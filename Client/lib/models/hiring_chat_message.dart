class HiringChatMessage {
  final int? id;
  final int applicationId;
  final int senderId;
  final String message;
  final DateTime? timestamp;

  HiringChatMessage({
    this.id,
    required this.applicationId,
    required this.senderId,
    required this.message,
    this.timestamp,
  });

  factory HiringChatMessage.fromJson(Map<String, dynamic> json) =>
      HiringChatMessage(
        id: json['id'],
        applicationId: json['applicationId'],
        senderId: json['senderId'],
        message: json['message'],
        timestamp:
            json['timestamp'] != null
                ? DateTime.parse(json['timestamp'])
                : null,
      );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'applicationId': applicationId,
    'senderId': senderId,
    'message': message,
  };
}
