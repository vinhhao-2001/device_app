class Utils {
  String sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[.#$[\]]'), '_');
  }
}
