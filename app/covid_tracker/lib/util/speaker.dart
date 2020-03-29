import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:disposables/disposables.dart';

abstract class SpeakFuncionality {
  Future CustomSpeak(String text);
}

class Speaker implements Disposable, SpeakFuncionality {
  final String language = "en-US";
  final String voiceCode = "en-us-x-sfg#male_1-local";

  static Speaker instance;

  Speaker() {
    speaker = new FlutterTts();
    _configureLanguage(language, voiceCode);
  }

  static Speaker getInstance() {
    if (instance == null) {
      instance = new Speaker();
    }
    return instance;
  }

  @override
  void dispose() {
    speaker.stop();
  }

  FlutterTts speaker;

  @override
  Future CustomSpeak(String text) async {
    if (text != null && text.isNotEmpty) {
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
