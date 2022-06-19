import 'package:event/event.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class DataTest extends EventArgs {
  String value = '';
}

class mySTT {
  static SpeechToText? speechToText;
  static String lastWords = "";
  static Event<DataTest> myEvent = Event<DataTest>();

  static initialize() async {
    await speechToText!.initialize(debugLogging: false);
  }
  static Future<Event<DataTest>> listen(String language) async{
    if(speechToText == null){
      speechToText = SpeechToText();
      await initialize();
    }
    speechToText!.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        onSoundLevelChange: null,
        localeId: language,
        partialResults: false,
    );
    return myEvent;
  }

  static void _onSpeechResult(SpeechRecognitionResult result) {
    lastWords = result.recognizedWords;
    DataTest test = DataTest();
    test.value = lastWords;
    myEvent.broadcast(test);
    // print("onSpeech" + lastWords);
  }
}



