import 'package:intl/intl.dart';

class IntFormatter {
  static final _formatador = NumberFormat.decimalPattern('pt_BR');

  static String format(int valor) {
    return _formatador.format(valor);
  }
}
