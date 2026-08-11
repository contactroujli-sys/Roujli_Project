import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/storage_service.dart';

class ChatSocketDataSource {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  bool get isConnected => _socket != null && _socket!.connected;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await StorageService.getAccessToken();
    if (token == null) return;

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      log('Socket.IO connected to backend');
    });

    _socket!.onDisconnect((_) {
      log('Socket.IO disconnected');
    });

    _socket!.on('new_message', (data) {
      if (data != null) {
        _messageController.add(Map<String, dynamic>.from(data as Map));
      }
    });

    _socket!.on('user_typing', (data) {
      if (data != null) {
        _typingController.add(Map<String, dynamic>.from(data as Map));
      }
    });

    _socket!.connect();
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', {'conversationId': conversationId});
  }

  void sendMessage(String conversationId, String body) {
    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'body': body,
    });
  }

  void startTyping(String conversationId) {
    _socket?.emit('typing', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    _socket?.emit('stop_typing', {'conversationId': conversationId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
  }
}
