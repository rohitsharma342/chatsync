import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../data/static_data.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  String _currentGroupId = '';
  bool _isLoading = false;
  bool _isOnline = true;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  void loadMessages(String groupId) {
    _isLoading = true;
    _currentGroupId = groupId;
    notifyListeners();

    _messages = StaticData.messages
        .where((msg) => msg.groupId == groupId)
        .toList();

    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: 'msg${StaticData.messages.length + 1}',
      groupId: groupId,
      senderId: senderId,
      senderName: senderName,
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    StaticData.messages.add(newMessage);
    _messages.add(newMessage);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _currentGroupId = '';
    notifyListeners();
  }

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }
}