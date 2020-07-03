import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  final String _url = 'http://192.168.5.40/locationtags/public/api/';
  var token, myToken;

  getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    return '$token';
  }

  authData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders());
  }

  storeDataTag(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    var uri = Uri.parse(fullUrl);
    var request = new http.MultipartRequest("POST", uri);

    request.headers.addAll({
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': myToken
    });
  }

  authDataTag(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    token = await getToken();
    var auth = 'Bearer $token';
    var token2 = auth.replaceAll(new RegExp('"'), '');
    print(token2);
    /* Dio dio = new Dio();

    dio.options.headers['Authorization'] = token2;
    dio.options.headers['Accept'] = "application/json";
    dio.options.headers["Content-Type"] = "application/json"; */

    return await http.post(fullUrl, body: jsonEncode(data), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token2
    });
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    token = await getToken();
    var auth = 'Bearer $token';
    var token2 = auth.replaceAll(new RegExp('"'), '');
    myToken = token2;
    /* print(token2); */
    return await http.get(fullUrl, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token2
    });
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };
}
