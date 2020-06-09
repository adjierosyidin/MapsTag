import 'package:flutter/material.dart';
import 'package:maps_tags/auth/login_register.dart';
import 'package:maps_tags/maps.dart';
import 'package:maps_tags/navigation_drawer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginRegister(),
    );
  }
}
