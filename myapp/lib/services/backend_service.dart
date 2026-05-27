import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_session.dart';

class BackendService {

   // static const String _endpoint ='http://10.0.2.2:8000/process-text';   //Emulator


  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    } else {
      return "http://10.0.2.2:8000";
    }
  }



  /*Future<String> sendAudio(File audioFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_endpoint),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody);

    final audioUrl = json['audio_url'] as String;

    return await _downloadAudio(audioUrl);
  }*/

  /*Future<String> sendText(String text) async {
        final response = await http.post(
          Uri.parse(_endpoint),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"text": text}),
        );

        if (response.statusCode != 200) {
          throw Exception('Backend error: ${response.statusCode}');
        }

        final json = jsonDecode(response.body);

        final audioUrl = json['audio_url'] as String;

        /// ✅ Download assistant audio
        return await _downloadAudio(audioUrl);
      }



      /// Downloads assistant audio and saves locally
  Future<String> _downloadAudio(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Failed to download audio');
    }

    final dir = await getTemporaryDirectory();
    print('${dir.path}');
    final filePath =
        '${dir.path}/assistant_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final file = File(filePath);
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }*/
  Future<String> sendText(String text,String chatID) async {
    final response = await http.post(
      Uri.parse("$baseUrl/process-text"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text,"chat_id":chatID}),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);

    print("FULL RESPONSE: $json");

    final llm_text = json['text'];

    print("🎧 Text from backend: $text");

    return llm_text;   // ✅ ✅ RETURN URL DIRECTLY
  }
  Future<List<ChatSession>> getChats() async {
    final res = await http.get(Uri.parse("$baseUrl/get-chats"));
    final data = jsonDecode(res.body);

    return data["chats"].map<ChatSession>((e) {
      return ChatSession(
        id: e["chat_id"],
        title: e["title"],
      );
    }).toList();
  }
  /// ✅ GET MESSAGES FOR A CHAT
  Future<List<dynamic>> getChatMessages(String chatId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/get-chat/$chatId"),
    );

    if (res.statusCode != 200) {
      return []; // ✅ avoid crash
    }

    final data = jsonDecode(res.body);

    return data["messages"] ?? [];
  }

}