import 'dart:io';

import 'package:gallery_saver/gallery_saver.dart';
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
  final String annotation;
  final MemoryLocation? location;

  const Memory({
    required this.id,
    required this.creationDate,
    required this.filePath,
    required this.isPublic,
    required this.userID,
    required this.annotation,
    this.location,
  });

  static parse(final Map<String, dynamic> jsonData) => Memory(
        id: jsonData['id'],
        creationDate: DateTime.parse(jsonData['created_at']),
        filePath: jsonData['location'],
        isPublic: jsonData['is_public'],
        userID: jsonData['user_id'],
        annotation: jsonData['annotation'],
        location: MemoryLocation.parse(jsonData),
      );

  String get filename => basename(filePath);

  MemoryType get type =>
      filename.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

  Future<File> downloadToFile() => FileManager.downloadFile(
        'memories',
        filePath,
      );

  Future<void> saveFileToGallery() async {
    final file = await downloadToFile();

    switch (type) {
      case MemoryType.photo:
        await GallerySaver.saveImage(file.path);
        break;
      case MemoryType.video:
        await GallerySaver.saveVideo(file.path);
        break;
    }
  }
}
