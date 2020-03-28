import 'package:flutter/material.dart';

final TextStyle newStyle = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 13.0,
    letterSpacing: -0.12,
    fontWeight: FontWeight.normal);

Widget getNothingScreen(String text) {
  return Center(
      child: Container(
          child: Text(
    text,
    style: newStyle,
  )));
}
