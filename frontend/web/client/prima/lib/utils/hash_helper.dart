import 'package:flutter/foundation.dart';

@Deprecated('Use Object.hash() instead')
int hashValues(dynamic value1, dynamic value2) {
  return Object.hash(value1, value2);
}
