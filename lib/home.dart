import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maps_tags/auth/login_register.dart';
import 'package:maps_tags/api/network.dart';
import 'package:maps_tags/input_tag.dart';
import 'package:maps_tags/maps.dart';
import 'package:maps_tags/auth/logout.dart';
import 'package:maps_tags/drawer_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var userData;
  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    setState(() {
      userData = user;
    });
  }

  int _selectionIndex = 0;
  final drawerItems = [
    DrawerItem("Home", Icons.home),
    DrawerItem("Input Data", Icons.input),
    DrawerItem("Logout", Icons.exit_to_app),
  ];

  _getDrawerItemScreen(int pos) {
    switch (pos) {
      case 1:
        return InputTag();
      case 2:
        return Logout();
      default:
        return MyMap();
    }
  }

  _onSelectItem(int index) {
    setState(() {
      _selectionIndex = index;
      _getDrawerItemScreen(_selectionIndex);
    });
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _getDrawerItemScreen(_selectionIndex),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(
          d.title,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        ),
        selected: i == _selectionIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Maps Tag'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: new CircleAvatar(
                radius: 50.0,
                backgroundColor: const Color(0xFF778899),
                backgroundImage:
                    NetworkImage("http://tineye.com/images/widgets/mona.jpg"),
              ),
              accountName: Text(
                userData != null ? 'Hi, ' + '${userData['name']}' : 'Hi, ' + '',
              ),
              accountEmail: Text(
                userData != null ? '${userData['email']}' : '',
              ),
            ),
            Column(
              children: drawerOptions,
            ),
          ],
        ),
      ),
      body: _getDrawerItemScreen(_selectionIndex),
    );
  }
}
