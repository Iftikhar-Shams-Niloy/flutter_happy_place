import 'dart:io';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image, [File? mapSnapshot]) {
    final newPlace = Place(
      title: title,
      image: image,
      mapSnapshot: mapSnapshot,
    );
    state = [newPlace, ...state];
  }
}

//* <--- By defining the <UserPlacesNotifier, List<Place>>, we are making dart aware what kind of data it will be. --->
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
