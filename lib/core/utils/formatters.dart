import 'package:intl/intl.dart';

/// Memformat harga tiket masuk ke format Rupiah Indonesia,
/// atau mengembalikan "Gratis" jika harga <= 0.
String formatTicketPrice(int price) {
  if (price <= 0) {
    return 'Gratis';
  }
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(price);
}
