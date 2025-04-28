import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hatter/components/appBar.dart';
import 'package:hatter/database/post_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CreatePostPage extends StatefulWidget {
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {

  final controllerPostController = TextEditingController();
  bool showMap = false;
  final post = PostService();
  late String lat;
  late String long;

  late GoogleMapController _mapController;
  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('location'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(
        title: 'San Andreas',
        snippet: 'Home',
      ),
    ),
  };

  void goToUralsk() async {
    List<Location> locations = await locationFromAddress('Uralsk');
    _mapController.animateCamera(
        CameraUpdate.newLatLng(
            LatLng(
              locations.first.latitude,
              locations.first.longitude,
            )
        )
    );
  }
  void goToSomewhere() async {
    List<Placemark> placemark = await placemarkFromCoordinates(51.1694, 71.4491);
    print(placemark.first.country);
    print(placemark.first.locality);
  }
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Position disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Denied OK.');
      }
    }
    return Geolocator.getCurrentPosition();
  }
  void _getCameraPosition(CameraPosition campos){
    print("cameraPosition: " + campos.target.toString());
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWall(context),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
              children: [
                TextField(
                  controller: controllerPostController,
                  decoration: InputDecoration(
                      hintText: 'Write something...',
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.person)
                  ),
                ),
                SizedBox(height: 8,),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(Icons.photo)
                    ),
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(Icons.mic_rounded)
                    ),
                    IconButton(
                        onPressed: () async {
                          try {
                            final pos = await getCurrentLocation();
                            lat = pos.latitude.toString();
                            long = pos.longitude.toString();
                            setState(() {
                              if (!showMap) {
                                showMap = true;
                              }
                              else {
                                showMap = false;
                              }
                            });
                          }
                          catch (e) {
                            print('Error');
                          }
                        },
                        icon: Icon(Icons.location_on)
                    ),
                  ],
                ),
                if(showMap)
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(lat), double.parse(long)),
                              zoom: 10,
                            ),
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            markers: markers,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            // we can move
                            rotateGesturesEnabled: true,
                            onMapCreated: (controller){
                              _mapController = controller;
                            },
                            onTap: (LatLng tapped) {
                              setState(() {
                                markers.add(
                                    Marker(
                                        markerId: MarkerId('New marker'),
                                        position: tapped,
                                        infoWindow: InfoWindow(
                                          title: 'New Marker',
                                          snippet: 'yes',
                                        )
                                    )
                                );
                              });
                            },
                            onCameraMove: _getCameraPosition
                          ),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 5,
                            child: Column(
                              children: [
                                FloatingActionButton(
                                  heroTag: 'Zoom_in', // Planning to add Animations
                                  mini: true,
                                  onPressed: (){
                                    _mapController.animateCamera(
                                      CameraUpdate.zoomIn(),
                                    );
                                  },
                                  child: Icon(Icons.zoom_in),
                                  backgroundColor: Colors.white,
                                ),
                                FloatingActionButton(
                                  heroTag: 'Zoom_out', // Planning to add Animations
                                  mini: true,
                                  onPressed: (){
                                    _mapController.animateCamera(
                                      CameraUpdate.zoomOut(),
                                    );
                                  },
                                  child: Icon(Icons.zoom_out),
                                  backgroundColor: Colors.white,
                                ),
                                Row(
                                  children: [
                                    FloatingActionButton(
                                      heroTag: true,
                                      mini: true,
                                      onPressed: () async {
                                        final pos = await getCurrentLocation();
                                        _mapController.animateCamera(
                                          CameraUpdate.newLatLng(
                                            LatLng(
                                                pos.latitude,
                                                pos.longitude
                                            ),
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.person),
                                    ),
                                    FloatingActionButton(
                                      heroTag: true,
                                      mini: true,
                                      onPressed: () async {
                                        goToUralsk();
                                      },
                                      child: Icon(Icons.accessibility_new_rounded),
                                    ),
                                    FloatingActionButton(
                                      heroTag: true,
                                      mini: true,
                                      onPressed: () async {
                                        goToSomewhere();
                                      },
                                      child: Icon(Icons.add_alert_sharp),
                                    )
                                  ],
                                )
                              ],
                            )
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(9.0),
                  child: GestureDetector(
                    onTap: () async {
                      post.addPost(controllerPostController.text);
                      controllerPostController.clear();
                    },
                    child: Container(
                      padding: EdgeInsets.all(25.0),
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      decoration
                          : BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                        child: Text(
                          'Push',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              ]),
        )
    );
  }
}