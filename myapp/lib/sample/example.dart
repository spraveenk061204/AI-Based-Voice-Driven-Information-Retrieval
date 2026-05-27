import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TtsDemoPage(),
    );
  }
}

class TtsDemoPage extends StatefulWidget {
  const TtsDemoPage({super.key});

  @override
  State<TtsDemoPage> createState() => _TtsDemoPageState();
}

class _TtsDemoPageState extends State<TtsDemoPage> {
  final FlutterTts tts = FlutterTts();
  final TextEditingController controller = TextEditingController();

  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  /// ✅ Initialize TTS
  Future<void> initTts() async {
    await tts.setLanguage("en-US");
    await tts.setPitch(1.0);
    await tts.setSpeechRate(0.5);

    tts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });

    tts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });

    tts.setCancelHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  /// ✅ Speak function
  Future<void> speak() async {
    String text = controller.text.trim();

    if (text.isEmpty) return;

    await tts.stop(); // stop previous speech
    await tts.speak(text);
  }

  /// ✅ Stop speech
  Future<void> stop() async {
    await tts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text("Flutter TTS Demo"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ TEXT INPUT
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter text to speak...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),
            /// ✅ SPEAK BUTTON
            ElevatedButton.icon(
              onPressed: speak,
              icon: const Icon(Icons.volume_up),
              label: const Text("Speak"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),

            const SizedBox(height: 10),

            /// ✅ STOP BUTTON
            ElevatedButton.icon(
              onPressed: stop,
              icon: const Icon(Icons.stop),
              label: const Text("Stop"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ STATUS TEXT
            Text(
              isSpeaking ? "🔊 Speaking..." : "Idle",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    tts.stop();
    controller.dispose();
    super.dispose();
  }
}