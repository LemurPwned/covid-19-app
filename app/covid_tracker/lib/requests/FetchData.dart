import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

const String url = "https://corona.lmao.ninja/v2/historical/";

class GraphData {
  List<String> timelineDates;
  List<int> timelineCases;
  List<int> timelineDeaths;
  String countryName;
  GraphData(String country) {
    timelineDates = new List();
    timelineDeaths = new List();
    timelineCases = new List();
    this.countryName = country;
  }
}

class CovidStat {
  final DateTime day;
  final int cases;
  // int deaths;
  CovidStat(this.day, this.cases);

  factory CovidStat.fromJsonKeys(String key, int value) {
    List<String> dt = key.split('/');
    var covidStat = CovidStat(
        DateTime(int.parse("20" + dt[2]), int.parse(dt[0]), int.parse(dt[1])),
        value);
    return covidStat;
  }
}

class DataFetcher {
  static Future<List<List<CovidStat>>> fetchCountryHistoric(
      String country) async {
    String properUrl = url + country;

    final response = await http.get(properUrl);
    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);

      List<CovidStat> covidCaseStats = new List();
      List<CovidStat> covidDeathStats = new List();
      resBody['timeline']['cases'].forEach((key, value) =>
          covidCaseStats.add(CovidStat.fromJsonKeys(key, value)));

      resBody['timeline']['deaths'].forEach((key, value) =>
          covidDeathStats.add(CovidStat.fromJsonKeys(key, value)));
      return [covidCaseStats, covidDeathStats];
    } else {
      throw Exception("Failed to fetch Historic data for $country");
    }
  }
}