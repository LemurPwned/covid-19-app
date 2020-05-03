import 'package:covid_tracker/util/speaker.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/widgets/CircleAvatar.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen() {}
  int speakerCursor = 0;

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
  List<MessageTile> messageTiles = new List();
  final _textController = TextEditingController();

  @override
  void initState() {
    var initialMessage = new MessageTile(
        "Hello! My name in Covidella. I'm here to help you!",
        'Robo',
        DateTime.now(),
        TileType.SYSTEM);
    messageTiles.add(initialMessage);
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
    var mapMsg = new MessageTile(
        "Here's the nearest hospital", 'Robo', DateTime.now(), TileType.SYSTEM,
        marker: new LatLng(50.03, 19.57));

    var mapMsg2 = new MessageTile(
        "Here's another hospital", 'Robo', DateTime.now(), TileType.SYSTEM,
        marker: new LatLng(50.07, 19.60));
    messageTiles.add(choiceMsg);
    messageTiles.add(mapMsg);
    messageTiles.add(mapMsg2);
    super.initState();
    widget.onLoad(messageTiles);
  }

  void responseInteraction() {
    /// create a new Message
    var msgText = _textController.text;
    _submitQuery(msgText);
  }

  void agentResponse(query) async {
    _textController.clear();
    AuthGoogle authGoogle =
    await AuthGoogle(fileJson: "assets/valued-torch-276019-6e8cd0e1a520.json").build();
    Dialogflow dialogFlow =
    Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogFlow.detectIntent(query);
    MessageTile message = new MessageTile(
        response.getMessage(),
        'Robo',
        DateTime.now(),
        TileType.SYSTEM);

    setState(() {
      messageTiles.add( message);
    });
  }

  void _submitQuery(String text) {
    _textController.clear();
    var message = new MessageTile(text, 'user', new DateTime.now(), TileType.USER);
    setState(() {
      messageTiles.add(message);
      _textController.clear();
    });
    agentResponse(text);
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
                    itemCount: messageTiles.length,
                    itemBuilder: (ctx, i) {
                      if (messageTiles[i].type == TileType.SYSTEM) {
                        return ReceivedMessagesWidget(msgTile: messageTiles[i]);
                      } else {
                        return SentMessageWidget(msgTile: messageTiles[i]);
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
