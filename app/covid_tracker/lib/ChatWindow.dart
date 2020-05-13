import 'package:covid_tracker/util/speaker.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/widgets/CircleAvatar.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:covid_tracker/util/LastBotValidResponse.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen() {}
  int speakerCursor = 0;
  int risk = 0;

  @override
  _ChatScreenState createState() {
    _ChatScreenState result = _ChatScreenState();
    return result;
  }

  void onLoad(List<MessageTile> list) async {
    Speaker speaker = Speaker.getInstance();

    if (list.length != speakerCursor)
      speaker.CustomSpeak(list.first.text);
    else
      await speaker.CustomSpeak(list.last.text);
  }
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> _messageTiles = new List();
  final _textController = TextEditingController();
  Speaker _speaker = Speaker.getInstance();
  int stateMachineStep = 0;
  LastBotValidResponse _lastValidResponse = null;

  @override
  void initState() {
    var initMsg = "Hello! My name in Covidella. I'm here to help you!";
    var initialMessage =
        new MessageTile(initMsg, 'Robo', DateTime.now(), TileType.SYSTEM);
    _messageTiles.add(initialMessage);

    _lastValidResponse = new LastBotValidResponse(0, initMsg);

//    var mapMsg = new MessageTile(
//        "Here's the nearest hospital", 'Robo', DateTime.now(), TileType.SYSTEM,
//        marker: new LatLng(50.03, 19.57));
//
//    var mapMsg2 = new MessageTile(
//        "Here's another hospital", 'Robo', DateTime.now(), TileType.SYSTEM,
//        marker: new LatLng(50.07, 19.60));
//    messageTiles.add(choiceMsg);
//    messageTiles.add(mapMsg);
//    messageTiles.add(mapMsg2);
    super.initState();
    widget.onLoad(_messageTiles);
  }

  void responseInteraction() {
    var msgText = _textController.text;
    if (msgText.isNotEmpty) _submitQuery(msgText);
  }

  void agentResponse(query) async {
    _textController.clear();
    String responseMessage = "";
    try {
      AuthGoogle authGoogle =
          await AuthGoogle(fileJson: "assets/newagent-jqwvxl-2cd321decf71.json")
              .build();
      Dialogflow dialogFlow =
          Dialogflow(authGoogle: authGoogle, language: Language.english);
      AIResponse response = await dialogFlow.detectIntent(query);

      var responseCode = response.getResponseCode;

      switch (responseCode) {
        case 200:
          {
            responseMessage = response.getMessage();
            ParseValidResponse(responseMessage);
            break;
          }
        case 400:
          {
            responseMessage =
                "Invalid configuration using this application. Contact me to solve this issue";
            break;
          }
        case 500:
          {
            responseMessage = "Backend server is unavailable. Try again later.";
            break;
          }
      }
    } on Exception catch (_) {
      print(
          'Exception during authentication to Google Cloud and DialogFlow was thrown');
      responseMessage = "Unexpected error occured. Please contact me on email";
    }

    await _speaker.CustomSpeak(responseMessage);

    MessageTile message = new MessageTile(
        responseMessage, 'Robo', DateTime.now(), TileType.SYSTEM);

    setState(() {
      _messageTiles.add(message);
    });
  }

  void _submitQuery(String text) {
    _textController.clear();
    var message =
        new MessageTile(text, 'user', new DateTime.now(), TileType.USER);
    setState(() {
      _messageTiles.add(message);
      _textController.clear();
    });
    agentResponse(text);
  }

  void ParseValidResponse(String response) {
    String keyword = "symptoms";
    switch (keyword) {
      case "symptoms":
        {
          List<String> choices = [
            "headache",
            "fever",
            "short-breath",
            "sneezing",
            "loss of smell"
          ];

          var choiceMsg = new MessageTile(
              "Pick symptoms that best describe how you feel!",
              'Robo',
              DateTime.now(),
              TileType.SYSTEM,
              choices: choices);

          _messageTiles.add(choiceMsg);
          break;
        }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Scaffold res = Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: _messageTiles.length,
                    itemBuilder: (ctx, i) {
                      if (_messageTiles[i].type == TileType.SYSTEM) {
                        return ReceivedMessagesWidget(
                            msgTile: _messageTiles[i]);
                      } else {
                        return SentMessageWidget(msgTile: _messageTiles[i]);
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15.0),
                  height: 61,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35.0),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 3),
                                  blurRadius: 5,
                                  color: Colors.grey)
                            ],
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 15),
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  decoration: InputDecoration(
                                      hintText: "Type Something...",
                                      border: InputBorder.none),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () => responseInteraction(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );

    return res;
  }
}
