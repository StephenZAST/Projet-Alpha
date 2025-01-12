// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderState {
  List<Service> get services => throw _privateConstructorUsedError;
  List<ArticleCategory> get categories => throw _privateConstructorUsedError;
  List<Article> get articles => throw _privateConstructorUsedError;
  Service? get selectedService => throw _privateConstructorUsedError;
  Map<String, int> get selectedArticles => throw _privateConstructorUsedError;
  DateTime? get collectionDate => throw _privateConstructorUsedError;
  DateTime? get deliveryDate => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStateCopyWith<OrderState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStateCopyWith<$Res> {
  factory $OrderStateCopyWith(
          OrderState value, $Res Function(OrderState) then) =
      _$OrderStateCopyWithImpl<$Res, OrderState>;
  @useResult
  $Res call(
      {List<Service> services,
      List<ArticleCategory> categories,
      List<Article> articles,
      Service? selectedService,
      Map<String, int> selectedArticles,
      DateTime? collectionDate,
      DateTime? deliveryDate,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$OrderStateCopyWithImpl<$Res, $Val extends OrderState>
    implements $OrderStateCopyWith<$Res> {
  _$OrderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? services = null,
    Object? categories = null,
    Object? articles = null,
    Object? selectedService = freezed,
    Object? selectedArticles = null,
    Object? collectionDate = freezed,
    Object? deliveryDate = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      services: null == services
          ? _value.services
          : services // ignore: cast_nullable_to_non_nullable
              as List<Service>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ArticleCategory>,
      articles: null == articles
          ? _value.articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<Article>,
      selectedService: freezed == selectedService
          ? _value.selectedService
          : selectedService // ignore: cast_nullable_to_non_nullable
              as Service?,
      selectedArticles: null == selectedArticles
          ? _value.selectedArticles
          : selectedArticles // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      collectionDate: freezed == collectionDate
          ? _value.collectionDate
          : collectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveryDate: freezed == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderStateImplCopyWith<$Res>
    implements $OrderStateCopyWith<$Res> {
  factory _$$OrderStateImplCopyWith(
          _$OrderStateImpl value, $Res Function(_$OrderStateImpl) then) =
      __$$OrderStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Service> services,
      List<ArticleCategory> categories,
      List<Article> articles,
      Service? selectedService,
      Map<String, int> selectedArticles,
      DateTime? collectionDate,
      DateTime? deliveryDate,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$OrderStateImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$OrderStateImpl>
    implements _$$OrderStateImplCopyWith<$Res> {
  __$$OrderStateImplCopyWithImpl(
      _$OrderStateImpl _value, $Res Function(_$OrderStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? services = null,
    Object? categories = null,
    Object? articles = null,
    Object? selectedService = freezed,
    Object? selectedArticles = null,
    Object? collectionDate = freezed,
    Object? deliveryDate = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$OrderStateImpl(
      services: null == services
          ? _value._services
          : services // ignore: cast_nullable_to_non_nullable
              as List<Service>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<ArticleCategory>,
      articles: null == articles
          ? _value._articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<Article>,
      selectedService: freezed == selectedService
          ? _value.selectedService
          : selectedService // ignore: cast_nullable_to_non_nullable
              as Service?,
      selectedArticles: null == selectedArticles
          ? _value._selectedArticles
          : selectedArticles // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      collectionDate: freezed == collectionDate
          ? _value.collectionDate
          : collectionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveryDate: freezed == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OrderStateImpl implements _OrderState {
  const _$OrderStateImpl(
      {final List<Service> services = const [],
      final List<ArticleCategory> categories = const [],
      final List<Article> articles = const [],
      this.selectedService,
      final Map<String, int> selectedArticles = const {},
      this.collectionDate,
      this.deliveryDate,
      this.isLoading = false,
      this.error})
      : _services = services,
        _categories = categories,
        _articles = articles,
        _selectedArticles = selectedArticles;

  final List<Service> _services;
  @override
  @JsonKey()
  List<Service> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  final List<ArticleCategory> _categories;
  @override
  @JsonKey()
  List<ArticleCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<Article> _articles;
  @override
  @JsonKey()
  List<Article> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  final Service? selectedService;
  final Map<String, int> _selectedArticles;
  @override
  @JsonKey()
  Map<String, int> get selectedArticles {
    if (_selectedArticles is EqualUnmodifiableMapView) return _selectedArticles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedArticles);
  }

  @override
  final DateTime? collectionDate;
  @override
  final DateTime? deliveryDate;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'OrderState(services: $services, categories: $categories, articles: $articles, selectedService: $selectedService, selectedArticles: $selectedArticles, collectionDate: $collectionDate, deliveryDate: $deliveryDate, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStateImpl &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._articles, _articles) &&
            (identical(other.selectedService, selectedService) ||
                other.selectedService == selectedService) &&
            const DeepCollectionEquality()
                .equals(other._selectedArticles, _selectedArticles) &&
            (identical(other.collectionDate, collectionDate) ||
                other.collectionDate == collectionDate) &&
            (identical(other.deliveryDate, deliveryDate) ||
                other.deliveryDate == deliveryDate) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_services),
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_articles),
      selectedService,
      const DeepCollectionEquality().hash(_selectedArticles),
      collectionDate,
      deliveryDate,
      isLoading,
      error);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStateImplCopyWith<_$OrderStateImpl> get copyWith =>
      __$$OrderStateImplCopyWithImpl<_$OrderStateImpl>(this, _$identity);
}

abstract class _OrderState implements OrderState {
  const factory _OrderState(
      {final List<Service> services,
      final List<ArticleCategory> categories,
      final List<Article> articles,
      final Service? selectedService,
      final Map<String, int> selectedArticles,
      final DateTime? collectionDate,
      final DateTime? deliveryDate,
      final bool isLoading,
      final String? error}) = _$OrderStateImpl;

  @override
  List<Service> get services;
  @override
  List<ArticleCategory> get categories;
  @override
  List<Article> get articles;
  @override
  Service? get selectedService;
  @override
  Map<String, int> get selectedArticles;
  @override
  DateTime? get collectionDate;
  @override
  DateTime? get deliveryDate;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStateImplCopyWith<_$OrderStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrderResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_OrderSuccess value) success,
    required TResult Function(_OrderError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_OrderSuccess value)? success,
    TResult? Function(_OrderError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_OrderSuccess value)? success,
    TResult Function(_OrderError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderResultCopyWith<$Res> {
  factory $OrderResultCopyWith(
          OrderResult value, $Res Function(OrderResult) then) =
      _$OrderResultCopyWithImpl<$Res, OrderResult>;
}

/// @nodoc
class _$OrderResultCopyWithImpl<$Res, $Val extends OrderResult>
    implements $OrderResultCopyWith<$Res> {
  _$OrderResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OrderSuccessImplCopyWith<$Res> {
  factory _$$OrderSuccessImplCopyWith(
          _$OrderSuccessImpl value, $Res Function(_$OrderSuccessImpl) then) =
      __$$OrderSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OrderSuccessImplCopyWithImpl<$Res>
    extends _$OrderResultCopyWithImpl<$Res, _$OrderSuccessImpl>
    implements _$$OrderSuccessImplCopyWith<$Res> {
  __$$OrderSuccessImplCopyWithImpl(
      _$OrderSuccessImpl _value, $Res Function(_$OrderSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OrderSuccessImpl implements _OrderSuccess {
  const _$OrderSuccessImpl();

  @override
  String toString() {
    return 'OrderResult.success()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OrderSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return success();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return success?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_OrderSuccess value) success,
    required TResult Function(_OrderError value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_OrderSuccess value)? success,
    TResult? Function(_OrderError value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_OrderSuccess value)? success,
    TResult Function(_OrderError value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _OrderSuccess implements OrderResult {
  const factory _OrderSuccess() = _$OrderSuccessImpl;
}

/// @nodoc
abstract class _$$OrderErrorImplCopyWith<$Res> {
  factory _$$OrderErrorImplCopyWith(
          _$OrderErrorImpl value, $Res Function(_$OrderErrorImpl) then) =
      __$$OrderErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$OrderErrorImplCopyWithImpl<$Res>
    extends _$OrderResultCopyWithImpl<$Res, _$OrderErrorImpl>
    implements _$$OrderErrorImplCopyWith<$Res> {
  __$$OrderErrorImplCopyWithImpl(
      _$OrderErrorImpl _value, $Res Function(_$OrderErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$OrderErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$OrderErrorImpl implements _OrderError {
  const _$OrderErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'OrderResult.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OrderResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderErrorImplCopyWith<_$OrderErrorImpl> get copyWith =>
      __$$OrderErrorImplCopyWithImpl<_$OrderErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_OrderSuccess value) success,
    required TResult Function(_OrderError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_OrderSuccess value)? success,
    TResult? Function(_OrderError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_OrderSuccess value)? success,
    TResult Function(_OrderError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _OrderError implements OrderResult {
  const factory _OrderError(final String message) = _$OrderErrorImpl;

  String get message;

  /// Create a copy of OrderResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderErrorImplCopyWith<_$OrderErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
