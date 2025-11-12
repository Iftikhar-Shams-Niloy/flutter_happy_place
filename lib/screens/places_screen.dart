import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_happy_place/widgets/sort_button.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';
import 'package:flutter_happy_place/widgets/searchbar.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Current sorting selection for the places list
  SortOption _sortOption = SortOption.oldestFirst;

  @override
  void initState() {
    super.initState();
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  child: AppSearchBar(
                    controller: _searchController,
                    query: _searchQuery,
                    hintText: 'Search happy places!',
                    onChanged: (v) => setState(() => _searchQuery = v),
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
        child: SafeArea(
          child: FutureBuilder(
            future: _placesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //* <-- apply search filter -->
              final query = _searchQuery.toLowerCase();
              final filtered = query.isEmpty
                  ? userPlaces.toList()
                  : userPlaces
                        .where(
                          (p) =>
                              p.title.toLowerCase().contains(query) ||
                              p.details.toLowerCase().contains(query),
                        )
                        .toList();

              List<Place> placesForDisplay = List<Place>.of(filtered);
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
      ),
    );
  }
}
