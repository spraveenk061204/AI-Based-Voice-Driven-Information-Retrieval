import 'package:flutter/material.dart';
import '../models/voice_message.dart';

class ChatController extends ChangeNotifier {
  final List<VoiceMessage> _messages = [];

  List<VoiceMessage> get messages => _messages;

  void addMessage(VoiceMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}