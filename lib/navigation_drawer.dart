import 'package:flutter/material.dart';
import 'package:maps_tags/maps.dart';
import 'package:maps_tags/drawer_item.dart';

class NavigationDrawer extends StatefulWidget {
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  int _selectionIndex = 0;
  final drawerItems = [
    DrawerItem("Home", Icons.home),
    DrawerItem("Input Data", Icons.input),
    DrawerItem("Logout", Icons.exit_to_app),
  ];

  _getDrawerItemScreen(int pos) {
    switch (pos) {
      case 1:
        return MyMap();
      case 2:
        return NavigationDrawer();
      default:
        return NavigationDrawer();
    }
  }

  _onSelectItem(int index) {
    setState(() {
      _selectionIndex = index;
      _getDrawerItemScreen(_selectionIndex);
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _getDrawerItemScreen(_selectionIndex),
      ),
    );
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
              accountName: Text('Hi, Adjie Rosyidin'),
              accountEmail: Text('adjierosyidin48@gmail.com'),
            ),
            Column(
              children: drawerOptions,
            ),
          ],
        ),
      ),
      body: MyMap(),
    );
  }
}
