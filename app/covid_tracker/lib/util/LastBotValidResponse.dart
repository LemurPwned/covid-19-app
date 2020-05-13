class LastBotValidResponse {
  int _graphStep;
  String _lastResponse;

  LastBotValidResponse(int step, String lastResponse) {
    _graphStep = step;
    _lastResponse = lastResponse;
  }

  int get getGraphStep {
    return _graphStep;
  }

  String get getLastResponse{
    return _lastResponse;
  }
}
