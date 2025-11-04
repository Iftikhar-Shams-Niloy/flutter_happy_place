import 'package:uuid/uuid.dart';
import 'dart:io';

final myUuid = const Uuid();

class Place {
  Place({
    String? id,
    required this.title,
    required this.details,
    required this.image,
    required this.mapSnapshot,
  }) : id = id ?? myUuid.v4();

  final String id;
  final String title;
  final String details;
  final File? image;
  final File? mapSnapshot;
}
