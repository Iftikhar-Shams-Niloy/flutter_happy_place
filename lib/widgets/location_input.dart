import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_happy_place/widgets/open_state_map.dart';
import '../utils/file_utils.dart';

class LocationInputWidget extends StatefulWidget {
  const LocationInputWidget({
    super.key,
    this.onMapSnapshotPicked,
    this.initialMapSnapshot,
  });

  // Callback when a map snapshot file is available (PNG file)
  final void Function(File? mapSnapshot)? onMapSnapshotPicked;
  // Optional initial snapshot file to preview (edit mode)
  final File? initialMapSnapshot;
  
  @override
  State<LocationInputWidget> createState() {
    return _LocationInputWidgetState();
  }
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  LatLng? _pickedLocation;
  File? _mapSnapshotFile;
  var _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMapSnapshot != null) {
      _mapSnapshotFile = widget.initialMapSnapshot;
    }
  }

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
      // convert ui.Image to PNG bytes and save to a temp file
      final byteData = await capturedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final tempDir = Directory.systemTemp;
        final file = await File(
          '${tempDir.path}/map_snapshot_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await file.writeAsBytes(bytes);
        if (!mounted) return;
        setState(() {
          _mapSnapshotFile = file;
        });
        // notify parent widget (e.g., AddPlaceScreen) about the saved file
        widget.onMapSnapshotPicked?.call(file);
      } else {
        if (!mounted) return;
        setState(() {
          _mapSnapshotFile = null;
        });
        widget.onMapSnapshotPicked?.call(null);
      }
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
    } else if (isValidImageFile(_mapSnapshotFile)) {
      previewContent = ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Image.file(
          _mapSnapshotFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stack) => Center(
            child: Icon(Icons.broken_image, size: 50),
          ),
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
            label: const Text("Pickup Location From Map"),
          ),
        ),
      ],
    );
  }
}
