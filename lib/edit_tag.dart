import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:maps_tags/mytags.dart';
import 'package:maps_tags/providers/tags_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_tags/api/network.dart';
import 'package:maps_tags/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTag extends StatefulWidget {
  final String id;
  EditTag({this.id});

  @override
  _EditTagState createState() => _EditTagState();
}

class _EditTagState extends State<EditTag> {
  final _formKey = new GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  /* TextEditingController image = TextEditingController(); */
  TextEditingController address = TextEditingController();
  TextEditingController lat = TextEditingController();
  TextEditingController lng = TextEditingController();
  /* TextEditingController active = TextEditingController(); */

  final Map<String, Marker> _markers = {};

  String _name;
  String _description;
  PickedFile _image;
  String imageURL = 'http://192.168.5.40/locationtags/public/storage/1/a1.png';
  List img;
  String _address;
  double _lat = -7.939794;
  double _lng = 112.621231;

  bool _isLoading = false;

  final picker = ImagePicker();
  static LatLng _initialPosition;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<TagsProvider>(this.context, listen: false)
          .findTags(widget.id)
          .then((response) {
        setState(() {
          name.text = response.name;
          description.text = response.description;
          address.text = response.address;
          lat.text = response.latitude;
          lng.text = response.longitude;
          /* act = response.active; */
          img = response.image;
          imageURL = img[0]['url'];
          /* if (act == 1) {
            activeValue = true;
          } else {
            activeValue = false;
          } */
          _lat = double.parse(response.latitude);
          _lng = double.parse(response.longitude);
          _getLocTag();
        });
      });
    });

    super.initState();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            _showFormInputTag(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showFormInputTag() {
    return new Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showNameInput(),
              showDescriptionInput(),
              showImage(),
              showImageInput(),
              showAddressInput(),
              showLatInput(),
              showLngInput(),
              showMap(),
              /* showActiveInput(), */
              showPrimaryButton(),
              showBackButton(),
            ],
          ),
        ));
  }

  Widget showBackButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.grey,
            child: new Text('Back',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              Navigator.of(this.context).pop();
            },
          ),
        ));
  }

  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new TextFormField(
        controller: name,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Name',
            icon: new Icon(
              Icons.business,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Name can\'t be empty' : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget showDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: description,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Description',
            icon: new Icon(
              Icons.description,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Description can\'t be empty' : null,
        onSaved: (value) => _description = value.trim(),
      ),
    );
  }

  File image;

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxWidth: 756, imageQuality: 80);

    setState(() {
      _image = pickedFile;
      image = File(_image.path);
    });

    Navigator.pop(this.context);
  }

  Future getImageCamera() async {
    Navigator.pop(this.context);
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxWidth: 756, imageQuality: 80);
    setState(() {
      _image = pickedFile;
      image = File(_image.path);
      /* var img = imge.decodeImage(new File(image.path).readAsBytesSync());

      var thumbnail = imge.copyResize(img, width: 512);

      File(image.path).writeAsBytesSync(imge.encodePng(thumbnail)); */
    });
  }

  Widget showImage() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new Center(
        child: _image == null
            ? Image.network(imageURL)
            : Image.file(
                File(_image.path),
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    print('Image Picker Modal Called');
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Camera'),
                  onPressed: () {
                    getImageCamera();
                  },
                ),
                FlatButton(
                  textColor: flatButtonColor,
                  child: Text('Use Gallery'),
                  onPressed: () {
                    getImageGallery();
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget showImageInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
      child: OutlineButton(
        onPressed: () => _openImagePickerModal(this.context),
        borderSide:
            BorderSide(color: Theme.of(this.context).accentColor, width: 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.camera_alt),
            SizedBox(
              width: 5.0,
            ),
            Text('Change Image'),
          ],
        ),
      ),
    );
  }

  /* Widget showImageGalleryInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new FlatButton(
        color: Colors.grey,
        child: Text(
          "Tap here to upload image",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          getImageGallery();
        },
      ),
    );
  } */

  Widget showAddressInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        controller: address,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Address',
            icon: new Icon(
              Icons.place,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Address can\'t be empty' : null,
        onSaved: (value) => _address = value.trim(),
      ),
    );
  }

  Widget showLatInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        enabled: false,
        controller: lat,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Latitude',
            icon: new Icon(
              Icons.map,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Latitude can\'t be empty' : null,
        /* onSaved: (value) => _name = value.trim(), */
      ),
    );
  }

  Widget showLngInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        enabled: false,
        controller: lng,
        maxLines: 1,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Longitude',
            icon: new Icon(
              Icons.map,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Longitude can\'t be empty' : null,
        /* onSaved: (value) => _name = value.trim(), */
      ),
    );
  }

  void _getLocTag() async {
    setState(() {
      _initialPosition = LatLng(_lat, _lng);

      final marker = Marker(
        markerId: MarkerId("tag"),
        position: LatLng(_lat, _lng),
        infoWindow: InfoWindow(title: 'Your Tag'),
      );
      _markers["Your Tag"] = marker;
    });
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _initialPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      lat.text = currentLocation.latitude.toString();
      lng.text = currentLocation.longitude.toString();
      /* _markers.clear(); */
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markers["Current Location"] = marker;
    });
  }

  Widget mapView() {
    if (_initialPosition == null) {
      _initialPosition = LatLng(_lat, _lng);
    } else {
      return GoogleMap(
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          /* ? LatLng(40.688841, -74.044015)
                            : _initialPosition, */
          zoom: 11,
        ),
        gestureRecognizers: Set()
          ..add(
              Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())),
        markers: _markers.values.toSet(),
      );
    }
    setState(() {
      mapView();
    });
  }

  Widget showMap() {
    return Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: mapView());
  }

  /* var act;
  bool activeValue = false;

  Widget showActiveInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: new CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text('Active'),
          value: activeValue,
          activeColor: Colors.grey,
          onChanged: (bool newValue) {
            setState(() {
              activeValue = newValue;
            });
          }),
    );
  } */

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            child: new Text('Update Tag',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _addTags();
              }
            },
          ),
        ));
  }

  var userData;

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    setState(() {
      userData = user;
    });
  }

  void _addTags() async {
    setState(() {
      _isLoading = true;
    });

    var token = await Network().getToken();
    var auth = 'Bearer $token';
    var token2 = auth.replaceAll(new RegExp('"'), '');

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/json",
      "Authorization": token2
    };

    var postUri = Uri.parse(
        "http://192.168.5.40/locationtags/public/api/v1/tags/" + widget.id);

    var request = new http.MultipartRequest("POST", postUri);

    /* if (activeValue) {
      act = 1;
    } else {
      act = 0;
    } */

    request.fields['_method'] = 'PUT';
    request.fields['name'] = name.text;
    request.fields['description'] = description.text;
    request.fields['address'] = address.text;
    request.fields['latitude'] = lat.text;
    request.fields['longitude'] = lng.text;
    request.fields['active'] = '1';
    /* request.fields['tag_color'] = userData['tag_color'].toString();
    request.fields['created_by_id'] = userData['id'].toString(); */

    if (image != null) {
      var stream =
          new http.ByteStream(DelegatingStream.typed(image.openRead()));
      var length = await image.length();
      var multipartFile = new http.MultipartFile('img', stream, length,
          filename: basename(image.path));
      request.files.add(multipartFile);
    }

    request.headers.addAll(headers);

    http.StreamedResponse res = await request.send();
    var resJson;

    /* var res = await Network().authDataTag(data, 'v1/tags'); */
    var body = res.stream.transform(utf8.decoder).listen((value) {
      resJson = value;
    });

    if (res.statusCode == 202) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('tags', json.encode(resJson));
      Navigator.of(this.context)
          .push(MaterialPageRoute(builder: (context) => MyTagsApp()));
    } else {
      _showMsg('Tags Gagal Diedit');
    }

    print(res.statusCode);

    setState(() {
      _isLoading = false;
    });
  }
}
