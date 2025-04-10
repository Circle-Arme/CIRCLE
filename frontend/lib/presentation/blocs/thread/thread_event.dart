abstract class ThreadEvent {}

class FetchThreadsEvent extends ThreadEvent {
  final int communityId;
  final bool isJobOpportunity;

  FetchThreadsEvent(this.communityId, {this.isJobOpportunity = false});
}

class CreateThreadEvent extends ThreadEvent {
  final int communityId;
  final String title;
  final String content;
  final String classification;
  final List<String> tags;
  final bool isJobOpportunity;

  CreateThreadEvent(
      this.communityId,
      this.title,
      this.content,
      this.classification,
      this.tags, {
        this.isJobOpportunity = false,
      });
}