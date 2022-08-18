import 'dart:io';

import 'package:path/path.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';

import 'memory_location.dart';

class Memory {
  final String id;
  final DateTime creationDate;
  final String filePath;
  final bool isPublic;
  final String userID;
  final MemoryLocation? location;

  const Memory({
    required this.id,
    required this.creationDate,
    required this.filePath,
    required this.isPublic,
    required this.userID,
    this.location,
  });

  static parse(final Map<String, dynamic> jsonData) => Memory(
        id: jsonData['id'],
        creationDate: DateTime.parse(jsonData['created_at']),
        filePath: jsonData['location'],
        isPublic: jsonData['is_public'],
        userID: jsonData['user_id'],
        location: MemoryLocation.parse(jsonData),
      );

  String get filename => basename(filePath);

  MemoryType get type =>
      filename.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

  Future<File> downloadToFile() => FileManager.downloadFile(
        'memories',
        filePath,
      );
}
