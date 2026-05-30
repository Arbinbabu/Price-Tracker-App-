import 'package:intl/intl.dart';

String formatNpr(double value) => NumberFormat.currency(symbol: 'NPR ', decimalDigits: 0).format(value);
