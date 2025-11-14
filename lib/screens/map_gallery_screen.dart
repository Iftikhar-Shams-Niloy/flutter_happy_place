import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/sort_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../utils/file_utils.dart';

class MapGalleryScreen extends ConsumerStatefulWidget {
  const MapGalleryScreen({super.key});

  @override
  ConsumerState<MapGalleryScreen> createState() => _MapGalleryScreenState();
}

class _MapGalleryScreenState extends ConsumerState<MapGalleryScreen> {
  late Future<void> _placesFuture;
  SortOption _sortOption = SortOption.oldestFirst;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  void _showMapDialog(BuildContext context, File mapSnapshot, String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                child: Image(
                  image: FileImage(mapSnapshot),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(userPlacesProvider);
    var mapsWithTitles = places
        .where((place) => isValidImageFile(place.mapSnapshot))
        .map((place) => {'map': place.mapSnapshot!, 'title': place.title})
        .toList();

    switch (_sortOption) {
      case SortOption.oldestFirst:
        break;
      case SortOption.newestFirst:
        mapsWithTitles = mapsWithTitles.reversed.toList();
        break;
      case SortOption.alphabetical:
        mapsWithTitles.sort(
          (a, b) => (a['title'] as String).toLowerCase().compareTo(
            (b['title'] as String).toLowerCase(),
          ),
        );
        break;
      case SortOption.reverseAlphabetical:
        mapsWithTitles.sort(
          (a, b) => (b['title'] as String).toLowerCase().compareTo(
            (a['title'] as String).toLowerCase(),
          ),
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Snapshots'),
        actions: [
          SortButton(
            buttonSize: 16,
            value: _sortOption,
            onSelected: (selected) => setState(() => _sortOption = selected),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (mapsWithTitles.isEmpty) {
            return const Center(
              child: Text('No map snapshots yet!'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: mapsWithTitles.length,
              itemBuilder: (context, index) {
                final item = mapsWithTitles[index];
                final mapSnapshot = item['map'] as File;
                final title = item['title'] as String;

                return GestureDetector(
                  onTap: () => _showMapDialog(context, mapSnapshot, title),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 6,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image(
                                image: FileImage(mapSnapshot),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black87,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
