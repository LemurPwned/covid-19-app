import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:disposables/disposables.dart';

class Speaker implements Disposable {
  final String language = "en-US";
  final String voiceCode = "en-us-x-sfg#female_2-local";

  static Speaker instance;

  Speaker() {
    speaker = new FlutterTts();
    configureSpeaker(language, voiceCode);
  }

  static Speaker getInstance() {
    if (instance == null) {
      instance = new Speaker();
    }
    return instance;
  }

  configureSpeaker(language, voiceCode) async {
    await _configureLanguage(language, voiceCode);
    print("Configured speaker, language: ${language}, voice: ${voiceCode}");
  }

  @override
  void dispose() {
    speaker.stop();
  }

  FlutterTts speaker;

  Future CustomSpeak(String text) async {
    if (text != null && text.isNotEmpty) {
      await new Future.delayed(const Duration(milliseconds : 600));
      var result = await speaker.speak(text);
    }
  }

  Future _configureLanguage(String lang, String voiceCode) async {
    // TODO: getting all voices
    //    languages = await flutterTts.getLanguages;
    //    if (languages != null) setState(() => languages);
    await speaker.setLanguage(lang);
    await speaker.setVoice(voiceCode);
    // TODO: get voices
    // await flutterTts.getVoices
  }

  @override
  bool get isDisposed => null;
}
