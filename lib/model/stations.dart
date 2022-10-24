import 'station.dart';

class Stations {
  List<Station>? stations;

  Stations({this.stations});

  Stations.fromJson(Map<String, dynamic> json) {
    if (json['stations'] != null) {
      stations = <Station>[];
      json['stations'].forEach((v) {
        stations!.add(Station.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stations != null) {
      data['stations'] = stations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
