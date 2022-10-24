// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:radio/model/Stations.dart';
import 'package:radio/extensions/HexColor.dart';

import 'dart:io' show Platform;

import 'dart:async';
import 'package:flutter/services.dart';

import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const RadioHome(),
    );
  }
}

class RadioHome extends StatefulWidget {
  const RadioHome({super.key});

  @override
  State<RadioHome> createState() => _RadioHomeState();
}

class _RadioHomeState extends State<RadioHome> {
  final String appTitle = "Radio";
  late Future<Stations> futureStations;
  static const platformPlayStation = MethodChannel('orllewin.radio/play');
  final player = AudioPlayer();

  Future<Stations> fetchStations() async {
    final response = await http.get(Uri.https('orllewin.uk', 'stations.json'));

    if (response.statusCode == 200) {
      return Stations.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load stations');
    }
  }

  void playStation(String streamUrl) async {
    if (Platform.isMacOS) {
      //todo - play in Flutter with Dart player
      if (player.playing) {
        player.stop();
      }
      await player.setUrl(streamUrl);
      player.play();
    } else if (Platform.isAndroid) {
      final int result = await platformPlayStation.invokeMethod('playStation', streamUrl);
      print("Play result: $result");
    }
  }

  @override
  void initState() {
    super.initState();
    futureStations = fetchStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.dark),
          centerTitle: false,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<Stations>(
                  future: futureStations,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GridView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: true,
                          padding: const EdgeInsets.all(20),
                          itemCount: snapshot.data!.stations?.length,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                playStation("${snapshot.data!.stations?[index].streamUrl}");
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  color: HexColor(snapshot.data!.stations?[index].colour ?? "#cdcdcd"),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: NetworkImage(snapshot.data!.stations?[index].logoUrl ?? ""), fit: BoxFit.fill),
                                        ),
                                      ),
                                      // Text(snapshot.data!.stations?[index].title ??
                                      //     "Unknown")
                                    ],
                                  ),
                                ),
                              )));
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    return const CircularProgressIndicator();
                  })
            ],
          ),
        ));
  }
}
