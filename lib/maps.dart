import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_tags/api/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMap extends StatefulWidget {
  @override
  State<MyMap> createState() => MyMapSampleState();
}

final Map<String, Marker> _markers = {};

class MyMapSampleState extends State<MyMap> {
  static LatLng _initialPosition;
  var tagData;

  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  _onMapCreated(GoogleMapController controller) async {
    final mapTag = await getTags();
    /* print(mapTag); */
    setState(() {
      _markers.clear();
      for (final tag in mapTag['data']) {
        final marker = Marker(
          markerId: MarkerId(tag['name']),
          position: LatLng(
              double.parse(tag['latitude']), double.parse(tag['longitude'])),
          infoWindow: InfoWindow(
            title: tag['name'],
            snippet: tag['address'],
          ),
        );
        _markers[tag['name']] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      body: _initialPosition == null
          ? Container(
              child: Center(
                child: Text(
                  'loading map..',
                  style: TextStyle(
                      fontFamily: 'Avenir-Medium', color: Colors.grey[400]),
                ),
              ),
            )
          : Container(
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    scrollGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    myLocationEnabled: true,
                    rotateGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      /* ? LatLng(40.688841, -74.044015)
                          : _initialPosition, */
                      zoom: 11,
                    ),
                    markers: _markers.values.toSet(),
                  ),
                ],
              ),
            ),
    );
  }

  _loadTags() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var tagJson = localStorage.getString('tags');
    var tag = json.decode(tagJson);
    setState(() {
      tagData = tag;
    });
  }

  getTags() async {
    var res = await Network().getData('v1/tags');
    var body = json.decode(res.body);
    /* print(res.statusCode); */
    if (res.statusCode == 200) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('tags', json.encode(body));
      var tagJson = localStorage.getString('tags');
      var tag = json.decode(tagJson);
      return tag;
    } else {
      _showMsg("Data Tags Gagal dimuat");
    }
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _initialPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      /* _markers.clear(); */
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }
}
