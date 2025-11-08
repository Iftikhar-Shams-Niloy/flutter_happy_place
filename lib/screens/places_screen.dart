import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/screens/add_place_screen.dart';
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
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: IconButton(
                    icon: Image(
                      image: AssetImage("assets/icons/sort.png"),
                      color: Theme.of(context).colorScheme.secondary,
                      height: 24,
                      width: 24,
                    ),
                    onPressed: () {
                    },
                  ),
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

              // apply search filter (title or details)
              final query = _searchQuery;
              final filtered = query.isEmpty
                  ? userPlaces
                  : userPlaces
                        .where(
                          (p) =>
                              p.title.toLowerCase().contains(query) ||
                              p.details.toLowerCase().contains(query),
                        )
                        .toList();

              return PlacesList(
                placesList: filtered,
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
