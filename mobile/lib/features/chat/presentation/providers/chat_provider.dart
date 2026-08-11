import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/datasources/chat_socket_datasource.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

final chatRemoteDataSourceProvider = Provider((ref) => ChatRemoteDataSource());
final chatSocketDataSourceProvider = Provider((ref) {
  final ds = ChatSocketDataSource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

// Conversations List State
class ConversationsNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  final ChatRemoteDataSource _remote;

  ConversationsNotifier(this._remote) : super(const AsyncValue.loading()) {
    loadConversations();
  }

  Future<void> loadConversations() async {
    try {
      state = const AsyncValue.loading();
      final list = await _remote.getConversations();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void updateLastMessage(String conversationId, String body, DateTime time) {
    if (!state.hasValue) return;
    final currentList = state.value!;
    
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final oldConv = currentList[index];
      final updated = Conversation(
        id: oldConv.id,
        userId: oldConv.userId,
        businessId: oldConv.businessId,
        lastMessageAt: time,
        createdAt: oldConv.createdAt,
        businessName: oldConv.businessName,
        businessLogo: oldConv.businessLogo,
        lastMessageBody: body,
        unreadCount: oldConv.unreadCount,
      );

      final newList = List<Conversation>.from(currentList);
      newList[index] = updated;
      
      // Sort by last message date descending
      newList.sort((a, b) {
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });
      state = AsyncValue.data(newList);
    }
  }

  void resetUnreadCount(String conversationId) {
    if (!state.hasValue) return;
    final currentList = state.value!;
    final index = currentList.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final oldConv = currentList[index];
      final updated = Conversation(
        id: oldConv.id,
        userId: oldConv.userId,
        businessId: oldConv.businessId,
        lastMessageAt: oldConv.lastMessageAt,
        createdAt: oldConv.createdAt,
        businessName: oldConv.businessName,
        businessLogo: oldConv.businessLogo,
        lastMessageBody: oldConv.lastMessageBody,
        unreadCount: 0,
      );
      final newList = List<Conversation>.from(currentList);
      newList[index] = updated;
      state = AsyncValue.data(newList);
    }
  }
}

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>((ref) {
  return ConversationsNotifier(ref.watch(chatRemoteDataSourceProvider));
});

// Active Chat Messages State
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatRemoteDataSource _remote;
  final ChatSocketDataSource _socket;
  final String _conversationId;

  ChatMessagesNotifier(this._remote, this._socket, this._conversationId)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    try {
      state = const AsyncValue.loading();
      final messages = await _remote.getMessages(_conversationId);
      state = AsyncValue.data(messages);

      // Connect and join socket room
      await _socket.connect();
      _socket.joinConversation(_conversationId);

      // Listen for socket messages
      _socket.messageStream.listen((msgMap) {
        if (msgMap['conversationId'] == _conversationId) {
          final msg = Message.fromJson(msgMap);
          _addMessage(msg);
        }
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _addMessage(Message msg) {
    if (!state.hasValue) return;
    final currentList = state.value!;
    
    // Avoid double inserts if socket echo returns
    if (currentList.any((m) => m.id == msg.id)) return;

    state = AsyncValue.data([...currentList, msg]);
  }

  Future<void> sendMessage(String body) async {
    if (_socket.isConnected) {
      _socket.sendMessage(_conversationId, body);
    } else {
      try {
        final msg = await _remote.sendMessage(_conversationId, body);
        _addMessage(msg);
      } catch (_) {
        _socket.sendMessage(_conversationId, body);
      }
    }
  }

  @override
  void dispose() {
    _socket.leaveConversation(_conversationId);
    super.dispose();
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<Message>>, String>((ref, conversationId) {
  return ChatMessagesNotifier(
    ref.watch(chatRemoteDataSourceProvider),
    ref.watch(chatSocketDataSourceProvider),
    conversationId,
  );
});
