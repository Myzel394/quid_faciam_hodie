import 'dart:io';

import 'package:path/path.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';

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
      userID: jsonData['user_id'],
    );
  }

  String get filename => basename(location);

  MemoryType get type =>
      filename.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

  Future<File> downloadToFile() => FileManager.downloadFile(
        'memories',
        location,
      );
}
