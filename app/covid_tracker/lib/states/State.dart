import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

enum StateType { LOCATION, MULTICHOICE, TEXT, TWITTER }

class UserInput {
  final String message;
  List<String> choices;

  UserInput(this.message, {this.choices});

  Map<String, dynamic> toJson() => {'message': message, 'choices': choices};

  UserInput.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        choices = json['choices'];
}

class ResponseState {
  @required
  StateType state;
  @required
  String intent;

  @required
  String messageText;
  @required
  bool responseExpected;
  List<String> messageChoices;

  ResponseState.fromJson(Map<String, dynamic> json) {
    this.state = StateType.values[json['state']];
    this.intent = json['intent'];
    this.messageText = json['messageText'];
    if (json['messageChoices'] != null) {
      this.messageChoices = List<String>.from(json['messageChoices']);
    } else {
      this.messageChoices = null;
    }
    this.responseExpected = json['responseExpected'];
  }
}

class MobileState {
  final StateType state;
  final String userId;
  final String timestamp;
  final UserInput userInput;
  MobileState(this.state, this.userId, this.timestamp, this.userInput);

  MobileState.fromJson(Map<String, dynamic> json)
      : state = json['state'],
        userId = json['userId'],
        timestamp = json['timestamp'],
        userInput = json['userInput'];

  Map<String, dynamic> toJson() => {
        "state": state.toString(),
        "userId": userId,
        "timestamp": timestamp,
        "userInput": userInput.toJson()
      };
}

class StateMachineInteraction {
  Future<ResponseState> fetchInteraction(MobileState state) async {
    final localState = jsonEncode(state.toJson());
    print(localState);
    final response = await http.post("http://192.168.0.15:3000/response",
        body: localState, headers: {'Content-type': 'application/json'});

    print(response);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      print(responseBody);
      return ResponseState.fromJson(responseBody);
    } else {
      throw Exception("Failed to fetch next State");
    }
  }
}
