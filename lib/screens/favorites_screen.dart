import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';
import 'package:flutter_happy_place/widgets/sort_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  SortOption _sortOption = SortOption.oldestFirst;

  @override
  Widget build(BuildContext context) {
    var places = ref
        .watch(userPlacesProvider)
        .where((p) => p.isFavorite)
        .toList();

    switch (_sortOption) {
      case SortOption.oldestFirst:
        break;
      case SortOption.newestFirst:
        places = places.reversed.toList();
        break;
      case SortOption.alphabetical:
        places.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.reverseAlphabetical:
        places.sort((a, b) =>
            b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Super Happy Places'),
        automaticallyImplyLeading: false,
        actions: places.isEmpty
            ? null
            : [
                SortButton(
                  buttonSize: 16,
                  value: _sortOption,
                  onSelected: (selected) =>
                      setState(() => _sortOption = selected),
                ),
                const SizedBox(width: 8),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: places.isEmpty
            ? const Center(
                child: Text('No favorites yet! Swipe right to add favorites.'),
              )
            : PlacesList(
                placesList: places,
                onDelete: (id) =>
                    ref.read(userPlacesProvider.notifier).deletePlace(id),
                onToggleFavorite: (id, isFav) => ref
                    .read(userPlacesProvider.notifier)
                    .toggleFavorite(id, isFav),
              ),
      ),
    );
  }
}
