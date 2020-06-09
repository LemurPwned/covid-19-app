import 'dart:math';

/// Example of a combo time series chart with two series rendered as lines, and
/// a third rendered as points along the top line with a different color.
///
/// This example demonstrates a method for drawing points along a line using a
/// different color from the main series color. The line renderer supports
/// drawing points with the "includePoints" option, but those points will share
/// the same color as the line.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:covid_tracker/widgets/TwitterView.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:covid_tracker/requests/FetchData.dart';
import 'package:covid_tracker/globals.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CovidGraph extends StatefulWidget {
  final bool animate;
  final DateTime initPos = DateTime.now().add(Duration(days: -1));

  CovidGraph({this.animate});

  @override
  _CovidGraphState createState() => _CovidGraphState();
}

class _CovidGraphState extends State<CovidGraph> {
  List<charts.Series> seriesList;
  Future<List<List<CovidStat>>> covidStats;
  Future<List<NamedSeries>> covidSummary;
  final String country = "Poland";
  _CovidGraphState();

  void updateLatestData() async {
    covidStats = DataFetcher.fetchCountryHistoric(country);
    covidSummary = DataFetcher.fetchCountryCurrent(country);
  }

  void buildSeriesList(List<List<CovidStat>> data) {
    setState(() {
      this.seriesList = constructSeriesFromData(data);
    });
  }

  @override
  void initState() {
    // initialize root dir
    seriesList = new List();
    updateLatestData();
    super.initState();
  }

  List<charts.Series<CovidStat, DateTime>> constructSeriesFromData(
      List<List<CovidStat>> data) {
    charts.Series<CovidStat, DateTime> casesList =
        charts.Series<CovidStat, DateTime>(
      id: 'Cases',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (CovidStat stats, _) => stats.day,
      measureFn: (CovidStat stats, _) => stats.cases,
      data: data[0],
    );
    charts.Series<CovidStat, DateTime> deathsList =
        charts.Series<CovidStat, DateTime>(
      id: 'Deaths',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (CovidStat stats, _) => stats.day,
      measureFn: (CovidStat stats, _) => stats.cases,
      data: data[1],
    );

    return [casesList, deathsList];
  }

  List<charts.Series<NamedSeries, String>> constructHistogramData(
      List<NamedSeries> data) {
    return [
      new charts.Series<NamedSeries, String>(
        id: 'Summary',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (NamedSeries obj, _) => obj.name,
        measureFn: (NamedSeries obj, _) => obj.value,
        data: data,
      )
    ];
  }

  Widget barChartBuilder(List<String> keys) {
    return FutureBuilder(
        future: covidSummary,
        builder:
            (BuildContext context, AsyncSnapshot<List<NamedSeries>> snapshot) {
          if (!snapshot.hasData) return getNothingScreen("Loading a pie chart");
          var filteredData = snapshot.data
              .where((element) => keys.contains(element.name))
              .toList();
          return charts.BarChart(
            constructHistogramData(filteredData),
            animate: true,
          );
        });
  }

  Widget timeSeriesBuilder() {
    return FutureBuilder(
        future: covidStats,
        builder: (BuildContext context,
            AsyncSnapshot<List<List<CovidStat>>> snapshot) {
          if (!snapshot.hasData)
            return getNothingScreen("Loading a time series!");
          return buildTimeSeriesChart(snapshot.data);
        });
  }

  static const months = {
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };

  DateTime _sliderDomainValue;
  num currentCases, currentDeaths;
  Point<int> _sliderPosition;
  DateFormat formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');

  _onSliderChange(Point<int> point, dynamic domain, String roleId,
      charts.SliderListenerDragState dragState) {
    // Request a build
    print("VAL ${formatter.format(domain)}");

    var dt = DateTime(domain.year, domain.month, domain.day);

    var cases = seriesList[0].data.map((e) => e.day).toList().indexOf(dt);
    var deaths = seriesList[1].measureFn(cases);
    cases = seriesList[0].measureFn(cases);
    print(cases);
    print(deaths);
    void rebuild(_) {
      setState(() {
        _sliderDomainValue = domain;
        currentCases = cases;
        currentDeaths = deaths;
      });
    }

    SchedulerBinding.instance.addPostFrameCallback(rebuild);
  }

  Widget buildTimeSeriesChart(List<List<CovidStat>> data) {
    seriesList = constructSeriesFromData(data);

    final children = <Widget>[
      SizedBox(
          height: 280.0,
          child: charts.TimeSeriesChart(
            seriesList,
            animate: false,
            behaviors: [
              charts.Slider(
                  initialDomainValue: this.widget.initPos,
                  onChangeCallback: _onSliderChange),
              charts.RangeAnnotation([
                charts.LineAnnotationSegment(
                    DateTime.now(), charts.RangeAnnotationAxisType.domain,
                    endLabel: DateTime.now().day.toString() +
                        " " +
                        months[DateTime.now().month]),
              ])
            ],
            // Configure the default renderer as a line renderer. This will be used
            // for any series that does not define a rendererIdKey.
            //
            // This is the default configuration, but is shown here for  illustration.
            defaultRenderer: charts.LineRendererConfig(),
            // Custom renderer configuration for the point series.
            customSeriesRenderers: [
              charts.PointRendererConfig(
                  // ID used to link series to this renderer
                  customRendererId: 'customPoint')
            ],
            // Optionally pass in a [DateTimeFactory] used by the chart. The factory
            // should create the same type of [DateTime] as the data provided. If none
            // specified, the default creates local date time.
            dateTimeFactory: const charts.LocalDateTimeFactory(),
          ))
    ];

    if (_sliderDomainValue != null) {
      String dateSlug =
          "${_sliderDomainValue.day.toString().padLeft(2, '0')}-${_sliderDomainValue.month.toString().padLeft(2, '0')}";

      children.add(Padding(
          padding: EdgeInsets.only(top: 1.0), child: Text('Date: $dateSlug')));
    }
    if (currentDeaths != null) {
      children.add(Padding(
          padding: EdgeInsets.only(top: 1.0),
          child: Text('Deaths: $currentDeaths, cases: $currentCases')));
    }

    return Column(children: children);
  }

  List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
    const StaggeredTile.count(4, 4),
    const StaggeredTile.count(2, 3),
    const StaggeredTile.count(2, 3),
    const StaggeredTile.count(4, 4),
  ];

  Widget buildStatisticsView() {
    return StaggeredGridView.count(
        crossAxisCount: 4,
        staggeredTiles: _staggeredTiles,
        children: [
          Card(child: timeSeriesBuilder()),
          Card(child: barChartBuilder(["todayCases", "critical"])),
          Card(child: barChartBuilder(["active", "recovered"])),
          Card(child: SizedBox(height: 350.0, child: TwitterView()))
        ],
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: const EdgeInsets.all(4.0));
  }

  @override
  Widget build(BuildContext context) {
    // Speaker.getInstance().CustomSpeak("Let's see some charts.");
    return Scaffold(
      appBar: AppBar(title: Text("Live cases")),
      body: buildStatisticsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => updateLatestData(),
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
