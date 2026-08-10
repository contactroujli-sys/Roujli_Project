class Message {
  final String id;
  final String body;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.body,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      body: json['body'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderRole: json['senderRole'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
