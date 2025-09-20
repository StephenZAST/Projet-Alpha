/// Extensions pour gérer les valeurs null de manière sécurisée
extension SafeString on String? {
  String get safe => this ?? '';
  String get safeOrDefault => this?.isNotEmpty == true ? this! : 'N/A';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

extension SafeList<T> on List<T>? {
  List<T> get safe => this ?? <T>[];
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  int get safeLength => this?.length ?? 0;
}

extension SafeDouble on double? {
  double get safe => this ?? 0.0;
  bool get isNullOrZero => this == null || this == 0.0;
}

extension SafeInt on int? {
  int get safe => this ?? 0;
  bool get isNullOrZero => this == null || this == 0;
}

extension SafeBool on bool? {
  bool get safe => this ?? false;
}

extension SafeDateTime on DateTime? {
  DateTime get safe => this ?? DateTime.now();
  String get safeFormatted => this?.toString() ?? 'N/A';
}