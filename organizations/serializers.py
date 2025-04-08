from rest_framework import serializers
from .models import Organization
from fields.models import Community

class OrganizationSerializer(serializers.ModelSerializer):
    communities = serializers.PrimaryKeyRelatedField(
        queryset=Community.objects.all(),
        many=True
    )

    class Meta:
        model = Organization
        fields = ['id', 'name', 'description', 'website', 'communities']
