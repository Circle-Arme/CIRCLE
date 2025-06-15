

class RTEvent {
  final String type;
  final Map<String, dynamic> payload;
  RTEvent(this.type, this.payload);

  factory RTEvent.fromJson(Map<String, dynamic> json) {
    return RTEvent(json['type']??'',json);}
}
