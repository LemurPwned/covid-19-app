import 'dart:async';
import 'dart:convert';

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
      this.widget.destinationMarker =
          await findNearestHospital(LatLng(pos.latitude, pos.longitude));
    } 

    return pos;
  }

  Future<LatLng> findNearestHospital(LatLng currentLoc) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/full_data.json");
    final jsonResult = json.decode(data);

    var smallestDist = 100000000.0;
    LatLng closest;
    for (final key in jsonResult.values) {
      var hospital = LatLng(key['latitude'], key['longitude']);
      final distance = Distance();
      var km = distance.as(LengthUnit.Kilometer, currentLoc, hospital);
      if (km < smallestDist) {
        smallestDist = km;
        closest = hospital;
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

    return FlutterMap(
      options: new MapOptions(
        center: currentLocation,
        zoom: 13.0,
      ),
      layers: [
        new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        new MarkerLayerOptions(markers: markerList),
      ],
      mapController: mapController,
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
