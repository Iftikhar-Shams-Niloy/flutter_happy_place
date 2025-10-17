import 'package:uuid/uuid.dart';
import 'dart:io';

final myUuid = const Uuid();

class Place {
  Place({required this.title, required this.image}) : id = myUuid.v4();

  final String id;
  final String title;
  final File image;
}
