import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:maps_tags/api/network.dart';
import 'package:maps_tags/edit_tag.dart';
import 'package:maps_tags/model/tags_model.dart';
import 'package:provider/provider.dart';
import 'package:maps_tags/providers/tags_provider.dart';
import 'package:maps_tags/input_tag.dart';

class MyTagsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TagsProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyTags(),
      ),
    );
  }
}

class MyTags extends StatefulWidget {
  @override
  _MyTagsState createState() => _MyTagsState();
}

class _MyTagsState extends State<MyTags> {
  TextEditingController controller = new TextEditingController();

  Future<List<TagsModel>> getTags() async {
    var res = await Network().getData('v1/tags');

    if (res.statusCode == 200) {
      var tag = json.decode(res.body)['data'].cast<Map<String, dynamic>>();
      _tagDetails =
          tag.map<TagsModel>((json) => TagsModel.fromJson(json)).toList();
    } else {
      throw Exception();
    }
  }

  @override
  void initState() {
    super.initState();
    getTags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: RefreshIndicator(
        onRefresh: () =>
            Provider.of<TagsProvider>(context, listen: false).getTags(),
        color: Colors.blue,
        child: Container(
            margin: EdgeInsets.all(10),
            child: FutureBuilder(
                future:
                    Provider.of<TagsProvider>(context, listen: false).getTags(),
                builder: (context, snapshot) {
                  /* if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } */
                  return Consumer<TagsProvider>(builder: (context, data, _) {
                    return Column(children: <Widget>[
                      new Container(
                        child: new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Card(
                            child: new ListTile(
                              leading: new Icon(Icons.search),
                              title: new TextField(
                                controller: controller,
                                decoration: new InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none),
                                onChanged: onSearchTextChanged,
                              ),
                              trailing: new IconButton(
                                icon: new Icon(Icons.cancel),
                                onPressed: () {
                                  controller.clear();
                                  onSearchTextChanged('');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      new Expanded(
                        child: _searchResult.length != 0 ||
                                controller.text.isNotEmpty
                            ? new ListView.builder(
                                itemCount: _searchResult.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () {
                                      /* print(_searchResult[i].id); */
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditTag(
                                            id: _searchResult[i].id.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 8,
                                      child: ListTile(
                                        title: Text(
                                          _searchResult[i].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'Alamat: ${_searchResult[i].address}'),
                                        /* trailing: Text("\$${data.tags[i].description}"), */
                                      ),
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: data.tags.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () {
                                      /* print(data.tags[i].id); */
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditTag(
                                            id: data.tags[i].id.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 8,
                                      child: ListTile(
                                        title: Text(
                                          data.tags[i].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'Alamat: ${data.tags[i].address}'),
                                        /* trailing: Text("\$${data.tags[i].description}"), */
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ]);
                  });
                })),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Text('+'),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => InputTag()));
        },
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _tagDetails.forEach((tagDetail) {
      if (tagDetail.name.toLowerCase().contains(text.toLowerCase()) ||
          tagDetail.description.toLowerCase().contains(text.toLowerCase()) ||
          tagDetail.address.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(tagDetail);
    });

    setState(() {});
  }

  List<TagsModel> _searchResult = [];

  List<TagsModel> _tagDetails = [];
}
