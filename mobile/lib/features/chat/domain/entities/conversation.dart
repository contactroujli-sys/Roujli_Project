class Conversation {
  final String id;
  final String userId;
  final String businessId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String businessName;
  final String? businessLogo;
  final String? lastMessageBody;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.userId,
    required this.businessId,
    this.lastMessageAt,
    required this.createdAt,
    required this.businessName,
    this.businessLogo,
    this.lastMessageBody,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final messages = json['messages'] as List<dynamic>?;
    String? lastMsg;
    if (messages != null && messages.isNotEmpty) {
      lastMsg = messages.first['body'] as String?;
    }
    final count = json['_count'] as Map<String, dynamic>?;
    final unread = count?['messages'] as int? ?? 0;

    return Conversation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessId: json['businessId'] as String,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      businessName: business?['name'] as String? ?? 'Business',
      businessLogo: business?['logo'] as String?,
      lastMessageBody: lastMsg,
      unreadCount: unread,
    );
  }
}
