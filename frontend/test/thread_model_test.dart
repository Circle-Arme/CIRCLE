/*
// test/thread_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/models/thread_model.dart';

void main() {
  test('ThreadModel.fromJson parses JSON correctly', () {
    final jsonData = {
      "id": "123",
      "title": "Test Thread",
      "creatorName": "User A",
      "createdAt": "2025-03-29T10:00:00Z",
      "repliesCount": 5,
      "classification": "Q&A",
      "content": "Test content",
      "tags": ["flutter", "test"]
    };

    final thread = ThreadModel.fromJson(jsonData);

    expect(thread.id, "123");
    expect(thread.title, "Test Thread");
    expect(thread.creatorName, "User A");
    expect(thread.repliesCount, 5);
    expect(thread.classification, "Q&A");
    expect(thread.content, "Test content");
    expect(thread.tags, ["flutter", "test"]);
  });

  test('ThreadModel.toJson returns correct JSON map', () {
    final thread = ThreadModel(
      id: "123",
      title: "Test Thread",
      creatorName: "User A",
      createdAt: DateTime.parse("2025-03-29T10:00:00Z"),
      repliesCount: 5,
      classification: "Q&A",
      content: "Test content",
      tags: const ["flutter", "test"],
    );

    final json = thread.toJson();

    expect(json["id"], "123");
    expect(json["title"], "Test Thread");
    expect(json["creatorName"], "User A");
    expect(json["repliesCount"], 5);
    expect(json["classification"], "Q&A");
    expect(json["content"], "Test content");
    expect(json["tags"], ["flutter", "test"]);
    expect(json["createdAt"], "2025-03-29T10:00:00.000Z");
  });
}
*/
