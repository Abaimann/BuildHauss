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
