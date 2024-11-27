import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// this page is opened when you want to view a map
class MapPage extends StatelessWidget {
  final String title;
  final Function(LatLng)? onMapTap;
  final double? latitude;
  final double? longitude;

  const MapPage({
    super.key,
    required this.title,
    this.onMapTap,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude ?? 37.7749, longitude ?? -122.4194),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('workoutLocation'),
            position: LatLng(latitude ?? 37.7749, longitude ?? -122.4194),
            infoWindow: const InfoWindow(title: 'Workout Location'),
          ),
        },
        onTap: onMapTap,
      ),
    );
  }
}
