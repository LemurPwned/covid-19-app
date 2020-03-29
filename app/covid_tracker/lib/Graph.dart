/// Example of a combo time series chart with two series rendered as lines, and
/// a third rendered as points along the top line with a different color.
///
/// This example demonstrates a method for drawing points along a line using a
/// different color from the main series color. The line renderer supports
/// drawing points with the "includePoints" option, but those points will share
/// the same color as the line.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:covid_tracker/util/speaker.dart';
import 'package:flutter/material.dart';
import 'package:covid_tracker/requests/FetchData.dart';
import 'package:covid_tracker/globals.dart';

class CovidGraph extends StatefulWidget {
  final bool animate;

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

  Widget pieChartBuilder() {
    return FutureBuilder(
        future: covidSummary,
        builder:
            (BuildContext context, AsyncSnapshot<List<NamedSeries>> snapshot) {
          if (!snapshot.hasData) return getNothingScreen("Loading a pie chart");
          return SizedBox(
              height: 300,
              width: 300,
              child: charts.BarChart(
                constructHistogramData(snapshot.data),
                animate: true,
              ));
        });
  }

  Widget timeSeriesBuilder() {
    return FutureBuilder(
        future: covidStats,
        builder: (BuildContext context,
            AsyncSnapshot<List<List<CovidStat>>> snapshot) {
          if (!snapshot.hasData)
            return getNothingScreen("Loading a time series!");
          return SizedBox(
              width: 300,
              height: 300,
              child: buildTimeSeriesChart(snapshot.data));
        });
  }

  Widget buildTimeSeriesChart(List<List<CovidStat>> data) {
    seriesList = constructSeriesFromData(data);
    return new charts.TimeSeriesChart(
      seriesList,
      animate: true,
      // Configure the default renderer as a line renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for  illustration.
      defaultRenderer: new charts.LineRendererConfig(),
      // Custom renderer configuration for the point series.
      customSeriesRenderers: [
        new charts.PointRendererConfig(
            // ID used to link series to this renderer
            customRendererId: 'customPoint')
      ],
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  Widget buildStatisticsView() {
    return ListView(children: <Widget>[
      pieChartBuilder(),
      SizedBox(height: 30),
      timeSeriesBuilder()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Speaker.getInstance().CustomSpeak("Let's see some charts.");
    return Scaffold(
      body: buildStatisticsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => updateLatestData(),
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
