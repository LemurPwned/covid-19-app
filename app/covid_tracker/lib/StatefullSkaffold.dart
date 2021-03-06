import 'package:covid_tracker/ChatWindow.dart';
import 'package:covid_tracker/Graph.dart';
import 'package:covid_tracker/util/speaker.dart';
import 'package:covid_tracker/widgets/MapWidget.dart';
import 'package:flutter/material.dart';


class MainScaffold extends StatefulWidget {
  @required
  List<PageStorage> screens;
  final List<String> names = ["Chat", "Charts"];

  MainScaffold() {
    Speaker.getInstance();

    screens = [
      PageStorage(child: ChatScreen(), bucket: PageStorageBucket()),
      PageStorage(child: CovidGraph(), bucket: PageStorageBucket()),
    ];
  }

  @override
  MainScaffoldState createState() {
    return new MainScaffoldState();
  }
}

class MainScaffoldState extends State<MainScaffold> {
  int currentScreen = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(20.0), // here the desired height
            child: AppBar(
                // ...
                )),
        bottomNavigationBar: buildBottomNavigationBar(context),
        backgroundColor: Color(0xFFF2F2F2),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: widget.screens,
        ));
  }

  BottomNavigationBar buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentScreen,
        onTap: (index) {
          this._pageController.animateToPage(index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut);
          setState(() {
            this.currentScreen = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text("Chat")),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), title: Text("Chart"))
        ]);
  }
}
