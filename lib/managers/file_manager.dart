import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_location/enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final supabase = Supabase.instance.client;

class FileManager {
  static Map<String, Uint8List> fileCache = {};

  static Future<User> getUser(final String userID) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', userID)
        .single()
        .execute();

    return response.data;
  }

  static uploadFile(final User user, final File file) async {
    final basename = uuid.v4();
    final extension = file.path.split('.').last;
    final filename = '$basename.$extension';
    final path = '${user.id}/$filename';

    final response = await supabase.storage.from('memories').upload(path, file);

    if (response.error != null) {
      throw Exception('Error uploading file: ${response.error!.message}');
    }

    final memoryResponse = await supabase.from('memories').insert({
      'user': user.id,
      'location': path,
    }).execute();

    if (memoryResponse.error != null) {
      throw Exception('Error creating memory: ${response.error!.message}');
    }
  }

  static Future<List?> getLastFile(final User user) async {
    final response = await supabase
        .from('memories')
        .select()
        .eq('user', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .single()
        .execute();

    if (response.data == null) {
      return null;
    }

    final memory = response.data;
    final location = memory['location'];
    final memoryType =
        location.split('.').last == 'jpg' ? MemoryType.photo : MemoryType.video;

    try {
      final file = await getFileData('memories', location);

      return [file, memoryType];
    } catch (error) {
      return null;
    }
  }

  static Future<Uint8List> getFileData(final String table, final String path,
      {final bool disableCache = false}) async {
    final key = '$table:$path';

    if (!disableCache && fileCache.containsKey(key)) {
      return fileCache[key]!;
    }

    final response = await supabase.storage.from(table).download(path);

    if (response.error != null) {
      throw Exception('Error downloading file: ${response.error!.message}');
    }

    final data = response.data!;

    fileCache[key] = data;

    return data;
  }

  static Future<File> downloadFile(
    final String table,
    final String path, {
    final bool disableDownloadCache = false,
    final bool disableFileCache = false,
  }) async {
    final tempDirectory = await getTemporaryDirectory();
    final filename = '${tempDirectory.path}/$path';
    final file = File(filename);

    if (!disableFileCache && (await file.exists())) {
      return file;
    }

    final data =
        await getFileData(table, path, disableCache: disableDownloadCache);

    // Create file
    await file.create(recursive: true);
    await file.writeAsBytes(data);

    return file;
  }

  static Future<void> deleteFile(final String path) async {
    final response =
        await supabase.from('memories').delete().eq('location', path).execute();

    if (response.error != null) {
      throw Exception('Error deleting file: ${response.error!.message}');
    }

    final storageResponse =
        await supabase.storage.from('memories').remove([path]);

    if (storageResponse.error != null) {
      throw Exception('Error deleting file: ${storageResponse.error!.message}');
    }
  }
}
