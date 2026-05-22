class FormatUtils {
  static String formatVND(double amount) {
    int rounded = amount.round();
    // Format using regex to add thousand separators with dot
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]}.';
    String result = rounded.toString().replaceAllMapped(reg, mathFunc);
    return "$result đ";
  }
}
