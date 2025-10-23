import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationInputWidget extends StatefulWidget {
  const LocationInputWidget({super.key});

  @override
  State<LocationInputWidget> createState() {
    return _LocationInputWidgetState();
  }
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  Location? _pickedLocation;
  var _isGettingLocation = false;

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
    locationData = await location.getLocation();
    setState(() {
      _isGettingLocation = false;
    });
    print(locationData.latitude);
    print(locationData.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      "No location chosen!",
      textAlign: TextAlign.center,
    );

    if (_isGettingLocation == true) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 3),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text("Current Location"),
              ),
            ),
            Card(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_rounded),
                label: const Text("Pick Location"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
