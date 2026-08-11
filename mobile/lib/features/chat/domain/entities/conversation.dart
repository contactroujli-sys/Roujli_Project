class Conversation {
  final String id;
  final String userId;
  final String businessId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String businessName;
  final String? businessLogo;
  final String? userName;
  final String? userAvatar;
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
    this.userName,
    this.userAvatar,
    this.lastMessageBody,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final business = json['business'] as Map<String, dynamic>?;
    final userObj = json['user'] as Map<String, dynamic>?;
    final profile = userObj?['profile'] as Map<String, dynamic>?;
    final messages = json['messages'] as List<dynamic>?;
    String? lastMsg;
    if (messages != null && messages.isNotEmpty) {
      lastMsg = messages.first['body'] as String?;
    }
    final count = json['_count'] as Map<String, dynamic>?;
    final unread = count?['messages'] as int? ?? 0;

    String? uName;
    String? uAvatar;
    if (profile != null) {
      final fName = profile['firstName'] as String? ?? '';
      final lName = profile['lastName'] as String? ?? '';
      final name = '$fName $lName'.trim();
      if (name.isNotEmpty) uName = name;
      uAvatar = profile['avatar'] as String?;
    }

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
      userName: uName,
      userAvatar: uAvatar,
      lastMessageBody: lastMsg,
      unreadCount: unread,
    );
  }
}
