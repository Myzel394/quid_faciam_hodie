import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_cache/flutter_cache.dart' as cache;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
const storage = FlutterSecureStorage();

final supabase = Supabase.instance.client;

class FileManager {
  static Future<Memory> getMemoryMetadata(final String id) async {
    await GlobalValuesManager.waitForInitialization();

    final response = await supabase
        .from('memories')
        .select()
        .eq('id', id)
        .single()
        .execute();

    if (response.error != null) {
      throw Exception(response.error);
    }

    return Memory.parse(response.data);
  }

  static uploadFile(
    final User user,
    final File file, {
    final LocationData? locationData,
    final Future<String?>? annotationGetterFuture,
  }) async {
    await GlobalValuesManager.waitForInitialization();

    final basename = uuid.v4();
    final extension = file.path.split('.').last;
    final filename = '$basename.$extension';
    final path = '${user.id}/$filename';

    final response = await supabase.storage.from('memories').upload(path, file);

    if (response.error != null) {
      throw Exception('Error uploading file: ${response.error!.message}');
    }

    final Map<String, dynamic> data = {
      'user_id': user.id,
      'location': path,
    };

    if (locationData != null) {
      data['location_latitude'] = locationData.latitude!;
      data['location_longitude'] = locationData.longitude!;
      data['location_speed'] = locationData.speed!;
      data['location_accuracy'] = locationData.accuracy!;
      data['location_altitude'] = locationData.altitude!;
      data['location_heading'] = locationData.heading!;
    }

    if (annotationGetterFuture != null) {
      final annotation = await annotationGetterFuture;

      if (annotation != null) {
        // User has specified annotation
        data['annotation'] = annotation;
      }
    }

    final memoryResponse =
        await supabase.from('memories').insert(data).execute();

    if (memoryResponse.error != null) {
      throw Exception('Error creating memory: ${response.error!.message}');
    }
  }

  static Future<Uint8List> _downloadFileData(
      final String table, final String path) async {
    final response = await supabase.storage.from(table).download(path);

    if (response.error != null) {
      throw Exception('Error downloading file: ${response.error!.message}');
    }

    return response.data!;
  }

  static Future<Uint8List> _getFileData(final String table, final String path,
      {final bool disableCache = false}) async {
    final key = '$table:$path';

    // Check cache
    if (!disableCache) {
      final cachedData = (await cache.load(key)) as Uint8List?;

      if (cachedData is Uint8List) {
        return cachedData as Uint8List;
      }
    }

    final data = await _downloadFileData(table, path);

    final cacheData = String.fromCharCodes(data);

    try {
      await cache.write(key, cacheData, CACHE_INVALIDATION_DURATION.inMinutes);
    } catch (error) {}

    return data;
  }

  static Future<File> downloadFile(
    final String table,
    final String path, {
    final bool disableDownloadCache = false,
    final bool disableFileCache = false,
  }) async {
    await GlobalValuesManager.waitForInitialization();

    final tempDirectory = await getTemporaryDirectory();
    final filename = '${tempDirectory.path}/$path';
    final file = File(filename);

    if (!disableFileCache && (await file.exists())) {
      return file;
    }

    final data =
        await _getFileData(table, path, disableCache: disableDownloadCache);

    // Create file
    await file.create(recursive: true);
    await file.writeAsBytes(data);

    return file;
  }

  static Future<void> deleteFile(final String path) async {
    await GlobalValuesManager.waitForInitialization();

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
