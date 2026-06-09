import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:myapp/ui/widgets/glass_container.dart';
import 'package:myapp/ui/widgets/voice_bubble.dart';
import 'package:myapp/state/chat_controller.dart';
import 'package:myapp/services/backend_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/chat_session.dart';
import '../models/voice_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  ChatController chatController = ChatController();
  final FlutterTts tts = FlutterTts();
  final SpeechToText speechToText = SpeechToText();
  bool isListening = false;
  bool isLoading = false;
  final BackendService backend = BackendService();
  String chatId = DateTime.now().millisecondsSinceEpoch.toString();


  Future<void> handleSend(String text) async {

    if (text.trim().isEmpty) return;
    setState(() => isLoading = true);

    /// USER MESSAGE
    chatController.addMessage(
      VoiceMessage(
        text: text,
        sender: Sender.user,
        duration: Duration.zero,
      ),
    );

    chatController.queryController.clear();

    ///  LOADING
    chatController.addMessage(
      VoiceMessage(
        isLoading: true,
        sender: Sender.assistant,
        duration: Duration.zero,
      ),
    );


    try {
      final answerText =
      await backend.sendText(text, chatId);

      if (!isLoading) return;   //  IF STOPPED → ignore response

      chatController.removeLastMessage();

      chatController.addMessage(
        VoiceMessage(
          text: answerText,
          sender: Sender.assistant,
          duration: Duration.zero,
        ),
      );

      await tts.stop();
      await tts.speak(answerText);

    } catch (e) {
      print("Error: $e");
    }

    setState(() => isLoading = false);   //  STOP LOADING

  }
  @override
  void initState() {
    super.initState();
    chatController.createNewChat();
    loadChats();
    tts.setLanguage("en-US");
    tts.setPitch(1.1);
    tts.setSpeechRate(1.0);
    chatController.onAutoSend = handleSend;
  }


  Widget buildSidebar() {
    return Drawer(
      backgroundColor: Colors.white10,
      child: Column(
        children: [

          const SizedBox(height: 40),

          ///NEW CHAT
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text("New Chat",
                style: TextStyle(color: Colors.white)),
            onTap: () {

              chatId = DateTime.now().millisecondsSinceEpoch.toString();

              chatController.createNewChat();

              Navigator.pop(context);
            },
          ),

          const Divider(color: Colors.white24),


          Expanded(
            child: AnimatedBuilder(
              animation: chatController,
              builder: (context, _) {
                return ListView.builder(
                  itemCount: chatController.chats.length,
                  itemBuilder: (context, index) {

                    final chat = chatController.chats[index];
                    bool isHovering = false;
                    return StatefulBuilder(
                      builder: (context, setItemState) {



                        return MouseRegion(
                          onEnter: (_) => setItemState(() => isHovering = true),
                          onExit: (_) => setItemState(() => isHovering = false),

                          child: ListTile(
                            title: Text(
                              chat.title,
                              style: const TextStyle(color: Colors.white),
                            ),

                            selected: chat.id == chatController.activeChatId,

                            ///  SHOW ICONS ONLY ON HOVER
                            trailing: isHovering
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                ///  RENAME
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    showRenameDialog(chat);
                                  },
                                ),

                                /// 🗑️ DELETE
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDeleteDialog(chat);
                                  },
                                ),
                              ],
                            )
                                : null,

                            ///  OPTIONAL HOVER HIGHLIGHT
                            tileColor: isHovering ? Colors.white10 : null,

                            onTap: () async {
                              chatController.switchChat(chat.id);
                              chatId = chat.id;

                              final msgs = await backend.getChatMessages(chat.id);

                              chatController.setMessages(
                                msgs.map((m) {
                                  return VoiceMessage(
                                    text: m["content"],
                                    sender: m["role"] == "user"
                                        ? Sender.user
                                        : Sender.assistant,
                                    duration: Duration.zero,
                                  );
                                }).toList(),
                              );

                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      drawer: buildSidebar(),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'AI-Based Voice Driven Information Retrieval',
          style: TextStyle(color: Colors.white,fontSize: 18),

        ),
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 16),

              Expanded(
                child: GlassContainer(
                  child: Column(
                    children: [

                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: chatController,
                          builder: (context, _) {

                            if (chatController.messages.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.waving_hand_sharp, color: Colors.white, size: 50),
                                    SizedBox(height: 12),

                                    Text(
                                      "Hello, How can I assist you ?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 8),

                                    Text(
                                      "Ask anything using voice or text",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            else{
                              return ListView.builder(
                                itemCount:
                                chatController.messages.length,
                                itemBuilder: (context, index) {
                                  final message =
                                  chatController.messages[index];

                                  return Align(
                                    alignment: message.sender ==
                                        Sender.user
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: VoiceBubble(
                                      message: message,tts:tts
                                      //player: audioPlayer,
                                    ),
                                  );
                                },
                              );}
                          },
                        ),
                      ),
                      const SizedBox(height: 16),


                    ],
                  ),
                ),


              ),
              const SizedBox(height: 16),
              ///  QUERY BOX
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [

                    Expanded(
                      child: TextField(
                        controller: chatController.queryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Speak or type...",
                          hintStyle:
                          const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                            suffixIcon: GestureDetector(
                              onTap: () async {

                                ///  START LISTENING
                                if (!isListening) {

                                  bool available = await speechToText.initialize();

                                  if (available) {
                                    setState(() => isListening = true);

                                    chatController.queryController.text = "Listening...";

                                    speechToText.listen(
                                      onResult: (result) {
                                        chatController.queryController.text =
                                            result.recognizedWords;
                                      },
                                    );
                                  }
                                }

                                ///  STOP LISTENING
                                else {
                                  await speechToText.stop();
                                  setState(() => isListening = false);
                                }
                              },

                              child: Icon(
                                isListening ? Icons.stop_circle : Icons.mic,
                                color: isListening ? Colors.red : Colors.white,
                              ),
                            ),

                        ),
                      ),

                    ),


                    const SizedBox(width: 8),

                    /// SEND BUTTON
                    GestureDetector(
                      onTap: () {

                        if (isLoading) {
                          stopResponse();   // STOP
                        } else {
                          handleSend(chatController.queryController.text);
                        }

                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Icon( isLoading ? Icons.stop : Icons.send,   // toggle
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),



            ],
          ),
        ),
      ),
    );
  }
  Future<void> loadChats() async {
    final chats = await backend.getChats();
    chatController.setChats(chats); //  IMPORTANT
  }
  void stopResponse() {
    setState(() => isLoading = false);

    /// remove loading bubble
    chatController.removeLastMessage();

    ///  stop TTS
    tts.stop();
  }
  void showRenameDialog(dynamic chat) {
    TextEditingController controller =
    TextEditingController(text: chat.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,

          title: const Text(
            "Rename Chat",
            style: TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter new title",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {

                final newTitle = controller.text.trim();
                if (newTitle.isEmpty) return;

                /// CALL BACKEND
                await backend.renameChat(chat.id, newTitle);

                ///  UPDATE UI
                int index = chatController.chats
                    .indexWhere((c) => c.id == chat.id);

                if (index != -1) {
                  chatController.chats[index] =
                      ChatSession(id: chat.id, title: newTitle);

                  chatController.notifyListeners();
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
  void showDeleteDialog(dynamic chat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,

          title: const Text(
            "Delete Chat?",
            style: TextStyle(color: Colors.white),
          ),

          content: const Text(
            "This action cannot be undone.",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () async {

                /// DELETE FROM BACKEND
                await backend.deleteChat(chat.id);

                /// REMOVE FROM UI
                chatController.chats.removeWhere(
                        (c) => c.id == chat.id);

                /// HANDLE ACTIVE CHAT
                if (chatController.activeChatId == chat.id) {
                  chatController.createNewChat();
                  chatId = chatController.activeChatId!;
                }

                chatController.notifyListeners();

                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

}































