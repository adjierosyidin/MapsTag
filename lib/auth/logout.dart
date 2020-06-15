import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:maps_tags/api/network.dart';
import 'package:maps_tags/auth/login_register.dart';

class Logout extends StatefulWidget {
  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  void _logout() async {
    var res = await Network().getData('logout');
    var body = json.decode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      localStorage.remove('tags');
    }
  }

  @override
  void initState() {
    _logout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: LoginRegister(),
    );
  }
}
