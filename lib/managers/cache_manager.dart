import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';
import 'package:quid_faciam_hodie/constants/values.dart';

const storage = FlutterSecureStorage();

class CacheManager {
  static _createKey(final String key) => '$CACHE_KEY/$key';

  static Future<bool> isCacheValid(final String key) async {
    final cacheKey = _createKey(key);
    final existingEntry = await storage.read(key: cacheKey);

    if (existingEntry != null) {
      final entry = jsonDecode(existingEntry);
      final DateTime creationDate = DateTime.parse(entry['creationDate']);

      // Check if the entry is still valid using CACHE_INVALIDATION_DURATION as the validity duration.
      return DateTime.now().difference(creationDate) <
          CACHE_INVALIDATION_DURATION;
    }

    return false;
  }

  static Future<void> set(final String key, final String data) async {
    final cacheKey = _createKey(key);
    final cacheEntry = {
      'creationDate': DateTime.now().toIso8601String(),
      'data': data,
    };

    return storage.write(
      key: cacheKey,
      value: json.encode({
        key: cacheEntry,
      }),
    );
  }

  static Future<String?> get(final String key) async {
    final cacheKey = _createKey(key);
    final existingEntry = await storage.read(key: cacheKey);

    if (existingEntry == null) {
      return null;
    }

    final entry = jsonDecode(existingEntry);

    return entry['data'];
  }
}
