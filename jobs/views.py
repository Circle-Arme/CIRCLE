# jobs/views.py
from rest_framework import generics, permissions
from .models import JobOpportunity, JobReply
from .serializers import JobOpportunitySerializer, JobReplySerializer

class JobOpportunityListCreateAPIView(generics.ListCreateAPIView):
    queryset = JobOpportunity.objects.all()
    serializer_class = JobOpportunitySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class JobReplyListCreateAPIView(generics.ListCreateAPIView):
    queryset = JobReply.objects.all()
    serializer_class = JobReplySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
