from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from fields.models import Field, Community

User = get_user_model()


class Command(BaseCommand):
    help = "Create initial Fields and Communities (English descriptions)."

    def handle(self, *args, **kwargs):
        # If you have a super-user, use it as creator for communities.
        admin_user = User.objects.filter(is_superuser=True).first()

        data = [
            {
                "field": {
                    "name": "Medical Fields",
                    "description": (
                        "Health-care sciences that focus on diagnosing diseases "
                        "and discovering safe, effective treatments."
                    ),
                },
                "communities": [
                    "Medicine",
                    "Pharmacy",
                    "Medical Laboratories",
                ],
            },
            {
                "field": {
                    "name": "Engineering Fields",
                    "description": (
                        "Applying scientific principles to design, build and "
                        "innovate everything from circuits to city skylines."
                    ),
                },
                "communities": [
                    "Electrical Engineering",
                    "Architecture",
                    "Civil Engineering",
                ],
            },
            {
                "field": {
                    "name": "Handicrafts",
                    "description": (
                        "Traditional hand-made skills that turn raw materials into art. "
                        "Blend creativity, precision and practical utility."
                    ),
                },
                "communities": [
                    "Crochet",
                    "Embroidery",
                    "Resin",
                ],
            },
        ]

        for item in data:
            # ---------- Field ----------
            field_obj, _ = Field.objects.get_or_create(
                name=item["field"]["name"],
                defaults={
                    "description": item["field"]["description"],
                },
            )

            # ---------- Communities under this Field ----------
            for comm_name in item["communities"]:
                Community.objects.get_or_create(
                    field=field_obj,
                    name=comm_name,
                    defaults={"created_by": admin_user},
                )

        self.stdout.write(self.style.SUCCESS("✅  Initial fields and communities created."))
