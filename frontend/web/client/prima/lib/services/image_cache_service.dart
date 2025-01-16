import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  static Future<String> getCachedImagePath(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      final file = await _cacheManager.downloadFile(url);
      return file.file.path;
    }
    return fileInfo.file.path;
  }

  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}
