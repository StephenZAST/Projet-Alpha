class CacheManager {
  static final cache = <String, dynamic>{};

  static void setData(String key, dynamic data) {
    cache[key] = data;
  }

  static dynamic getData(String key) {
    return cache[key];
  }
}
