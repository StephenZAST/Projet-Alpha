import '../models/user.dart';
import 'package:get_storage/get_storage.dart';

class OrderCacheService {
  static final _storage = GetStorage();
  static const _recentSearchesKey = 'recent_user_searches';
  static const _maxRecentSearches = 10;

  static List<User> getRecentSearches() {
    final List<dynamic> rawList = _storage.read(_recentSearchesKey) ?? [];
    return rawList.map((json) => User.fromJson(json)).toList();
  }

  static void addRecentSearch(User user) {
    final recentSearches = getRecentSearches();

    // Éviter les doublons
    recentSearches.removeWhere((item) => item.id == user.id);

    // Ajouter au début de la liste
    recentSearches.insert(0, user);

    // Limiter la taille de la liste
    if (recentSearches.length > _maxRecentSearches) {
      recentSearches.removeLast();
    }

    // Sauvegarder
    _storage.write(_recentSearchesKey,
        recentSearches.map((user) => user.toJson()).toList());
  }

  static void clearRecentSearches() {
    _storage.remove(_recentSearchesKey);
  }
}
