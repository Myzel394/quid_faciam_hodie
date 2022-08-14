import 'package:share_location/enums.dart';

class Memory {
  final String id;
  final DateTime creationDate;
  final String location;
  final bool isPublic;
  final String userID;

  const Memory({
    required this.id,
    required this.creationDate,
    required this.location,
    required this.isPublic,
    required this.userID,
  });

  static parse(Map<String, dynamic> jsonData) {
    return Memory(
      id: jsonData['id'],
      creationDate: DateTime.parse(jsonData['created_at']),
      location: jsonData['location'],
      isPublic: jsonData['is_public'],
      userID: jsonData['user'],
    );
  }

  MemoryType get type =>
      location.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;
}
