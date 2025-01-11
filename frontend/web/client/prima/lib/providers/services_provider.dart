import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prima/models/service.dart';
import 'package:prima/services/article_service.dart';

part 'services_provider.g.dart';

@riverpod
class ServicesNotifier extends _$ServicesNotifier {
  @override
  FutureOr<List<Service>> build() async {
    return const [];
  }

  Future<void> loadServices() async {
    state = const AsyncLoading();

    try {
      final services = await ref.read(articleServiceProvider).getServices();
      state = AsyncData(services);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
ArticleService articleService(ArticleServiceRef ref) {
  return ArticleService(ref.watch(dioProvider));
}

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3001',
    contentType: 'application/json',
  ));
  return dio;
}
