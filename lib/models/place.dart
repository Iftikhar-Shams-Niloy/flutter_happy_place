import 'package:uuid/uuid.dart';

final myUuid = const Uuid();

class Place {
  Place({required this.title}) : id = myUuid.v4();

  final String id;
  final String title;
}
