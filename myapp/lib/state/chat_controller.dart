import 'package:flutter/material.dart';
import '../models/chat_session.dart';
import '../models/voice_message.dart';

class ChatController extends ChangeNotifier {
  final TextEditingController queryController = TextEditingController();
  List<VoiceMessage> _messages = [];

  List<VoiceMessage> get messages => _messages;
  List<ChatSession> chats = [];
  String? activeChatId;

  void addMessage(VoiceMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeLastMessage() {
    if (messages.isNotEmpty) {
      messages.removeLast();
      notifyListeners();
    }


  }

  void createNewChat() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    chats.insert(
      0,
      ChatSession(
        id: id,
        title: "New Chat",
      ),
    );

    activeChatId = id;
    _messages.clear();

    notifyListeners();
  }

  void switchChat(String chatId) {
    activeChatId = chatId;
    _messages.clear();

    notifyListeners();
  }

  void setMessages(List<VoiceMessage> newMessages) {
    _messages = newMessages;
    notifyListeners();
  }
  void setChats(List<ChatSession> newChats) {
    chats = newChats;
    notifyListeners();
  }



  Function(String text)? onAutoSend;

}