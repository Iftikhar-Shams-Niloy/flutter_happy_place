import 'package:flutter/material.dart';
import 'package:flutter_happy_place/screens/places_detail_screen.dart';

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
        itemBuilder: (ctx, index) {
          final isEven = index % 2 == 0;
          final cardShadowColor = isEven
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary;
          return Card(
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
                  foregroundImage: FileImage(placesList[index].image!),
                ),
                title: Text(
                  placesList[index].title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          PlacesDetailScreen(place: placesList[index]),
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
          );
        },
      );
    }
  }
}
