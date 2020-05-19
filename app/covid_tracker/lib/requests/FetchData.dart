import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:async';

const String url = "https://corona.lmao.ninja/v2/historical/";
const String countryUrl = "https://corona.lmao.ninja/v2/countries/";

class NamedSeries {
  final String name;
  final int value;

  NamedSeries(this.name, this.value);
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
  static Future<List<NamedSeries>> fetchCountryCurrent(String country) async {
    String properUrl = countryUrl + country;
    final response = await http.get(properUrl);
    if (response.statusCode == 200) {
      var resBody = json.decode(response.body);
      List<NamedSeries> nS = new List();

      List<String> desiredKeys = [
        'cases',
        'todayCases',
        'todayDeaths',
        'recovered',
        'active',
        'critical'
      ];

      resBody.forEach((k, v) {
        if (desiredKeys.contains(k)) {
          nS.add(NamedSeries(k, v));
        }
      });
      return nS;
    } else {
      throw Exception("Failed to fetch Historic data for $country");
    }
  }

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
