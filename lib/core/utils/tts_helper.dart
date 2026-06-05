import 'package:flutter_tts/flutter_tts.dart';

abstract final class TtsHelper {
  static final FlutterTts _tts = FlutterTts();
  static bool _ready = false;

  static Future<void> speak(String text) async {
    if (!_ready) {
      await _tts.setLanguage('en-US');
      // iOS maps ~0.5 to a natural speaking pace; 0.45 is slightly slower so
      // learners can clearly hear each syllable of a medical term.
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _ready = true;
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() => _tts.stop();
}
