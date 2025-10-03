import 'package:flutter/material.dart';

import '../models/place.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.placesList});

  final List<Place> placesList;

  @override
  Widget build(BuildContext context) {
    if (placesList.isEmpty) {
      return const Center(child: Text("Nothing to show!"));
    } else {
      return ListView.builder(
        itemCount: placesList.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(
            placesList[index].title,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }
  }
}
