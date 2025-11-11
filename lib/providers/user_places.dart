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
    version: 2,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, details TEXT, image TEXT, snapshot TEXT, favorite INTEGER DEFAULT 0)',
      );
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      // Add favorite column when upgrading from older DBs if it doesn't exist
      if (oldVersion < 2) {
        try {
          await db.execute(
            'ALTER TABLE user_places ADD COLUMN favorite INTEGER DEFAULT 0',
          );
        } catch (_) {
          // ignore if column already exists or cannot be altered on some platforms
        }
      }
    },
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
        isFavorite: (row['favorite'] as int?) == 1,
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
      isFavorite: false,
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
        "favorite": newPlace.isFavorite ? 1 : 0,
      },
    );

    await db.close();

    state = [newPlace, ...state];
  }

  Future<void> updatePlace(
    String id,
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

    final db = await _getDatabase();
    await db.update(
      'user_places',
      {
        "title": title,
        "details": details,
        "image": copiedImage?.path,
        "snapshot": copiedSnapShot?.path,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.close();

    state = state
        .map((p) => p.id == id
            ? Place(
                id: p.id,
                title: title,
                details: details,
                image: copiedImage ?? p.image,
                mapSnapshot: copiedSnapShot ?? p.mapSnapshot,
                isFavorite: p.isFavorite,
              )
            : p)
        .toList();
  }

  Future<void> deletePlace(String id) async {
    Place? existing;
    try {
      existing = state.firstWhere((p) => p.id == id);
    } catch (_) {
      existing = null;
    }

    try {
      if (existing != null) {
        if (existing.image != null && await existing.image!.exists()) {
          await existing.image!.delete();
        }
        if (existing.mapSnapshot != null &&
            await existing.mapSnapshot!.exists()) {
          await existing.mapSnapshot!.delete();
        }
      }
    } catch (_) {}

    final db = await _getDatabase();
    await db.delete(
      'user_places',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.close();

    state = state.where((p) => p.id != id).toList();
  }

  Future<void> toggleFavorite(String id, bool isFav) async {
    final db = await _getDatabase();
    await db.update(
      'user_places',
      {'favorite': isFav ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.close();

    state = state
        .map(
          (p) => p.id == id
              ? Place(
                  id: p.id,
                  title: p.title,
                  details: p.details,
                  image: p.image,
                  mapSnapshot: p.mapSnapshot,
                  isFavorite: isFav,
                )
              : p,
        )
        .toList();
  }
}

//* <--- By defining the <UserPlacesNotifier, List<Place>>, we are making dart aware what kind of data it will be. --->
final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
      (ref) => UserPlacesNotifier(),
    );
