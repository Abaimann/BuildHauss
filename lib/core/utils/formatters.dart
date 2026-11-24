import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _idrNumberFormat = NumberFormat('#,###', 'id_ID');
  static final _kmFormat = NumberFormat('#,###', 'id_ID');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _shortDateFormat = DateFormat('dd MMM', 'id_ID');

  static String currency(int? amount) {
    if (amount == null) return 'Harga belum tersedia';
    return _currencyFormat.format(amount);
  }

  static String formatIdrNumber(int amount) {
    return _idrNumberFormat.format(amount);
  }

  /// Mengekstrak nilai integer dari input nominal IDR (contoh: `"350.000"` -> `350000`).
  static int? parseCurrencyInt(String raw) {
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;
    return int.tryParse(digitsOnly);
  }

  /// Memformat angka odometer dengan pemisah ribuan bertitik (contoh: `14500` -> `"14.500"`).
  static String formatOdometer(num value) {
    if (!value.isFinite) return '0';
    final rounded = value < 0 ? 0 : value.round();
    return _kmFormat.format(rounded);
  }

  /// Mem-parse string odometer bertitik ribuan maupun desimal menjadi `double`
  /// (contoh: `"14.500"` -> `14500.0`, `"14.500 km"` -> `14500.0`).
  static double? parseOdometerDouble(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final isNegative = trimmed.startsWith('-');
    var cleaned = trimmed.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleaned.isEmpty) return null;

    if (cleaned.contains('.') && cleaned.contains(',')) {
      // Format Indonesia: titik sebagai pemisah ribuan, koma sebagai desimal.
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains(',')) {
      if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(cleaned)) {
        cleaned = cleaned.replaceAll(',', '');
      } else {
        cleaned = cleaned.replaceAll(',', '.');
      }
    } else if (cleaned.contains('.')) {
      // Titik ribuan bila ada > 1 titik atau diakhiri kelompok 3 digit (mis. "14.500", "1.000").
      final dotCount = '.'.allMatches(cleaned).length;
      if (dotCount > 1 || RegExp(r'^\d+\.\d{3}$').hasMatch(cleaned)) {
        cleaned = cleaned.replaceAll('.', '');
      }
    }

    final parsed = double.tryParse(cleaned);
    if (parsed == null) return null;
    return isNegative ? -parsed : parsed;
  }

  /// Memformat nomor plat Indonesia mengikuti pola `[1-2 huruf] [1-4 angka] [0-3 huruf]`
  /// dalam huruf kapital (contoh: `"b2841rdm"` -> `"B 2841 RDM"`, `"ab123cd"` -> `"AB 123 CD"`).
  static String formatPlateNumber(String raw) {
    return _formatPlateWithCursor(raw, raw.length).formatted;
  }

  static ({String formatted, int cursorOffset}) _formatPlateWithCursor(
    String raw,
    int cursorIndex,
  ) {
    final prefix = StringBuffer();
    final digits = StringBuffer();
    final suffix = StringBuffer();
    var phase = 0; // 0 = kode wilayah (huruf), 1 = angka, 2 = seri (huruf)
    var acceptedBeforeCursor = 0;
    final clampedCursor = cursorIndex.clamp(0, raw.length);

    for (var i = 0; i < raw.length; i++) {
      final code = raw.codeUnitAt(i);
      final isDigit = code >= 48 && code <= 57;
      final isUpper = code >= 65 && code <= 90;
      final isLower = code >= 97 && code <= 122;
      if (!isDigit && !isUpper && !isLower) continue;

      final ch = isLower ? String.fromCharCode(code - 32) : raw[i];
      var accepted = false;

      if (phase == 0) {
        if (!isDigit) {
          if (prefix.length < 2) {
            prefix.write(ch);
            accepted = true;
          }
        } else {
          phase = 1;
          digits.write(ch);
          accepted = true;
        }
      } else if (phase == 1) {
        if (isDigit) {
          if (digits.length < 4) {
            digits.write(ch);
            accepted = true;
          }
        } else {
          phase = 2;
          suffix.write(ch);
          accepted = true;
        }
      } else {
        if (!isDigit && suffix.length < 3) {
          suffix.write(ch);
          accepted = true;
        }
      }

      if (accepted && i < clampedCursor) {
        acceptedBeforeCursor++;
      }
    }

    final parts = <String>[
      if (prefix.isNotEmpty) prefix.toString(),
      if (digits.isNotEmpty) digits.toString(),
      if (suffix.isNotEmpty) suffix.toString(),
    ];
    final formatted = parts.join(' ');

    if (acceptedBeforeCursor == 0) {
      return (formatted: formatted, cursorOffset: 0);
    }

    var seen = 0;
    var cursorOffset = formatted.length;
    for (var i = 0; i < formatted.length; i++) {
      if (formatted.codeUnitAt(i) != 32) {
        seen++;
        if (seen >= acceptedBeforeCursor) {
          cursorOffset = i + 1;
          break;
        }
      }
    }

    return (formatted: formatted, cursorOffset: cursorOffset);
  }

  static String km(double? value) {
    if (value == null) return '-';
    return '${_kmFormat.format(value)} km';
  }

  static String date(DateTime? dt) {
    if (dt == null) return '-';
    return _dateFormat.format(dt);
  }

  static String dateTime(DateTime? dt) {
    if (dt == null) return '-';
    return _dateTimeFormat.format(dt);
  }

  static String shortDate(DateTime? dt) {
    if (dt == null) return '-';
    return _shortDateFormat.format(dt);
  }

  static String relativeDays(DateTime? dt) {
    if (dt == null) return '-';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}

/// TextInputFormatter yang otomatis memformat angka ke format ribuan IDR
/// (contoh: mengetik `350000` otomatis menjadi `350.000`) sambil menjaga posisi kursor.
class IdrTextInputFormatter extends TextInputFormatter {
  const IdrTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Hitung jumlah digit sebelum kursor pada teks baru agar kursor tetap akurat.
    final selEnd = newValue.selection.end.clamp(0, raw.length);
    final digitsBeforeCursor =
        raw.substring(0, selEnd).replaceAll(RegExp(r'[^0-9]'), '').length;

    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final parsed = int.tryParse(digits);
    if (parsed == null) return oldValue;

    final formatted = Formatters.formatIdrNumber(parsed);

    int cursorOffset = formatted.length;
    if (digitsBeforeCursor == 0) {
      cursorOffset = 0;
    } else {
      int seenDigits = 0;
      for (int i = 0; i < formatted.length; i++) {
        if (formatted.codeUnitAt(i) >= 48 && formatted.codeUnitAt(i) <= 57) {
          seenDigits++;
          if (seenDigits >= digitsBeforeCursor) {
            cursorOffset = i + 1;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}

/// Formatter angka ribuan bertitik otomatis saat diketik untuk semua input odometer
/// (contoh: mengetik `14500` otomatis menjadi `14.500`).
class OdometerTextInputFormatter extends IdrTextInputFormatter {
  const OdometerTextInputFormatter();
}

/// TextInputFormatter untuk nomor plat Indonesia (`[1-2 huruf] [1-4 angka] [0-3 huruf]`).
/// Mengubah huruf ke kapital, menghapus spasi berlebih, menyisipkan spasi antar segmen,
/// serta menjaga posisi kursor saat mengetik maupun backspace.
class IndonesiaPlateTextInputFormatter extends TextInputFormatter {
  const IndonesiaPlateTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final selEnd =
        (!newValue.selection.isValid || newValue.selection.end < 0)
            ? raw.length
            : newValue.selection.end.clamp(0, raw.length);

    final result = Formatters._formatPlateWithCursor(raw, selEnd);
    return TextEditingValue(
      text: result.formatted,
      selection: TextSelection.collapsed(
        offset: result.cursorOffset.clamp(0, result.formatted.length),
      ),
    );
  }
}
