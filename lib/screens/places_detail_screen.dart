import 'package:flutter/material.dart';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_happy_place/widgets/custom_item_card.dart';
import 'add_place_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_places.dart';
import '../utils/file_utils.dart';

class PlacesDetailScreen extends ConsumerStatefulWidget {
  const PlacesDetailScreen({super.key, required this.place});

  final Place place;

  @override
  ConsumerState<PlacesDetailScreen> createState() => _PlacesDetailScreenState();
}

class _PlacesDetailScreenState extends ConsumerState<PlacesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // watch provider so UI updates when the place is edited
    final places = ref.watch(userPlacesProvider);
    Place place;
    try {
      place = places.firstWhere((p) => p.id == widget.place.id);
    } catch (_) {
      // fallback to the original passed place if not found
      place = widget.place;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddPlaceScreen(editingPlace: place),
                ),
              );
              // after the edit screen returns, provider will have
              // been updated and ref.watch above will rebuild with new data
            },
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
                    isValidImageFile(place.image)
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
                                            errorBuilder: (context, error, stack) =>
                                                const Icon(Icons.error, size: 100),
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
                              imageProvider: isValidImageFile(place.image)
                                  ? FileImage(place.image!)
                                  : null,
                            ),
                          )
                        : PlaceHolderContainer(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            cardText: 'No image',
                          ),

                    const SizedBox(width: 16),

                    isValidImageFile(place.mapSnapshot)
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
                                            errorBuilder: (context, error, stack) =>
                                                const Icon(Icons.error, size: 100),
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
                              imageProvider: isValidImageFile(place.mapSnapshot)
                                  ? FileImage(place.mapSnapshot!)
                                  : null,
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
