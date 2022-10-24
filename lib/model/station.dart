class Station {
  String? title;
  String? website;
  String? streamUrl;
  String? logoUrl;
  String? colour;

  Station(
      {this.title, this.website, this.streamUrl, this.logoUrl, this.colour});

  Station.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    website = json['website'];
    streamUrl = json['streamUrl'];
    logoUrl = json['logoUrl'];
    colour = json['colour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['website'] = website;
    data['streamUrl'] = streamUrl;
    data['logoUrl'] = logoUrl;
    data['colour'] = colour;
    return data;
  }
}
