import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/globals.dart';

class MapWidget extends StatefulWidget {
  LatLng destinationMarker;
  String hospitalName = "";
  MapWidget({this.destinationMarker, this.hospitalName});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  // Krakow
  LatLng currentLocation = new LatLng(50.03, 19.56);
  LatLngBounds globalBounds;
  Placemark currentPlace;
  Future<Position> position;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final MapController mapController = MapController();
  Future<Position> getCurrentLocation() async {
    Position pos = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks = await geolocator.placemarkFromPosition(pos);

    Placemark place = placemarks[0];
    print(
        "${place.locality}, ${place.postalCode}, ${place.country}, ${place.administrativeArea}");

    if (this.widget.destinationMarker != null &&
        this.widget.destinationMarker.latitude == 0.0) {
      var hosp = await findNearestHospital(LatLng(pos.latitude, pos.longitude));
      this.widget.destinationMarker =
          LatLng(hosp.value['latitude'], hosp.value['longitude']);
      this.widget.hospitalName = hosp.key.toString();
    }

    return pos;
  }

  Future<MapEntry<String, dynamic>> findNearestHospital(
      LatLng currentLoc) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/full_data.json");
    final jsonResult = json.decode(data);

    var smallestDist = 100000000.0;
    dynamic closest;
    for (var entry in jsonResult.entries) {
      var hospital = LatLng(entry.value['latitude'], entry.value['longitude']);
      final distance = Distance();
      var km = distance.as(LengthUnit.Kilometer, currentLoc, hospital);
      if (km < smallestDist) {
        smallestDist = km;
        closest = entry;
      }
    }
    return closest;
  }

  @override
  void initState() {
    // get location

    super.initState();
  }

  Widget getFlutterMap(Position position) {
    currentLocation = new LatLng(position.latitude, position.longitude);
    LatLngBounds bounds;
    List<Marker> markerList = [
      new Marker(
        width: 80.0,
        height: 80.0,
        point: currentLocation,
        builder: (ctx) => new Container(
          child: Icon(Icons.person_pin_circle),
        ),
      )
    ];
    if (this.widget.destinationMarker != null) {
      markerList.add(
        new Marker(
          width: 80.0,
          height: 80.0,
          point: this.widget.destinationMarker,
          builder: (ctx) => new Container(
            child: Icon(Icons.place),
          ),
        ),
      );

      // also calculate zoom
      bounds = LatLngBounds.fromPoints(
          [currentLocation, this.widget.destinationMarker]);
    } else {
      bounds = LatLngBounds.fromPoints([currentLocation]);
    }
    mapController.onReady.then((result) {
      if (bounds != null) {
        mapController.fitBounds(bounds);
      }
    });

    return Column(children: <Widget>[
      SizedBox(
          height: 120,
          width: 300,
          child: FlutterMap(
            options: new MapOptions(
              center: currentLocation,
              zoom: 13.0,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(markers: markerList),
            ],
            mapController: mapController,
          )),
      Text(this.widget.hospitalName == null ? "" : this.widget.hospitalName)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: getCurrentLocation(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return getNothingScreen("Getting location");
          return getFlutterMap(snapshot.data);
        });
  }
}
