import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_tags/api/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyMap extends StatefulWidget {
  @override
  State<MyMap> createState() => MyMapSampleState();
}

final Map<String, Marker> _markers = {};

class MyMapSampleState extends State<MyMap> {
  static LatLng _initialPosition;

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

  _getIcon(String color) async {
    var pinColor = color;
    var iconurl =
        "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" +
            pinColor;
    /* var dataBytes;
    var request = await http.get(iconurl);
    var bytes = await request.bodyBytes;

    setState(() {
      dataBytes = bytes;
    }); */

    final int targetWidth = 60;
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(iconurl);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    final markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }

  _onMapCreated(GoogleMapController controller) async {
    final mapTag = await getTags();
    /* print(mapTag); */

    _markers.clear();

    for (final tag in mapTag['data']) {
      String color = tag['tag_color'].toString();
      final marker = Marker(
        markerId: MarkerId(tag['name']),
        icon: await _getIcon(color),
        position: LatLng(
            double.parse(tag['latitude']), double.parse(tag['longitude'])),
        infoWindow: InfoWindow(
          title: tag['name'],
          snippet: tag['address'],
        ),
      );
      _markers[tag['name']] = marker;
    }

    setState(() {});
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
      /* final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker; */
    });
  }
}
