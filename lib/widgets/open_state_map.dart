import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class OpenStateMap extends StatefulWidget {
  const OpenStateMap({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<OpenStateMap> createState() => _OpenStateMap();
}

class _OpenStateMap extends State<OpenStateMap> {
  final MapController _myMapController = MapController();
  final GlobalKey _mapKey = GlobalKey();
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use passed location if available, otherwise fetch current location
    if (widget.initialLocation != null) {
      _currentLocation = widget.initialLocation;
      _isLoading = false;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = const LatLng(40.7128, -74.0060); // Fallback to NYC
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _captureMapSnapshot() async {
    try {
      RenderRepaintBoundary boundary =
          _mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      Navigator.pop(context, image);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing snapshot: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Open State Map")),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _mapKey,
            child: FlutterMap(
              mapController: _myMapController,
              options: MapOptions(
                initialCenter:
                    _currentLocation ?? const LatLng(40.7128, -74.0060),
                initialZoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                onTap: (tapPosition, point) {},
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.flutter_open_state_map',
                ),
                CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin, color: Colors.red),
                    ),
                    markerSize: const Size(32, 32),
                    markerDirection: MarkerDirection.heading,
                  ),
                ),
              ],
            ),
          ),
          // Capture button at the bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _captureMapSnapshot,
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Map'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
