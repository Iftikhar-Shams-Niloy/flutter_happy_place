import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref
        .watch(userPlacesProvider)
        .where((p) => p.isFavorite)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Super Happy Places')),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: PlacesList(
          placesList: places,
          onDelete: (id) =>
              ref.read(userPlacesProvider.notifier).deletePlace(id),
          onToggleFavorite: (id, isFav) =>
              ref.read(userPlacesProvider.notifier).toggleFavorite(id, isFav),
        ),
      ),
    );
  }
}
