import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/add_place_screen.dart';
import 'package:flutter_happy_place/widgets/places_list.dart';

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Places"),
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
          placesList: [],
        ),
      ),
    );
  }
}
