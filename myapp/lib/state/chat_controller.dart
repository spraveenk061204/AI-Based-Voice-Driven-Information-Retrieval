import 'package:flutter/material.dart';
import '../models/voice_message.dart';

class ChatController extends ChangeNotifier {
  final TextEditingController queryController = TextEditingController();
  final List<VoiceMessage> _messages = [];

  List<VoiceMessage> get messages => _messages;

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

}