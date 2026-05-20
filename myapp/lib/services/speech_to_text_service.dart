import 'package:speech_to_text/speech_to_text.dart';

class SpeechResult {
  final String text;

  SpeechResult(this.text);
  String getText(){
    return this.text;
  }
}

class SpeechToTextUtil {
  final SpeechToText _speech = SpeechToText();


  Future<SpeechResult> listenWithResult() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("STATUS: $status");
      },
      onError: (error) {
        print("ERROR: ${error.errorMsg}");
      },
    );

    if (!available) return SpeechResult("");

    String recognizedText = "";

    await _speech.listen(
      listenMode: ListenMode.dictation,
      partialResults: true,
      cancelOnError: true,
      onResult: (result) {
        print("RESULT: ${result.recognizedWords}");

        // ✅ Always capture latest spoken words
        if (result.recognizedWords.isNotEmpty) {
          recognizedText = result.recognizedWords;
        }
      },
    );

    /// ✅ Fixed listening window
    await Future.delayed(const Duration(seconds: 6));

    await _speech.stop();

    print("✅ FINAL TEXT RETURNED: $recognizedText");

    return SpeechResult(recognizedText);
  }

}