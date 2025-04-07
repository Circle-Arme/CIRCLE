from django.contrib import admin
from .models import JobOpportunity
from organizations.models import Organization

class JobOpportunityAdmin(admin.ModelAdmin):
    list_display = ('title', 'organization', 'posted_at')
    search_fields = ('title',)

admin.site.register(JobOpportunity, JobOpportunityAdmin)
