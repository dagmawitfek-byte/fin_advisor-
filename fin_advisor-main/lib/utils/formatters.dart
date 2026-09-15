import 'package:intl/intl.dart';

class Formatters {
  static final currency = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);
  static final compactCurrency =
      NumberFormat.compactCurrency(symbol: 'ETB ', decimalDigits: 1);
  static final date = DateFormat('MMM d, yyyy');
  static final shortDate = DateFormat('MMM d');
  static final monthYear = DateFormat('MMMM yyyy');

  static String money(double value) => currency.format(value);
  static String compactMoney(double value) => compactCurrency.format(value);
}
