import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_happy_place/widgets/open_state_map.dart';

class LocationInputWidget extends StatefulWidget {
  const LocationInputWidget({super.key});
  @override
  State<LocationInputWidget> createState() {
    return _LocationInputWidgetState();
  }
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  LatLng? _pickedLocation;
  ui.Image? _mapSnapshot;
  var _isGettingLocation = false;

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    setState(() {
      _isGettingLocation = true;
    });

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }
    }

    locationData = await location.getLocation();

    setState(() {
      _isGettingLocation = false;
      _pickedLocation = LatLng(locationData.latitude!, locationData.longitude!);
    });

    //* Navigate to map and get snapshot
    if (!mounted) return;
    final capturedImage = await Navigator.of(context).push<ui.Image>(
      MaterialPageRoute(
        builder: (ctx) => OpenStateMap(initialLocation: _pickedLocation),
      ),
    );

    if (capturedImage != null) {
      setState(() {
        _mapSnapshot = capturedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = const Text(
      "No location chosen!",
      textAlign: TextAlign.center,
    );

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    } else if (_mapSnapshot != null) {
      previewContent = ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: RawImage(
          image: _mapSnapshot,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: previewContent,
        ),
        const SizedBox(height: 4),
        Card(
          child: TextButton.icon(
            onPressed: _isGettingLocation ? null : _getCurrentLocation,
            icon: const Icon(Icons.location_on),
            label: const Text("Get Current Location & Capture Map"),
          ),
        ),
      ],
    );
  }
}
