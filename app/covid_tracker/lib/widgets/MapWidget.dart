import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:covid_tracker/globals.dart';

class MapWidget extends StatefulWidget {
  LatLng destinationMarker;

  MapWidget({this.destinationMarker});

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  // Krakow
  LatLng currentLocation = new LatLng(50.03, 19.56);
  Placemark currentPlace;
  Future<Position> position;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  Future<Position> getCurrentLocation() async {
    Position pos = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    List<Placemark> placemarks = await geolocator.placemarkFromPosition(pos);

    Placemark place = placemarks[0];
    print(
        "${place.locality}, ${place.postalCode}, ${place.country}, ${place.administrativeArea}");

    return pos;
  }

  @override
  void initState() {
    // get location

    super.initState();
  }

  Widget getFlutterMap(Position position) {
    currentLocation = new LatLng(position.latitude, position.longitude);
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
    }
    return FlutterMap(
      options: new MapOptions(
        center: currentLocation,
        zoom: 13.0,
      ),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        new MarkerLayerOptions(
          markers: markerList,
        ),
      ],
    );
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
