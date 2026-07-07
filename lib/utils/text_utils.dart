String safeInitial(String? text, {String fallback = 'A'}) {
  final value = (text ?? '').trim();
  if (value.isEmpty) return fallback;
  return value.substring(0, 1).toUpperCase();
}
