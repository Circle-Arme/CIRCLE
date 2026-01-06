import random
from datetime import datetime, timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from django.utils import timezone
from fields.models import Field, Community, UserCommunity
from ChatRoom.models import ChatRoom, Thread, Reply, Like

User = get_user_model()

class Command(BaseCommand):
    help = "Create sample users, threads, replies, and likes for communities with mixed Arabic and English content."

    def handle(self, *args, **kwargs):
        # Sample user data (Arabic and English names)
        sample_users = [
            {"first_name": "Abeer", "last_name": "Abdo", "email": "abeer.abdo@example.com"},
            {"first_name": "Eilaf", "last_name": "Adel", "email": "eilaf.adel@example.com"},
            {"first_name": "Mayada", "last_name": "Seedahmed", "email": "mayada.seed@example.com"},
            {"first_name": "Riham", "last_name": "Abd-Elfatah", "email": "riham.awad@example.com"},
            {"first_name": "Ruba", "last_name": "", "email": "ruba@example.com"},
            {"first_name": "Memam", "last_name": "", "email": "memam@example.com"},
            {"first_name": "John", "last_name": "Smith", "email": "john.smith@example.com"},
            {"first_name": "Emma", "last_name": "Wilson", "email": "emma.wilson@example.com"},
        ]

        # Create users
        users = []
        for user_data in sample_users:
            user, created = User.objects.get_or_create(
                email=user_data["email"],
                defaults={
                    "first_name": user_data["first_name"],
                    "last_name": user_data["last_name"],
                    "user_type": "normal",
                    "is_active": True,
                }
            )
            if created:
                user.set_password("password123")
                user.save()
                user.profile.name = f"{user.first_name} {user.last_name}".strip()
                user.profile.email = user.email
                user.profile.save()
                self.stdout.write(self.style.SUCCESS(f"Created user: {user.email}"))
            users.append(user)

        # Get all communities
        communities = Community.objects.all()
        if not communities:
            self.stdout.write(self.style.ERROR("No communities found. Run `create_fields` first."))
            return

        # Content for threads and replies (Arabic and English)
        community_content = {
            "Medicine": {
                "language": "ar",
                "thread_title": "أحدث التطورات في علاج الأمراض المزمنة",
                "thread_details": "ما هي أحدث الأبحاث حول علاج الأمراض المزمنة مثل السكري؟ شاركوا تجاربكم!",
                "replies": [
                    "سمعت عن دراسة جديدة تستخدم العلاج الجيني، هل لديكم تفاصيل؟",
                    "أنا طبيب وأرى أن الوقاية لا تزال الخيار الأفضل. وأنتم؟",
                    "هل هناك مؤتمرات طبية قريبة لمناقشة هذا الموضوع؟"
                ],
                "job_opportunity": {
                    "title": "وظيفة طبيب أخصائي في مستشفى مرموق",
                    "details": "مستشفى في الرياض يبحث عن طبيب أخصائي باطنة. الخبرة: 5 سنوات.",
                    "job_type": "دوام كامل",
                    "location": "الرياض، السعودية",
                    "salary": "20,000 ريال شهريًا",
                    "job_link": "https://example.com/apply",
                    "job_link_type": "direct",
                }
            },
            "Pharmacy": {
                "language": "en",
                "thread_title": "Clinical Pharmacy and Patient Care",
                "thread_details": "How can pharmacists enhance patient experiences in hospitals?",
                "replies": [
                    "As a clinical pharmacist, I find direct interaction with doctors crucial.",
                    "Are there any recommended training courses for clinical pharmacy?",
                    "What are the best software tools for pharmacy management?"
                ],
                "job_opportunity": {
                    "title": "Pharmacist at a Major Pharmacy Chain",
                    "details": "A leading pharmacy chain in Cairo is seeking a pharmacist.",
                    "job_type": "Part-time",
                    "location": "Cairo, Egypt",
                    "salary": "8000 EGP monthly",
                    "job_link": "https://example.com/apply-pharmacy",
                    "job_link_type": "external",
                }
            },
            "Medical Laboratories": {
                "language": "ar",
                "thread_title": "تقنيات جديدة في تحليل العينات الطبية",
                "thread_details": "ما هي أحدث التقنيات في مختبرات التحاليل الطبية؟",
                "replies": [
                    "جهاز PCR الجديد سريع جدًا! هل تستخدمونه؟",
                    "أحتاج نصائح لتحسين دقة النتائج في المختبر.",
                    "ما رأيكم في الأتمتة في المختبرات؟"
                ],
                "job_opportunity": {
                    "title": "فني مختبر طبي",
                    "details": "مطلوب فني مختبر للعمل في مختبر حديث بدبي.",
                    "job_type": "دوام كامل",
                    "location": "دبي، الإمارات",
                    "salary": "15,000 درهم شهريًا",
                    "job_link": "https://example.com/apply-lab",
                    "job_link_type": "direct",
                }
            },
            "Electrical Engineering": {
                "language": "en",
                "thread_title": "The Future of Renewable Energy",
                "thread_details": "How can electrical engineers contribute to clean energy solutions?",
                "replies": [
                    "I'm working on a solar energy project, any tips?",
                    "What are the best circuit design software tools?",
                    "Is AI transforming the future of electrical engineering?"
                ],
                "job_opportunity": {
                    "title": "Electrical Engineer at a Renewable Energy Company",
                    "details": "A renewable energy firm is seeking an electrical engineer.",
                    "job_type": "Full-time",
                    "location": "London, UK",
                    "salary": "£50,000 annually",
                    "job_link": "https://example.com/apply-electrical",
                    "job_link_type": "external",
                }
            },
            "Architecture": {
                "language": "ar",
                "thread_title": "تصميم المباني المستدامة",
                "thread_details": "ما هي أفضل الممارسات لتصميم مباني صديقة للبيئة؟",
                "replies": [
                    "استخدام المواد المعاد تدويرها فعال جدًا!",
                    "هل هناك برامج تصميم معماري موصى بها؟",
                    "ما رأيكم في التصاميم الحديثة في الشرق الأوسط؟"
                ],
                "job_opportunity": {
                    "title": "مهندس معماري",
                    "details": "مكتب تصميم في إسطنبول يبحث عن مهندس معماري.",
                    "job_type": "دوام كامل",
                    "location": "إسطنبول، تركيا",
                    "salary": "100,000 ليرة تركية شهريًا",
                    "job_link": "https://example.com/apply-architecture",
                    "job_link_type": "direct",
                }
            },
            "Civil Engineering": {
                "language": "en",
                "thread_title": "Challenges in Modern Bridge Design",
                "thread_details": "What are the biggest challenges in designing bridges today?",
                "replies": [
                    "Vibrations from wind are a major issue!",
                    "Do you use software like SAP2000?",
                    "Any tips for managing large-scale construction projects?"
                ],
                "job_opportunity": {
                    "title": "Civil Engineer",
                    "details": "A construction company is seeking a civil engineer for major projects.",
                    "job_type": "Full-time",
                    "location": "Doha, Qatar",
                    "salary": "25,000 QAR monthly",
                    "job_link": "https://example.com/apply-civil",
                    "job_link_type": "external",
                }
            },
            "Crochet": {
                "language": "ar",
                "thread_title": "أفكار جديدة لمشاريع الكروشيه",
                "thread_details": "شاركوا أفكاركم لمشاريع كروشيه مبتكرة!",
                "replies": [
                    "صنعت حقيبة كروشيه رائعة، هل تريدون الصور؟",
                    "ما نوع الخيوط المفضل لديكم؟",
                    "هل هناك دروس كروشيه مجانية أونلاين؟"
                ],
                "job_opportunity": {
                    "title": "مصمم كروشيه",
                    "details": "متجر يدوي يبحث عن مصمم كروشيه لتصميم منتجات جديدة.",
                    "job_type": "عمل حر",
                    "location": "عن بُعد",
                    "salary": "$500 لكل مشروع",
                    "job_link": "https://example.com/apply-crochet",
                    "job_link_type": "direct",
                }
            },
            "Embroidery": {
                "language": "en",
                "thread_title": "Modern Embroidery Techniques",
                "thread_details": "What are the latest embroidery techniques you're using?",
                "replies": [
                    "Free-motion embroidery is so versatile!",
                    "Any favorite embroidery machines?",
                    "Where do you find inspiration for your designs?"
                ],
                "job_opportunity": {
                    "title": "Embroidery Designer",
                    "details": "A boutique is seeking an embroidery designer for custom projects.",
                    "job_type": "Freelance",
                    "location": "Remote",
                    "salary": "$600 per project",
                    "job_link": "https://example.com/apply-embroidery",
                    "job_link_type": "external",
                }
            },
            "Resin": {
                "language": "ar",
                "thread_title": "فن الريزين: نصائح وأفكار",
                "thread_details": "ما هي أفضل النصائح للعمل مع الريزين؟ شاركوا إبداعاتكم!",
                "replies": [
                    "استخدام القوالب السيليكون يعطي نتائج رائعة!",
                    "كيف تتجنبون الفقاعات في الريزين؟",
                    "هل هناك ورش عمل لفن الريزين؟"
                ],
                "job_opportunity": {
                    "title": "فنان ريزين",
                    "details": "متجر فني يبحث عن فنان ريزين لتصميم قطع ديكور.",
                    "job_type": "عمل حر",
                    "location": "عن بُعد",
                    "salary": "$400 لكل مشروع",
                    "job_link": "https://example.com/apply-resin",
                    "job_link_type": "direct",
                }
            }
        }

        # Assign users to communities and create content
        for community in communities:
            # Assign random users to this community
            community_users = random.sample(users, k=min(5, len(users)))
            for user in community_users:
                UserCommunity.objects.get_or_create(
                    user=user,
                    community=community,
                    defaults={"level": random.choice(['beginner', 'advanced', 'both'])}
                )
                user.profile.communities.add(community)
                self.stdout.write(self.style.SUCCESS(f"Added {user.email} to {community.name}"))

            # Get content for this community
            content = community_content.get(community.name)
            if not content:
                continue

            # Create thread in discussion_general room
            discussion_room = community.chat_rooms.filter(type="discussion_general").first()
            if discussion_room:
                thread = Thread.objects.create(
                    chat_room=discussion_room,
                    title=content["thread_title"],
                    details=content["thread_details"],
                    created_by=random.choice(community_users),
                    created_at=timezone.now() - timedelta(days=random.randint(0, 30))
                )
                self.stdout.write(self.style.SUCCESS(f"Created thread in {community.name}: {thread.title}"))

                # Create replies
                for reply_text in content["replies"]:
                    Reply.objects.create(
                        thread=thread,
                        reply_text=reply_text,
                        created_by=random.choice(community_users),
                        created_at=thread.created_at + timedelta(hours=random.randint(1, 72))
                    )
                self.stdout.write(self.style.SUCCESS(f"Created {len(content['replies'])} replies for thread: {thread.title}"))

                # Add likes to thread and replies
                for user in random.sample(community_users, k=min(3, len(community_users))):
                    Like.objects.get_or_create(user=user, thread=thread)
                for reply in thread.replies.all():
                    for user in random.sample(community_users, k=min(2, len(community_users))):
                        Like.objects.get_or_create(user=user, reply=reply)
                self.stdout.write(self.style.SUCCESS(f"Added likes to thread and replies in {community.name}"))

            # Create job opportunity in job_opportunities room
            job_room = community.chat_rooms.filter(type="job_opportunities").first()
            if job_room and content.get("job_opportunity"):
                job = content["job_opportunity"]
                job_thread = Thread.objects.create(
                    chat_room=job_room,
                    title=job["title"],
                    details=job["details"],
                    created_by=random.choice(community_users),
                    is_job_opportunity=True,
                    job_type=job["job_type"],
                    location=job["location"],
                    salary=job["salary"],
                    job_link=job["job_link"],
                    job_link_type=job["job_link_type"],
                    created_at=timezone.now() - timedelta(days=random.randint(0, 30))
                )
                self.stdout.write(self.style.SUCCESS(f"Created job opportunity in {community.name}: {job_thread.title}"))

        self.stdout.write(self.style.SUCCESS("✅ Sample data creation completed."))