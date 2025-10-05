import 'package:flutter/material.dart';
import 'package:flutter_happy_place/providers/user_places.dart';
import 'package:flutter_happy_place/screens/add_place_screen.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef myRef) {
    final userPlaces = myRef.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Happy Places"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddPlaceScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: PlacesList(
          placesList: userPlaces,
        ),
      ),
    );
  }
}
