import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_detail_screen.dart';

import '../models/place.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({
    super.key,
    required this.placesList,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  final List<Place> placesList;
  final Future<void> Function(String id) onDelete;
  final Future<void> Function(String id, bool isFav) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (placesList.isEmpty) {
      return const Center(child: Text("Nothing to show!"));
    } else {
      return ListView.builder(
        itemCount: placesList.length,
        itemBuilder: (ctx, index) {
          final isEven = index % 2 == 0;
          final cardShadowColor = isEven
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary;
          final place = placesList[index];
          return Dismissible(
            key: ValueKey(place.id),
            direction: DismissDirection.horizontal,
            // background for swipe right (startToEnd)
            secondaryBackground: Container(
              color: Theme.of(context).colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            background: Container(
              color: Theme.of(context).colorScheme.secondary,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.star, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // mark/unmark favorite; do not dismiss
                final newFav = !place.isFavorite;
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await onToggleFavorite(place.id, newFav);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        newFav
                            ? 'Added "${place.title}" to favorites'
                            : 'Removed "${place.title}" from favorites',
                      ),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
                }
                return false; // don't dismiss the item
              }

              // endToStart => delete confirmation
              return showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete'),
                  content: const Text(
                    'Are you sure you want to delete this happy place memory 🥹?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await onDelete(place.id);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Deleted "${place.title}"')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              }
            },
            child: Card(
              elevation: 4,
              shadowColor: cardShadowColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondaryContainer,
                    foregroundImage: FileImage(place.image!),
                  ),
                  title: Text(
                    place.title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            PlacesDetailScreen(place: place),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              // Slide the new page from bottom -> top with an ease curve.
                              final tween = Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
