T? castOrNull<T>(dynamic x) => x != null && x is T ? x : null;

String? castString(dynamic value, {String? defaultValue}) {
  return castOrNull<String>(value) ?? defaultValue;
}

int? castInt(dynamic value, {int? defaultValue}) {
  return castOrNull<int>(value) ??
      castOrNull<double>(value)?.toInt() ??
      int.tryParse(castOrNull<String>(value) ?? '') ??
      int.tryParse(value.toString()) ??
      defaultValue;
}

bool? castBool(dynamic value, {bool? defaultValue}) {
  final asBool = castOrNull<bool>(value);
  if (asBool != null) return asBool;

  final asString = castOrNull<String>(value)?.toLowerCase().trim();
  if (asString != null) return asString == 'true';

  return defaultValue;
}
