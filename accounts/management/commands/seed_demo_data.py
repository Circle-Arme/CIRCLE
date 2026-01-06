from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.db import transaction

from accounts.models      import UserProfile          # custom profile
from fields.models        import Community, UserCommunity
from ChatRoom.models      import ChatRoom, Thread, Reply

User = get_user_model()


class Command(BaseCommand):
    help = "Seeds 5 demo users (normal & organisation), 10 threads and 5 replies."

    def handle(self, *args, **kwargs):
        with transaction.atomic():
            # ------------------------------------------------------------------
            # 1. USERS
            # ------------------------------------------------------------------
            users_data = [
                # normal users
                {"email": "alice@example.com",   "password": "Pass1234", "first": "Alice", "last": "Johnson", "type": "normal"},
                {"email": "bob@example.com",     "password": "Pass1234", "first": "Bob",   "last": "Williams", "type": "normal"},
                {"email": "charlie@example.com", "password": "Pass1234", "first": "Charlie","last": "Brown",  "type": "normal"},
                # organisation users
                {"email": "acme@corp.com",       "password": "Pass1234", "first": "ACME",  "last": "Inc",     "type": "organization"},
                {"email": "globex@corp.com",     "password": "Pass1234", "first": "Globex","last": "Corp",    "type": "organization"},
            ]

            created_users = []

            for data in users_data:
                user, _ = User.objects.get_or_create(
                    email=data["email"],
                    defaults={
                        "first_name": data["first"],
                        "last_name":  data["last"],
                        "user_type":  data["type"],
                    },
                )
                # set / reset password every run (helpful in dev)
                user.set_password(data["password"])
                user.save(update_fields=["password"])

                created_users.append(user)

            self.stdout.write(self.style.SUCCESS(f"✔  Users ready ({len(created_users)})"))

            # ------------------------------------------------------------------
            # 2. JOIN COMMUNITIES
            # ------------------------------------------------------------------
            communities = list(Community.objects.all())
            if not communities:
                self.stdout.write(self.style.ERROR("✖  No communities found – seed them first!"))
                return

            # simple: user i joins community i % len(communities)
            for idx, user in enumerate(created_users):
                comm = communities[idx % len(communities)]
                UserCommunity.objects.get_or_create(user=user, community=comm)
                # also add to M2M on profile (if you rely on it)
                user.profile.communities.add(comm)

            self.stdout.write(self.style.SUCCESS("✔  Users linked to communities"))

            # ------------------------------------------------------------------
            # 3. THREADS (10)
            # ------------------------------------------------------------------
            thread_titles = [
                "Getting started in Medical Research",
                "Latest trends in Pharmacy automation",
                "Lab safety essentials everyone forgets",
                "Choosing the right micro-controller",
                "Sketching sustainable houses",
                "Reinforced concrete best practices",
                "Crochet: perfecting the magic ring",
                "Embroidery threads – cotton vs silk",
                "Preventing bubbles in resin casting",
                "Career paths for multidisciplinary engineers",
            ]

            threads = []

            for i, title in enumerate(thread_titles):
                author = created_users[i % len(created_users)]
                comm   = communities[i % len(communities)]
                room   = ChatRoom.objects.filter(
                            community=comm,
                            type="discussion_general"
                         ).first()  # fallback
                if not room:
                    room = ChatRoom.objects.filter(community=comm).first()

                thread, _ = Thread.objects.get_or_create(
                    title=title,
                    chat_room=room,
                    defaults={
                        "details": f"This is a demo thread about {title.lower()}. Feel free to comment!",
                        "created_by": author,
                        "classification": "General",
                    },
                )
                threads.append(thread)

            self.stdout.write(self.style.SUCCESS(f"✔  Threads ready ({len(threads)})"))

            # ------------------------------------------------------------------
            # 4. REPLIES (5)
            # ------------------------------------------------------------------
            reply_texts = [
                "Great point – thanks for sharing!",
                "I've tried that and it works well.",
                "Could you provide a reference?",
                "Interesting perspective, never thought of it that way.",
                "Here’s a link to further reading.",
            ]

            for i in range(5):
                thread = threads[i]
                author = created_users[(i + 1) % len(created_users)]  # different from thread author

                Reply.objects.get_or_create(
                    thread=thread,
                    reply_text=reply_texts[i],
                    created_by=author,
                )

            self.stdout.write(self.style.SUCCESS("✔  Replies added (5)"))

        self.stdout.write(self.style.SUCCESS("🎉  Demo data seeding complete!"))
