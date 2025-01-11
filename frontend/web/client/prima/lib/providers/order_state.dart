import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:prima/widgets/order_bottom_sheet.dart';

part 'order_state.freezed.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState({
    @Default([]) List<Service> services,
    @Default([]) List<ArticleCategory> categories,
    @Default([]) List<Article> articles,
    Service? selectedService,
    @Default({}) Map<String, int> selectedArticles,
    DateTime? collectionDate,
    DateTime? deliveryDate,
    @Default(false) bool isLoading,
    String? error,
  }) = _OrderState;
}

@freezed
class OrderResult with _$OrderResult {
  const factory OrderResult.success() = _OrderSuccess;
  const factory OrderResult.error(String message) = _OrderError;
}
