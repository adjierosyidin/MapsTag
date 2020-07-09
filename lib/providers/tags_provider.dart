import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maps_tags/api/network.dart';
import 'package:maps_tags/model/tags_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagsProvider extends ChangeNotifier {
  List<TagsModel> _data = [];

  List<TagsModel> get tags => _data;

  Future<List<TagsModel>> getTags() async {
    var res = await Network().getData('v1/tags');

    if (res.statusCode == 200) {
      var tag = json.decode(res.body)['data'].cast<Map<String, dynamic>>();
      _data = tag.map<TagsModel>((json) => TagsModel.fromJson(json)).toList();
      return _data;
    } else {
      throw Exception();
    }
  }

  Future<TagsModel> findTags(String id) async {
    return _data.firstWhere((i) => i.id == id, orElse: () => null);
  }
}
