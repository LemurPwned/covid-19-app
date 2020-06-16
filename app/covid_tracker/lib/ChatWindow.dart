import 'dart:async';

import 'package:covid_tracker/util/speaker.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracker/widgets/CircleAvatar.dart';
import 'package:covid_tracker/states/State.dart';
import 'package:covid_tracker/util/MessageTile.dart';

class ChatScreen extends StatefulWidget {
  int speakerCursor = 0;

  @override
  ChatScreenState createState() {
    ChatScreenState result = ChatScreenState();
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

class ChatScreenState extends State<ChatScreen> {
  List<MessageTile> _messageTiles = List();
  final _textController = TextEditingController();
  final ScrollController _controller = ScrollController();
  final StateMachineInteraction _stateInteraction = StateMachineInteraction();

  Speaker _speaker = Speaker.getInstance();

  @override
  void initState() {
    var initMsg = "Hello! Type in a greeting message to begin interaction!";
    var initialMessage =
        MessageTile(initMsg, 'Robo', DateTime.now(), TileType.SYSTEM);
    _messageTiles.add(initialMessage);

    super.initState();
    widget.onLoad(_messageTiles);
  }

  void responseInteraction({bool overrideChoices = false}) async {
    var msgText = _textController.text;
    // get selected choices
    var userChoices = _messageTiles.last.choices;
    if (overrideChoices) {
      msgText = "These are my symptoms!";
    }
    // TOOD: handle null submissions
    if (msgText.isNotEmpty) {
      setState(() {
        _messageTiles
            .add(MessageTile(msgText, 'user', DateTime.now(), TileType.USER));
        _textController.clear();
      });
      _controller.jumpTo(_controller.position.maxScrollExtent);
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
        print("Failed to get the response from the server: " + error.toString());
      }
      if (nextState != null) {
        var msgTile = MessageTile.fromResponseState(nextState);
        setState(() {          
          _messageTiles.add(msgTile);
        });
        _speaker.CustomSpeak(msgTile.text);

        if(msgTile.choices != null){
          _speaker.CustomSpeak(msgTile.choices.join(" "));
        }
      } else {
        var msgText = "Server currently unavailable!";
        setState(() {          
          _messageTiles.add(MessageTile(msgText, 'Robo',
              DateTime.now(), TileType.SYSTEM));
        });
        
        _speaker.CustomSpeak(msgText);
      }
    }
    _controller.jumpTo(_controller.position.maxScrollExtent);
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
                    controller: _controller,
                    reverse: false,
                    padding: const EdgeInsets.all(15),
                    itemCount: _messageTiles.length,
                    itemBuilder: (ctx, i) {
                      if (_messageTiles[i].type == TileType.SYSTEM) {
                        return ReceivedMessagesWidget(
                          msgTile: _messageTiles[i],
                          uberResponseManager: responseInteraction,
                        );
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
