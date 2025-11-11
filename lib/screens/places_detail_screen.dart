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
        actions: [
          IconButton(
            onPressed: () {},
            icon: Image(
              image: AssetImage("assets/icons/edit_icon.png"),
              height: 28,
              width: 28,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Builder(
              builder: (context) {
                final double padding = 16.0;
                final double spacing = 16.0;
                final double cardWidth =
                    (screenWidth - padding * 2 - spacing) / 2;
                final double cardHeight = screenHeight / 3;
                return Row(
                  children: [
                    place.image != null
                        ? GestureDetector(
                            onTap: () {
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
                                            image: FileImage(place.image!),
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
                                            decoration: BoxDecoration(
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
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: ImageCard(
                              height: cardHeight,
                              width: cardWidth,
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              shadowColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              imageProvider: FileImage(place.image!),
                            ),
                          )
                        : PlaceHolderContainer(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            cardText: 'No map snapshot',
                          ),

                    const SizedBox(width: 16),

                    place.mapSnapshot != null
                        ? GestureDetector(
                            onTap: () {
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
                                            image: FileImage(
                                              place.mapSnapshot!,
                                            ),
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
                                            decoration: BoxDecoration(
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
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: ImageCard(
                              height: cardHeight,
                              width: cardWidth,
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              shadowColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              imageProvider: FileImage(place.mapSnapshot!),
                            ),
                          )
                        : PlaceHolderContainer(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            cardText: 'No map snapshot',
                          ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.details,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceHolderContainer extends StatelessWidget {
  const PlaceHolderContainer({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    this.cardText = 'No map snapshot',
  });

  final double cardHeight;
  final double cardWidth;
  final String cardText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            blurRadius: 8,
            spreadRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        cardText,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
