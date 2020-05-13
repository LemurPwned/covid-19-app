enum StateType { LOCATION, MULTICHOICE, TEXT, TWITTER }

class UserInput {
  final String message;
  List<String> choices;

  UserInput({this.message});

  Map<String, dynamic> toJson() => {'message': message, 'choices': choices};

  UserInput.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        choices = json['choices'];
}

class MobileState {
  final StateType state;
  final String userId;
  final String timestamp;
  final UserInput userInput;
  MobileState({this.state, this.userId, this.timestamp, this.userInput});

  MobileState.fromJson(Map<String, dynamic> json)
      : state = json['state'],
        userId = json['userId'],
        timestamp = json['timestamp'],
        userInput = json['userInput'];

  Map<String, dynamic> toJson() => {
        'state': state,
        'userId': userId,
        'timestamp': timestamp,
        'userInput': userInput
      };
}
