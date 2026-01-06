import random
from datetime import timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from fields.models import Community, UserCommunity
from ChatRoom.models import ChatRoom, Thread, Reply

User = get_user_model()

class Command(BaseCommand):
    help = "Create 20 users, 5 threads (3 EN, 2 AR) and 10 replies each in Medicine community."

    def handle(self, *args, **kwargs):
        # ------------------------------------------------------------------ #
        # 1) 20 USERS
        # ------------------------------------------------------------------ #
        users_data = [
            # 10 males
            ("mohamed.adel@example.com", "Mohamed", "Adel"),
            ("ahmed.said@example.com", "Ahmed", "Said"),
            ("youssef.kamel@example.com", "Youssef", "Kamel"),
            ("khaled.farouk@example.com", "Khaled", "Farouk"),
            ("omar.rashad@example.com", "Omar", "Rashad"),
            ("tarek.hassan@example.com", "Tarek", "Hassan"),
            ("hassan.nasser@example.com", "Hassan", "Nasser"),
            ("ibrahim.ali@example.com", "Ibrahim", "Ali"),
            ("mahmoud.samir@example.com", "Mahmoud", "Samir"),
            ("ramy.hamdy@example.com", "Ramy", "Hamdy"),
            # 10 females
            ("fatma.hosny@example.com", "Fatma", "Hosny"),
            ("sara.abdallah@example.com", "Sara", "Abdallah"),
            ("laila.naguib@example.com", "Laila", "Naguib"),
            ("dina.helmy@example.com", "Dina", "Helmy"),
            ("noha.hussein@example.com", "Noha", "Hussein"),
            ("salma.radi@example.com", "Salma", "Radi"),
            ("yara.elshamy@example.com", "Yara", "Elshamy"),
            ("rania.fathi@example.com", "Rania", "Fathi"),
            ("nour.magdy@example.com", "Nour", "Magdy"),
            ("marwa.gamal@example.com", "Marwa", "Gamal"),
        ]

        users = []
        for email, first, last in users_data:
            user, _ = User.objects.get_or_create(
                email=email,
                defaults={
                    "first_name": first,
                    "last_name": last,
                    "user_type": "normal",
                    "is_active": True,
                }
            )
            if not user.has_usable_password():
                user.set_password("password123")
                user.save(update_fields=["password"])
            users.append(user)
        self.stdout.write(self.style.SUCCESS(f"✓ Created/updated {len(users)} users"))

        # ------------------------------------------------------------------ #
        # 2) MEDICINE COMMUNITY + GENERAL ROOM
        # ------------------------------------------------------------------ #
        community, _ = Community.objects.get_or_create(name="Medicine")
        room, _ = ChatRoom.objects.get_or_create(
            community=community,
            type="discussion_general",
            defaults={"title": "General Discussion"}
        )

        # link users to community
        for user in users:
            UserCommunity.objects.get_or_create(
                user=user,
                community=community,
                defaults={"level": "both"}
            )
            user.profile.communities.add(community)

        # ------------------------------------------------------------------ #
        # 3) THREAD DEFINITIONS
        # ------------------------------------------------------------------ #
        english_threads = [
            {
                "title": "Emerging Trends in Telemedicine",
                "details": "How are you integrating telemedicine into daily practice?",
                "replies": [
                    "Video consultations have reduced clinic crowding for us.",
                    "What platforms are HIPAA‑compliant and easy to use?",
                    "Patient satisfaction skyrocketed after we added tele‑follow‑ups.",
                    "Bandwidth issues remain a challenge in rural areas.",
                    "Does anyone bill insurance successfully for tele‑visits?",
                    "We offer evening tele‑clinics; patients love the flexibility.",
                    "Any tips for handling elderly patients online?",
                    "Wearable data integration is our next step.",
                    "How do you ensure proper documentation?",
                    "Virtual triage cut ER visits by 30 % last quarter."
                ],
            },
            {
                "title": "Gene Therapy Success Stories",
                "details": "Share real cases where gene therapy changed patient outcomes.",
                "replies": [
                    "We treated a spinal muscular atrophy infant last month.",
                    "Long‑term data on hemophilia looks promising.",
                    "Cost remains the biggest obstacle for most families.",
                    "Vector delivery safety has greatly improved recently.",
                    "Patient selection criteria are still evolving.",
                    "We’re starting a trial on retinal dystrophy soon.",
                    "Regulatory approvals vary wildly by country.",
                    "Has anyone managed post‑therapy immune reactions?",
                    "Follow‑up imaging protocols you recommend?",
                    "Ethical counseling is crucial before consent."
                ],
            },
            {
                "title": "AI in Radiology — Hype or Reality?",
                "details": "Is artificial intelligence actually boosting diagnostic accuracy?",
                "replies": [
                    "Our AI tool flags TB on chest X‑rays with 92 % sensitivity.",
                    "Radiologists still need to validate every suggestion.",
                    "False positives can create workflow bottlenecks.",
                    "The learning curve was surprisingly short.",
                    "Cost‑benefit ratio depends on scan volume.",
                    "Integration with RIS/PACS is key.",
                    "Regulation around liability is still unclear.",
                    "AI helps junior staff build confidence.",
                    "We saw a 15 % drop in reporting time.",
                    "Bias in training data remains a concern."
                ],
            },
        ]

        arabic_threads = [
            {
                "title": "أحدث طرق علاج ضغط الدم المرتفع",
                "details": "ما هي البروتوكولات الحديثة للتحكم في ضغط الدم؟",
                "replies": [
                    "القياس المنزلي يساعد على ضبط الجرعات بدقة.",
                    "العلاج المزدوج أصبح أكثر شيوعًا الآن.",
                    "تغيير نمط الحياة لا يزال أساس العلاج.",
                    "هل جرّب أحدكم أجهزة قياس الضغط القابلة للارتداء؟",
                    "نعتمد على متابعة شهرية للمرضى كبار السن.",
                    "الأدوية المركبة تقلل عدد الحبوب اليومية.",
                    "دور الصوديوم في النظام الغذائي حاسم.",
                    "ما رأيكم في العلاجات العشبية المساعدة؟",
                    "جلسات التثقيف الصحي تحسن التزام المرضى.",
                    "هل هناك دراسات عربية حديثة حول الموضوع؟",
                ],
            },
            {
                "title": "تقنيات حديثة في جراحة العظام",
                "details": "شاركوا تجاربكم مع الروبوت الجراحي في عمليات المفاصل.",
                "replies": [
                    "دقة القطع العظمي ارتفعت بشكل كبير.",
                    "وقت العملية أصبح أقل بحوالي 20٪.",
                    "التكلفة ما زالت تحديًا في المستشفيات الحكومية.",
                    "التدريب على الجهاز يحتاج وقتًا.",
                    "نتائج المرضى من حيث الألم أفضل.",
                    "هل واجهتم أعطال تقنية أثناء الجراحة؟",
                    "التصوير ثلاثي الأبعاد قبل العملية مفيد جدًا.",
                    "متى تتوقعون انتشار التقنية على نطاق واسع؟",
                    "سلامة المرضى تحسنت بفضل الحركات الدقيقة.",
                    "هناك منح لشراء الأجهزة في بعض الدول.",
                ],
            },
        ]

        # ------------------------------------------------------------------ #
        # 4) CREATE THREADS & REPLIES
        # ------------------------------------------------------------------ #
        now = timezone.now()

        def create_thread(thread_data, language_tag):
            thread = Thread.objects.create(
                chat_room=room,
                title=thread_data["title"],
                details=thread_data["details"],
                created_by=random.choice(users),
                created_at=now - timedelta(days=random.randint(1, 20)),
                language=language_tag,          # إن كان لديك حقل لغة
            )
            for text in thread_data["replies"]:
                Reply.objects.create(
                    thread=thread,
                    reply_text=text,
                    created_by=random.choice(users),
                    created_at=thread.created_at + timedelta(hours=random.randint(1, 72))
                )
            self.stdout.write(self.style.SUCCESS(f"• {language_tag.upper()} thread “{thread.title}” + 10 replies created"))

        #for t in english_threads:
            #create_thread(t, "en")

        #for t in arabic_threads:
            #create_thread(t, "ar")

        self.stdout.write(self.style.SUCCESS("✅ Medicine sample data created successfully."))
