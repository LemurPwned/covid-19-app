import 'package:covid_tracker/widgets/MapWidget.dart';
import 'package:covid_tracker/widgets/TwitterView.dart';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/util/MessageTile.dart';

final robotUrl =
    'https://www.pinclipart.com/picdir/big/344-3446018_best-whiteboard-video-software-robot-logo-png-clipart.png';

class CustomCircleAvatar extends StatelessWidget {
  final String imgUrl;
  const CustomCircleAvatar({
    Key key,
    @required this.imgUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.3),
              offset: Offset(0, 2),
              blurRadius: 5)
        ],
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage("$imgUrl"),
      ),
    );
  }
}

class TwitterMessageWidget extends StatefulWidget {
  @override
  TwitterMessageWidgetState createState() => TwitterMessageWidgetState();
}

class TwitterMessageWidgetState extends State<TwitterMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return TwitterView();
  }
}

class ReceivedMessagesWidget extends StatefulWidget {
  final MessageTile msgTile;
  final void Function({bool overrideChoices}) uberResponseManager;
  const ReceivedMessagesWidget(
      {Key key, @required this.msgTile, this.uberResponseManager})
      : super(key: key);

  @override
  ReceivedMessagesWidgetState createState() => ReceivedMessagesWidgetState();
}

class ReceivedMessagesWidgetState extends State<ReceivedMessagesWidget> {
  MessageTile currentMsgTile;

  @override
  void initState() {
    // initialize root dir
    currentMsgTile = this.widget.msgTile;
    // Speaker.getInstance().CustomSpeak(currentMsgTile.text)
    super.initState();
  }

  List<String> selectedChoices = List();

  List<Widget> formTransformedTiles(List<String> choices) {
    List<Widget> widgetList = new List();
    choices.forEach((choice) => widgetList.add(new Container(
          padding: const EdgeInsets.all(2.0),
          child: ChoiceChip(
            autofocus: false,
            clipBehavior: Clip.antiAlias,
            label: Text(choice),
            selected: selectedChoices.contains(choice),
            onSelected: (selected) {
              setState(() {
                selectedChoices.contains(choice)
                    ? selectedChoices.remove(choice)
                    : selectedChoices.add(choice);
              });
            },
          ),
        )));
    widgetList.add(FlatButton(
      splashColor: Colors.blue,
      child: Text("Accept symptoms"),
      onPressed: () {
        if (this.widget.uberResponseManager != null) {
          this.widget.uberResponseManager(overrideChoices: true);
        }
      },
    ));
    return widgetList;
  }

  Widget askForChoice(List<String> choices) {
    if (choices != null && choices.isNotEmpty) {
      return Wrap(
          alignment: WrapAlignment.start,
          spacing: 4.0,
          children: formTransformedTiles(choices));
    } else {
      return SizedBox.shrink();
    }
  }

  List<String> getSelectedChoices() {
    return selectedChoices;
  }

  Widget locationDirective(LatLng destination) {
    if (destination != null) {
      return MapWidget(destinationMarker: destination);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget tweetDisplay() {
    if (currentMsgTile.tweet) {
      return TwitterView();
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    var body22 = Theme.of(context).textTheme.bodyText1;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                CustomCircleAvatar(imgUrl: robotUrl),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentMsgTile.username,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .6),
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color(0xfff9f9f9),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            currentMsgTile.text,
                            style: Theme.of(context).textTheme.body1.apply(
                                  color: Colors.black87,
                                ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          locationDirective(currentMsgTile.marker),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 15),
                Text(
                  currentMsgTile.dateString(),
                  style: body22.apply(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 5),
            askForChoice(currentMsgTile.choices),
          ],
        ));
  }
}

class SentMessageWidget extends StatelessWidget {
  final MessageTile msgTile;

  const SentMessageWidget({Key key, this.msgTile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            msgTile.dateString(),
            style: Theme.of(context).textTheme.body2.apply(color: Colors.grey),
          ),
          SizedBox(width: 15),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .6),
            padding: const EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: myGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            child: Text(
              msgTile.text,
              style: Theme.of(context).textTheme.body2.apply(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
