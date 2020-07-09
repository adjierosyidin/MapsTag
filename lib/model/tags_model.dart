class TagsModel {
  String id;
  String name;
  String address;
  String latitude;
  String longitude;
  String description;
  int active;
  String tag_color;
  List image;

  TagsModel(
      {this.id,
      this.name,
      this.address,
      this.latitude,
      this.longitude,
      this.description,
      this.active,
      this.tag_color,
      this.image});

  factory TagsModel.fromJson(Map<String, dynamic> json) => TagsModel(
        id: json['id'].toString(),
        name: json['name'],
        address: json['address'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        description: json['description'],
        active: json['active'],
        tag_color: json['tag_color'],
        image: json['img'],
      );
}
