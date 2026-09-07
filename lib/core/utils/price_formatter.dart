/// Saytdagi valyuta ko'rinishi: "165 000 000 so'm" / USD toggle.
enum Currency { uzs, usd }

abstract final class PriceFormatter {
  /// Saytda kurs ochiq ko'rsatilmagan — bu qiymatni bitta joydan o'zgartirasiz.
  static const int usdRate = 12800;

  static String _grouped(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 165000000 -> "165 000 000 so'm"
  static String uzs(int value) => "${_grouped(value)} so'm";

  /// 165000000 -> "12 900 \$" (yuzlikkacha yaxlitlanadi)
  static String usd(int valueUzs) {
    final raw = valueUzs / usdRate;
    final rounded = (raw / 100).round() * 100;
    return '${_grouped(rounded)} \$';
  }

  static String format(int valueUzs, Currency currency) =>
      currency == Currency.uzs ? uzs(valueUzs) : usd(valueUzs);

  /// 109000 -> "109 000 km"
  static String km(int value) => '${_grouped(value)} km';
}
