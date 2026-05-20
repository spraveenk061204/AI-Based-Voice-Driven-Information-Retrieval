import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _text = "";
  String _status = "Tap mic to start";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // ✅ Initialize speech
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint("STATUS: $status");
      },
      onError: (error) {
        debugPrint("ERROR: ${error.errorMsg}");
      },
    );

    if (!available) {
      setState(() {
        _status = "Speech not available";
      });
    }
  }

  // ✅ Start listening
  void _startListening() async {
    setState(() {
      _isListening = true;
      _text = "";
      _status = "🎤 Listening...";
    });

    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        setState(() {
          _text = result.recognizedWords;

          // ✅ Stop automatically when final result
          if (result.finalResult) {
            _isListening = false;
            _status = "✅ Done speaking";
          }
        });
      },
    );
  }

  // ✅ Stop listening manually
  void _stopListening() async {
    await _speech.stop();

    setState(() {
      _isListening = false;
      _status = "🛑 Stopped";
    });
  }

  // ✅ Toggle mic
  void _toggleMic() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speech to Text Demo"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 30),

            // ✅ OUTPUT DISPLAY BOX
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _text.isEmpty
                      ? "Your speech will appear here..."
                      : _text,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ STATUS TEXT
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 40),

            // ✅ MICROPHONE BUTTON
            GestureDetector(
              onTap: _toggleMic,
              child: CircleAvatar(
                radius: 40,
                backgroundColor:
                _isListening ? Colors.red : Colors.blue,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ INSTRUCTION TEXT
            Text(
              _isListening
                  ? "Speak clearly..."
                  : "Tap mic and start speaking",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
