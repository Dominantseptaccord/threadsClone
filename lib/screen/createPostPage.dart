import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hatter/components/appBar.dart';
import 'package:hatter/database/post_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool _isPushed = false;
  final controllerPostController = TextEditingController();
  bool showMap = false;
  final post = PostService();
  late String lat;
  late String long;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();


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
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
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
                        onPressed: _pickImage,
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
                if (_selectedImage != null)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                    onTapDown: (_) => setState(() => _isPushed = true),
                    onTapUp: (_) async {
                      setState(() => _isPushed = false);
                      await Future.delayed(Duration(milliseconds: 200));

                      String? imageUrl;
                      if (_selectedImage != null) {
                        imageUrl = await _uploadImage(_selectedImage!);
                      }

                      post.addPost(
                        controllerPostController.text,
                        imageUrl: imageUrl,
                      );

                      controllerPostController.clear();
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    onTapCancel: () => setState(() => _isPushed = false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(_isPushed ? 20.0 : 25.0),
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: _isPushed ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(_isPushed ? 30.0 : 15.0),
                        boxShadow: _isPushed
                            ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 6),
                          )
                        ]
                            : [],
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Push',
                          style: TextStyle(
                            color: _isPushed ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
        )
    );
  }
}