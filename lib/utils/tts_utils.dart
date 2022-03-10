import 'package:flutter_tts/flutter_tts.dart';

class TTS {
  static FlutterTts? flutterTts;

  static speak(String txt) {
    if (flutterTts == null) {
      flutterTts = FlutterTts();
    }
    flutterTts!.setSpeechRate(0.2);
    flutterTts!.speak(txt);
  }
}
