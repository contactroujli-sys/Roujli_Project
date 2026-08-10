import 'package:dio/dio.dart';
import '../../../../core/services/dio_service.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

class ChatRemoteDataSource {
  final Dio _dio = DioService.instance;

  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get('/messages');
    final list = response.data['data'] as List<dynamic>;
    return list.map((item) => Conversation.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final response = await _dio.get('/messages/$conversationId');
    final list = response.data['data'] as List<dynamic>;
    return list.map((item) => Message.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Conversation> startConversation(String businessId) async {
    final response = await _dio.post('/messages/start/$businessId');
    return Conversation.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
