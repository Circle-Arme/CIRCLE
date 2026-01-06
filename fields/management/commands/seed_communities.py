# fields/management/commands/seed_communities.py

import random
from datetime import timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from faker import Faker

from fields.models import Community, UserCommunity
from ChatRoom.models import ChatRoom, Thread, Reply, Like

User = get_user_model()


class Command(BaseCommand):
    help = "Seed the DB with realistic communities, users, threads and replies (Arabic + English)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--users", type=int, default=40,
            help="Number of users to generate (default: 40)."
        )

    def handle(self, *args, users, **kwargs):
        fake_en = Faker()
        fake_ar = Faker("ar_EG")
        now = timezone.now()

        # 1) أنشئ بعض المستخدمين الجدد إن لزم الأمر
        existing_users = list(User.objects.all())
        needed = users - len(existing_users)
        new_users = []
        for _ in range(max(0, needed)):
            # اختر لغة الملف الشخصي إنكليزي أو عربي
            locale = random.choice(["en", "ar"])
            fake = fake_ar if locale == "ar" else fake_en
            first, last = fake.first_name(), fake.last_name()
            email = fake.unique.email()
            u = User(
                email=email,
                first_name=first,
                last_name=last,
                user_type="normal",
                is_active=True,
            )
            u.set_password("password123")
            new_users.append(u)

        # bulk_create للمستخدمين الجدد
        if new_users:
            User.objects.bulk_create(new_users, batch_size=500)
            # إعادة جلب كل المستخدمين ليملأ PK في الكائنات
            all_users = list(User.objects.all())
        else:
            all_users = existing_users

        # 2) جلب كل المجتمعات
        communities = list(Community.objects.all().prefetch_related("chat_rooms"))
        if not communities:
            self.stderr.write("⚠️  لا توجد Communities. شغّل أمر create_fields أولاً.")
            return

        # أضف superuser لكل مجتمع لضمان ظهور المحتوى
        dev_user = User.objects.filter(is_superuser=True).first()
        if dev_user:
            for c in communities:
                UserCommunity.objects.get_or_create(
                    user=dev_user, community=c,
                    defaults={"level": "both"}
                )

        # 3) وزع المستخدمين على المجتمعات
        user_comms = []
        for c in communities:
            members = random.sample(all_users, k=min(len(all_users), random.randint(15, 25)))
            for u in members:
                # الآن u.pk موجودة، فلا خطأ
                if not UserCommunity.objects.filter(user=u, community=c).exists():
                    user_comms.append(
                        UserCommunity(user=u, community=c,
                                      level=random.choice(["beginner", "advanced", "both"]))
                    )
        UserCommunity.objects.bulk_create(user_comms, ignore_conflicts=True)

        # 4) قوالب المحتوى (عربي وإنجليزي)
        templates = {
            "ar": {
                "thread_title": lambda: fake_ar.sentence(nb_words=6),
                "thread_details": lambda: fake_ar.paragraph(nb_sentences=3),
                "reply": lambda: fake_ar.sentence(nb_words=10),
            },
            "en": {
                "thread_title": lambda: fake_en.sentence(nb_words=6),
                "thread_details": lambda: fake_en.paragraph(nb_sentences=3),
                "reply": lambda: fake_en.sentence(nb_words=10),
            },
        }

        # 5) إنشاء Threads
        created_threads = []
        for c in communities:
            general_room = c.chat_rooms.filter(type="discussion_general").first()
            if not general_room:
                continue

            members_ids = list(c.memberships.values_list("user_id", flat=True))
            for _ in range(random.randint(8, 15)):
                lang = random.choice(["ar", "en"])
                temp = templates[lang]
                thread_time = now - timedelta(days=random.randint(0, 30),
                                              hours=random.randint(0, 23))
                t = Thread(
                    chat_room=general_room,
                    title=temp["thread_title"](),
                    details=temp["thread_details"](),
                    created_by_id=random.choice(members_ids),
                    created_at=thread_time,
                )
                created_threads.append(t)
        Thread.objects.bulk_create(created_threads, batch_size=500)

        # 6) إنشاء Replies
        all_threads = list(Thread.objects.only("id", "chat_room_id", "created_at"))
        created_replies = []
        for thread in all_threads:
            community = ChatRoom.objects.get(id=thread.chat_room_id).community
            members_ids = list(community.memberships.values_list("user_id", flat=True))
            # أفترض لغة إنجليزية إذا لم تضف حقل language
            lang = "en"
            temp = templates[lang]
            for _ in range(random.randint(3, 10)):
                created_replies.append(
                    Reply(
                        thread_id=thread.id,
                        reply_text=temp["reply"](),
                        created_by_id=random.choice(members_ids),
                        created_at=thread.created_at + timedelta(hours=random.randint(1, 70)),
                    )
                )
        Reply.objects.bulk_create(created_replies, batch_size=1000)

        # 7) إنشاء Likes (على Threads و Replies)
        created_likes = []
        # ثريدات
        for thread in all_threads:
            community = ChatRoom.objects.get(id=thread.chat_room_id).community
            members_ids = list(community.memberships.values_list("user_id", flat=True))
            likers = random.sample(members_ids, k=max(1, int(len(members_ids)*0.2)))
            for u in likers:
                created_likes.append(Like(user_id=u, thread_id=thread.id))
        # ردود
        reply_ids = list(Reply.objects.values_list("id", flat=True))
        for rid in reply_ids:
            rp = Reply.objects.select_related("thread__chat_room__community").get(id=rid)
            members_ids = list(rp.thread.chat_room.community.memberships.values_list("user_id", flat=True))
            likers = random.sample(members_ids, k=max(1, int(len(members_ids)*0.1)))
            for u in likers:
                created_likes.append(Like(user_id=u, reply_id=rid))

        Like.objects.bulk_create(created_likes, ignore_conflicts=True, batch_size=5000)

        self.stdout.write(self.style.SUCCESS(
            f"✅ Seeded: {len(all_users)-len(existing_users)} new users, "
            f"{len(created_threads)} threads, "
            f"{len(created_replies)} replies, "
            f"{len(created_likes)} likes."
        ))
