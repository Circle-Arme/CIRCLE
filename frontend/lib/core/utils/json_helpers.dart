/// تُعيد `results` لو وُجدت، أو البيانات نفسها إن كانت List، وإلّا قائمة فارغة.
List<dynamic> asList(dynamic json) {
  if (json is List) return json;
  if (json is Map && json['results'] is List) return json['results'] as List;
  return [];
}
