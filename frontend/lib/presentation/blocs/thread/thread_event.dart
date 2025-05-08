// thread_event.dart
import 'package:file_picker/file_picker.dart';

abstract class ThreadEvent {}

class FetchThreadsEvent extends ThreadEvent {
  final int communityId;
  final String roomType;
  final bool isJobOpportunity;

  FetchThreadsEvent(this.communityId, this.roomType, {this.isJobOpportunity = false});
}

class CreateThreadEvent extends ThreadEvent {
  final int communityId;
  final String roomType;
  final String title;
  final String content;
  final String classification;
  final List<String> tags;
  final PlatformFile? file;
  final bool isJobOpportunity;

  // الحقول الجديدة الخاصة بفرص العمل
  final String? jobType;
  final String? location;
  final String? salary;

  CreateThreadEvent(
      this.communityId,
      this.roomType,
      this.title,
      this.content,
      this.classification,
      this.tags, {
        this.file,
        this.isJobOpportunity = false,
        this.jobType,
        this.location,
        this.salary,
      });
}
