import 'package:covid_tracker/util/speaker.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracker/widgets/CircleAvatar.dart';
import 'package:covid_tracker/states/State.dart';
import 'package:covid_tracker/util/MessageTile.dart';

class ChatScreen extends StatefulWidget {
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
  List<MessageTile> _messageTiles = List();
  final _textController = TextEditingController();

  final StateMachineInteraction _stateInteraction = StateMachineInteraction();

  Speaker _speaker = Speaker.getInstance();
  int stateMachineStep = 0;

  @override
  void initState() {
    var initMsg = "Hello! Type in a greeting message to begin interaction!";
    var initialMessage =
        MessageTile(initMsg, 'Robo', DateTime.now(), TileType.SYSTEM);
    _messageTiles.add(initialMessage);

    super.initState();
    widget.onLoad(_messageTiles);
  }

  void responseInteraction() async {
    var msgText = _textController.text;
    // get selected choices
    var userChoices = _messageTiles.last.choices;
    print(userChoices);
    // TOOD: handle null submissions
    if (msgText.isNotEmpty) {
      setState(() {
        _messageTiles
            .add(MessageTile(msgText, 'user', DateTime.now(), TileType.USER));
        _textController.clear();
      });
      // initialise zero state
      MobileState cState = MobileState(
          StateType.TEXT,
          "0",
          DateTime.now().toIso8601String(),
          UserInput(msgText, choices: userChoices));

      var nextState;
      try {
        nextState = await _stateInteraction.fetchInteraction(cState);
      } catch (error) {
        print("Failed to get the response from the server");
      }
      if (nextState != null) {
        setState(() {
          _messageTiles.add(MessageTile.fromResponseState(nextState));
        });
      } else {
        setState(() {
          _messageTiles.add(MessageTile("Server currently unavailable!", 'Robo',
              DateTime.now(), TileType.SYSTEM));
        });
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
