# jobs/urls.py
from django.urls import path
from .views import JobOpportunityListCreateAPIView, JobReplyListCreateAPIView

urlpatterns = [
    path('opportunities/', JobOpportunityListCreateAPIView.as_view(), name='job-opportunity-list'),
    path('replies/', JobReplyListCreateAPIView.as_view(), name='job-reply-list'),
]
