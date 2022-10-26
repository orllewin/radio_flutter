// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:radio/model/Stations.dart';
import 'package:radio/model/station.dart';
import 'package:radio/extensions/HexColor.dart';
import 'package:dart_when/when.dart';

import 'dart:io' show Platform;

import 'dart:async';
import 'package:flutter/services.dart';

import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Future<Stations?> futureStations;
  static const platformPlayStation = MethodChannel('orllewin.radio/play');
  final player = AudioPlayer();
  Station? nowPlaying;

  Future<Stations?> _fetchStations() async {
    final response = await http.get(Uri.https('orllewin.uk', 'stations.json'));

    Stations? stations = when(response.statusCode, {
      200: Stations.fromJson(jsonDecode(response.body)), //
      Else: () => snack("Error loading stations feed")
    });

    return stations;
  }

  Future<void> _openBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      snack("Can't open a browser on this platform");
    }
  }

  void snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void playStation(Station station) async {
    if (Platform.isMacOS) {
      if (player.playing) {
        player.stop();
      }
      player.setUrl(station.streamUrl ?? "");
      player.setVolume(1.0);
      player.play();

      setState(() {
        nowPlaying = station;
      });
    } else if (Platform.isAndroid) {
      final int result = await platformPlayStation.invokeMethod('playStation', station.streamUrl ?? "");
      print("Play result: $result");
    }
  }

  Icon speakerIcon() {
    if (player.volume != 0.0) {
      return const Icon(
        Icons.volume_off,
        size: 26.0,
      );
    } else {
      return const Icon(
        Icons.volume_up,
        size: 26.0,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    futureStations = _fetchStations();
  }

  List<Widget>? _getMenuActions() {
    if (Platform.isMacOS && player.playing && nowPlaying != null) {
      return <Widget>[
        Padding(padding: const EdgeInsets.only(right: 20.0, top: 20.0), child: Text(nowPlaying?.title ?? "")),
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
                onTap: () {
                  player.stop();
                  setState(() {
                    nowPlaying = null;
                  });
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.stop_circle,
                    size: 26.0,
                  ),
                ))),
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
                onTap: () {
                  if (player.volume == 0.0) {
                    player.setVolume(1.0);
                  } else {
                    player.setVolume(0.0);
                  }
                  setState(() {});
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: speakerIcon(),
                ))),
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
                onTap: () {
                  _openBrowser(nowPlaying?.website ?? "");
                },
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.link,
                    size: 26.0,
                  ),
                )))
      ];
    } else {
      return <Widget>[];
    }
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
          actions: _getMenuActions(),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FutureBuilder<Stations?>(
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
                                Station? s = snapshot.data?.stations?[index];
                                if (s != null) {
                                  playStation(s);
                                }
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

                    //todo - improve this loading indicator
                    return const CircularProgressIndicator();
                  })
            ],
          ),
        ));
  }
}
