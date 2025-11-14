import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_happy_place/widgets/sort_button.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';
import 'package:flutter_happy_place/widgets/search_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() {
    return _PlacesScreenState();
  }
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late Future<void> _placesFuture;
  SortOption _sortOption = SortOption.oldestFirst;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showSearchOverlay() {
    setState(() => _isSearching = true);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return SearchOverlay(
            allPlaces: ref.read(userPlacesProvider),
            onDismiss: () {
              Navigator.of(context).pop();
              setState(() => _isSearching = false);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Happy Places"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _showSearchOverlay,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 24,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search happy places!',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                //* <-- Use SortButton widget -->
                SortButton(
                  buttonSize: 24,
                  value: _sortOption,
                  onSelected: (selected) =>
                      setState(() => _sortOption = selected),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        
            //* <-- apply sorting -->
            List<Place> placesForDisplay = List<Place>.of(userPlaces);
            switch (_sortOption) {
              case SortOption.oldestFirst:
                break;
              case SortOption.newestFirst:
                placesForDisplay = placesForDisplay.reversed.toList();
                break;
              case SortOption.alphabetical:
                placesForDisplay.sort(
                  (a, b) =>
                      a.title.toLowerCase().compareTo(b.title.toLowerCase()),
                );
                break;
              case SortOption.reverseAlphabetical:
                placesForDisplay.sort(
                  (a, b) =>
                      b.title.toLowerCase().compareTo(a.title.toLowerCase()),
                );
                break;
            }
        
            return PlacesList(
              placesList: placesForDisplay,
              onDelete: (id) =>
                  ref.read(userPlacesProvider.notifier).deletePlace(id),
              onToggleFavorite: (id, isFav) => ref
                  .read(userPlacesProvider.notifier)
                  .toggleFavorite(id, isFav),
            );
          },
        ),
      ),
    );
  }
}
