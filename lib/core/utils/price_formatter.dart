import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(locale: 'en_NP', symbol: 'NPR ', decimalDigits: 0);

String formatPrice(num value) => _currencyFormatter.format(value);