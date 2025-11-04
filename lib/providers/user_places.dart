import 'dart:io';
import 'package:flutter_happy_place/models/place.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, details TEXT, image TEXT, snapshot TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');
    final places = data.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        details: row['details'] as String,
        image: row['image'] != null ? File(row['image'] as String) : null,
        mapSnapshot: row['snapshot'] != null
            ? File(row['snapshot'] as String)
            : null,
      );
    }).toList();

    state = places.cast<Place>();
  }

  void addPlace(
    String title,
    String details,
    File? image,
    File? mapSnapshot,
  ) async {
    final appDirectory = await syspaths.getApplicationDocumentsDirectory();

    File? copiedImage;
    File? copiedSnapShot;

    if (image != null) {
      final imageFileName = path.basename(image.path);
      copiedImage = await image.copy("${appDirectory.path}/$imageFileName");
    }

    if (mapSnapshot != null) {
      final snapShotFileName = path.basename(mapSnapshot.path);
      copiedSnapShot = await mapSnapshot.copy(
        "${appDirectory.path}/$snapShotFileName",
      );
    }

    final newPlace = Place(
      title: title,
      details: details,
      image: copiedImage,
      mapSnapshot: copiedSnapShot,
    );

    final db = await _getDatabase();
    db.insert(
      'user_places',
      {
        "id": newPlace.id,
        "title": newPlace.title,
        "details": newPlace.details,
        "image": newPlace.image?.path,
        "snapshot": newPlace.mapSnapshot?.path,
      },
    );

    await db.close();

    state = [newPlace, ...state];
  }
}

//* <--- By defining the <UserPlacesNotifier, List<Place>>, we are making dart aware what kind of data it will be. --->
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
