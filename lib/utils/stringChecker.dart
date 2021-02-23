class StringChecker {

  static bool hasWhiteSpace(String string) {
    if (string.trim().contains(' ')) {
      return true;
    } else {
      return false;
    }
  }

}