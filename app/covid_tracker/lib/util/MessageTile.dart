import 'package:covid_tracker/states/State.dart';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

enum TileType { SYSTEM, USER, TWEET }
Color myGreen = Color(0xff4bb17b);

class MessageTile {
  @required
  String text;
  @required
  String username;
  @required
  DateTime time;
  @required
  TileType type;
  List<String> choices;
  LatLng marker;
  bool tweet = false;

  MessageTile(this.text, this.username, this.time, this.type,
      {this.choices, this.marker, this.tweet});

  String dateString() {
    return "${this.time.hour}:${this.time.minute}";
  }

  MessageTile.fromResponseState(ResponseState st) {
    this.text = st.messageText;
    this.username = "Robo";
    this.time = DateTime.now();
    this.type = TileType.SYSTEM;
    if (st.messageChoices != null) this.choices = st.messageChoices;
    print(st.state);
    if (st.state == StateType.LOCATION) {
      // location set
      print("\n Setting up the location! \n");
      this.marker = LatLng(0.0, 0.0);
    }
  }
}
