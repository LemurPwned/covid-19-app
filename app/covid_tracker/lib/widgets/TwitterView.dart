import 'package:http/http.dart';
import 'package:tweet_ui/models/api/tweet.dart';
import 'package:tweet_ui/tweet_ui.dart';
import 'package:twitter_api/twitter_api.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracker/globals.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Creating the twitterApi Object with the secret and public keys
// These keys are generated from the twitter developer page
// Dont share the keys with anyone

class TwitterView extends StatefulWidget {
  Tweet superiorContnet;
  @override
  _TwitterViewState createState() {
    _TwitterViewState result = _TwitterViewState();
    return result;
  }
}

class _TwitterViewState extends State<TwitterView> {
  Future<dynamic> liveTweet;
  twitterApi _twitterOauth;

  loadJson() async {
    String data = await rootBundle.loadString('assets/twitter.json');
    var jsonResult = json.decode(data);

    _twitterOauth = new twitterApi(
        consumerKey: jsonResult["consumerApiKey"],
        consumerSecret: jsonResult["consumerApiSecret"],
        token: jsonResult["accessToken"],
        tokenSecret: jsonResult["accessTokenSecret"]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadJson();
    });
    // read from json
  }

  Future<dynamic> getLatestTweet() async {
// Make the request to twitter
    return _twitterOauth.getTwitterRequest(
      // Http Method
      "GET",
      // Endpoint you are trying to reach
      "statuses/user_timeline.json",
      // The options for the request
      options: {
        // "user_id": "19025957",
        "screen_name": "MZ_GOV_PL",
        "count": "1",
        "trim_user": "false",
        "tweet_mode": "extended", // Used to prevent truncating tweets
      },
    );
  }

  Widget buildTweetViewFromResponse(Response response) {
    if (response.statusCode == 200) {
      var parsed = jsonDecode(response.body)[0];
      var tweet = Tweet.fromJson(parsed);
      this.widget.superiorContnet = tweet;
      return EmbeddedTweetView.fromTweet(tweet);
    }
    print("Failed to retrieve twitter view");

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (this.widget.superiorContnet == null) {
      return FutureBuilder(
          future: getLatestTweet(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData)
              return getNothingScreen("Loading latest tweets!");
            return buildTweetViewFromResponse(snapshot.data);
          });
    } else {
      return EmbeddedTweetView.fromTweet(this.widget.superiorContnet);
    }
  }
}
