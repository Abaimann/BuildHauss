import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _kmFormat = NumberFormat('#,###', 'id_ID');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _shortDateFormat = DateFormat('dd MMM', 'id_ID');

  static String currency(int? amount) {
    if (amount == null) return 'Harga belum tersedia';
    return _currencyFormat.format(amount);
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
