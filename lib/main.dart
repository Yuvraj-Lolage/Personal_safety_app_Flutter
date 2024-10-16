// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? _currentPosition;
  final double defaultLatitude = 40.7128; // Default latitude (New York)
  final double defaultLongitude = -74.0060; // Default longitude (New York)

  String _locationMessage = "Current location will appear here";
  final MapController _mapController =
      MapController(); // Create a MapController

  // Method to get the current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _locationMessage =
          'Lat: ${position.latitude}, Long: ${position.longitude}';

      // Center the map to the current location
      _mapController.move(
        latlong.LatLng(position.latitude, position.longitude),
        13.0, // Set the zoom level
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Safety Application',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Text(_locationMessage),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text("Get Current Location"),
          ),
          Container(
            height: 600,
            child: FlutterMap(
              mapController: _mapController, // Assign the controller
              options: MapOptions(
                  initialCenter: latlong.LatLng(
                    _currentPosition != null
                        ? _currentPosition!.latitude
                        : defaultLatitude,
                    _currentPosition != null
                        ? _currentPosition!.longitude
                        : defaultLongitude,
                  ),
                  initialZoom: 15.2,
                  keepAlive: true),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                  userAgentPackageName: 'com.personalSafety.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: (_currentPosition != null
                          ? latlong.LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude)
                          : latlong.LatLng(defaultLatitude, defaultLongitude)),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: (_currentPosition != null
                          ? latlong.LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude)
                          : latlong.LatLng(defaultLatitude, defaultLongitude)),
                      radius: 2000,
                      color: const Color.fromARGB(62, 33, 149, 243),
                      borderColor: const Color.fromARGB(159, 18, 79, 128),
                      borderStrokeWidth: 3,
                      useRadiusInMeter: true,
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse(
                          'https://openstreetmap.org/copyright')), // (external)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void launchUrl(Uri parse) {
    // Define your launch logic here, if necessary
  }
}
