import 'package:vosk_flutter/vosk_flutter.dart';

class VoskService {
  late Model _model;
  Recognizer? _recognizer;
  SpeechService? _speech;

  bool _isInitialized = false;
  String _finalText = "";

  Future<void> init() async {
    if (_isInitialized) return;

    print("🔥 VOSK INIT START");

    final vosk = VoskFlutterPlugin.instance();

    /// ✅ Load from Android assets
    _model = await vosk.createModel("C:/Users/s.praveenk/Downloads/vosk-model-small-en-us-0.15/vosk-model-small-en-us-0.15");

    _recognizer = await vosk.createRecognizer(
      model: _model,
      sampleRate: 16000,
    );

    _speech = await vosk.initSpeechService(_recognizer!);

    _isInitialized = true;

    print("✅ VOSK INIT DONE");
  }

  Future<void> start(Function(String) onText) async {
    await init();

    _finalText = "";

    _speech!.onResult().listen((event) {
      final text = (event as Map)["text"]?.toString() ?? "";

      if (text.isNotEmpty) {
        _finalText = text;
        onText(text); // LIVE TEXT
      }
    });

    await _speech!.start();
  }

  Future<String> stop() async {
    await _speech?.stop();
    return _finalText;
  }
}