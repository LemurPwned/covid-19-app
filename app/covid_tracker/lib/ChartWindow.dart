import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/widgets/CircleAvatar.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageTile> messageTiles = new List();

  final msgField = TextEditingController();

  @override
  void initState() {
    // initialize root dir

    var initialMessage = new MessageTile(
        "Hell! I'm here to help you!", 'Robo', DateTime.now(), TileType.SYSTEM);
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
    messageTiles.add(choiceMsg);
    messageTiles.add(mapMsg);
    super.initState();
  }

  void responseInteraction() {
    /// create a new Message
    var msgText = msgField.text;
    var msg = MessageTile(msgText, 'user', new DateTime.now(), TileType.USER);
    setState(() {
      messageTiles.add(msg);
      msgField.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  controller: msgField,
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
  }
}
