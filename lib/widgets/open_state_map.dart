import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
  double _currentZoom = 13.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isSearching = false;
  Timer? _debounce;
  Timer? _singleTapTimer;
  List<Marker> _searchMarkers = [];

  @override
  void initState() {
    super.initState();
    //* <--- Use passed location if available, otherwise fetch current location --->
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
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location required'),
            content: const Text(
              'Please enable location permission in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        return;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = const LatLng(40.7128, -74.0060);
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
      final mapContext = _mapKey.currentContext;
      if (mapContext == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Map not available to capture')),
          );
        }
        return;
      }

      final renderObject = mapContext.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to capture map snapshot')),
          );
        }
        return;
      }

      final ui.Image image = await renderObject.toImage(pixelRatio: 3.0);

      if (!mounted) return;

      Navigator.of(context).pop(image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing snapshot: $e')),
        );
      }
    }
  }

  Future<void> _goToCurrentLocation() async {
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
        if (!mounted) return;

        //* <--- show a dialog and optionally open app settings --->
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location required'),
            content: const Text(
              'Please enable location permission in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Geolocator.openAppSettings();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        return;
      }

      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (!mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = latLng;
        _searchMarkers = [
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        ];
      });

      _myMapController.move(latLng, 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting current location: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _singleTapTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
    );

    try {
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'flutter_happy_place/1.0'},
      );

      if (res.statusCode != 200) throw 'HTTP ${res.statusCode}';
      final List data = json.decode(res.body) as List;

      if (mounted) {
        setState(() {
          _searchSuggestions = data.cast<Map<String, dynamic>>();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocations(value);
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    final lat = double.parse(location['lat'] as String);
    final lon = double.parse(location['lon'] as String);
    final latLng = LatLng(lat, lon);

    setState(() {
      _currentLocation = latLng;
      _searchSuggestions = [];
      _searchMarkers = [
        Marker(
          point: latLng,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ];
    });

    _myMapController.move(latLng, 15.0);
    _searchFocusNode.unfocus();
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
                initialZoom: _currentZoom,
                minZoom: 2.0,
                maxZoom: 20.0,
                onPositionChanged: (position, _) {
                  //* <--- keep track of current zoom so we can increment on double-tap --->
                  _currentZoom = position.zoom;
                },
                onTap: (tapPosition, point) {
                  //* <--- Distinguish single-tap (place marker) from double-tap (zoom in). --->
                  if (_singleTapTimer?.isActive ?? false) {
                    _singleTapTimer!.cancel();
                    final newZoom = (_currentZoom + 1).clamp(3.0, 18.0);
                    _myMapController.move(point, newZoom);
                    _currentZoom = newZoom;
                  } else {
                    //* <--- start timer to commit single-tap after short delay --->
                    _singleTapTimer = Timer(
                      const Duration(milliseconds: 200),
                      () {
                        if (!mounted) return;
                        setState(() {
                          _currentLocation = point;
                          _searchSuggestions = [];
                          _searchMarkers = [
                            Marker(
                              point: point,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ];
                        });
                        _searchFocusNode.unfocus();
                      },
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.flutter_open_state_map',
                ),
                if (_searchMarkers.isNotEmpty)
                  MarkerLayer(markers: _searchMarkers),
              ],
            ),
          ),

          //* <--- Search bar --->
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchSuggestions = [];
                                  _searchMarkers = [];
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (_searchSuggestions.isNotEmpty && !_isSearching)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _searchSuggestions[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on),
                            title: Text(
                              suggestion['display_name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            onTap: () => _selectLocation(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          //* <--- Capture button --->
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: _captureMapSnapshot,
                heroTag: 'captureFab',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Map'),
              ),
            ),
          ),

          //*<--- Recenter (current location) button in bottom-right --->
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'recenterFab',
              onPressed: _goToCurrentLocation,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
