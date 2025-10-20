import 'package:flutter/material.dart';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_happy_place/widgets/custom_item_card.dart';

class PlacesDetailScreen extends StatelessWidget {
  const PlacesDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ImageCard(
              height: screenHeight / 2,
              width: screenWidth / 2,
              borderColor: Theme.of(context).colorScheme.secondary,
              shadowColor: Theme.of(context).colorScheme.primary,
              imageProvider: FileImage(place.image),
            ),
          ),
          Text(
            place.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
