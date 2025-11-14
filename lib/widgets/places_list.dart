import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_detail_screen.dart';

import '../models/place.dart';
import '../utils/file_utils.dart';
import '../widgets/custom_snackbar.dart';

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
            //* <-- Delete (Swipe left to right) --->
            secondaryBackground: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16,
              ),
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).colorScheme.error,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.delete, size: 24, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            //* <-- Favorite (Swipe left to right) --->
            background: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16,
              ),
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).colorScheme.secondary,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, size: 24, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Super Happy Place',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                final newFav = !place.isFavorite;
                final messenger = ScaffoldMessenger.of(context);
                final successSnack = CustomSnackbar.build(
                  context,
                  newFav
                      ? 'Added "${place.title}" to favorites 😃'
                      : 'Removed "${place.title}" from favorites 🥺',
                  isError: false,
                );
                final errorSnack = CustomSnackbar.build(
                  context,
                  'Failed to update favorite',
                  isError: true,
                );

                try {
                  await onToggleFavorite(place.id, newFav);
                  messenger.showSnackBar(successSnack);
                } catch (e) {
                  messenger.showSnackBar(errorSnack);
                }
                return false;
              }

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
                final deletedSnack = CustomSnackbar.build(
                  context,
                  'Deleted "${place.title}"',
                  isError: false,
                );
                final deleteErrorSnack = CustomSnackbar.build(
                  context,
                  'Failed to delete',
                  isError: true,
                );

                try {
                  await onDelete(place.id);
                  messenger.showSnackBar(deletedSnack);
                } catch (e) {
                  messenger.showSnackBar(deleteErrorSnack);
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
                    foregroundImage: isValidImageFile(place.image)
                        ? FileImage(place.image!)
                        : null,
                    child: isValidImageFile(place.image)
                        ? null
                        : Icon(
                            Icons.image_not_supported,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                          ),
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
