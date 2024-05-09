// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unused_import, unused_local_variable

import 'dart:js_interop';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import "package:latlng_picker/latlng_picker.dart";
import 'package:firstproject/otpscreen.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required String phoneNumber, required String fullName, required String title}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

typedef MosqueTuple = ({
  LatLng location,
  String name,
  String id,
});

class _HomePageState extends State<HomePage> {
  List<MosqueTuple> mosques = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var dataQ =
        await FirebaseFirestore.instance.collection("mosques").limit(50).get();
    for (var item in dataQ.docs) {
      var data = item.data();
      var point = (data["location"] as GeoPoint);
      mosques.add(
        (
          id: item.id,
          name: data["name"],
          location: LatLng(point.latitude, point.longitude)
        ),
      );
    }

    setState(() {});
  }

  Future<void> _create() async {
    var latLng = await showLatLngPickerDialog(context: context);
    if (latLng?.isNotEmpty == true) {
      var item = await FirebaseFirestore.instance.collection("mosques").add({
        "name": "data.name",
        "location": GeoPoint(
          latLng!.first.latitude,
          latLng!.first.longitude,
        )
      });

      mosques.add((id: item.id, name: "data.name", location: latLng!.first));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Users = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _create,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(51.509364, -0.128928),
          initialZoom: 9.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              for (var item in mosques)
                Marker(
                  point: item.location,
                  width: 80,
                  height: 80,
                  child: IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(item.name),
                                content: Text(
                                    "If the [style] argument is null, the text will use the style from the closest enclosing [DefaultTextStyle]."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        // logic

                                        Navigator.of(context).pop();
                                      },
                                      child: Text("تسجيل"))
                                ],
                              );
                            });
                      },
                      icon: Icon(Icons.gps_fixed)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
