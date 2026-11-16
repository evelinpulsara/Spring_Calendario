/// Validación de datos externos en tiempo de ejecución (tema 2 del curso).
///
/// Los tipos de Dart protegen el código que escribimos, pero `jsonDecode`
/// devuelve `dynamic`: el compilador no sabe qué mandó realmente el servidor.
/// Validar sería solo revisar "¿está bien?"; aquí **parseamos**: convertimos
/// el JSON desconocido en datos con tipos seguros, o fallamos con un error
/// claro ([ContractViolation]) en vez de un `TypeError` en medio de la pantalla.
///
/// Las reglas siguen el contrato `openapi.yaml` del backend (Spring_Backend).
library;

/// La respuesta no cumple el contrato de la API.
class ContractViolation extends FormatException {
  ContractViolation(String where, String problem) : super('$where: $problem');
}

/// Objeto JSON con lectura tipada y validada.
class JsonObject {
  JsonObject._(this._map, this._where);

  final Map<String, dynamic> _map;
  final String _where;

  /// Convierte un valor de `jsonDecode` en objeto, o lanza [ContractViolation].
  static JsonObject parse(Object? json, String where) {
    if (json is Map<String, dynamic>) return JsonObject._(json, where);
    throw ContractViolation(where, 'se esperaba un objeto JSON');
  }

  /// Lista de objetos JSON (por ejemplo `GET /api/symptoms`).
  static List<JsonObject> parseList(Object? json, String where) {
    if (json is! List) throw ContractViolation(where, 'se esperaba una lista');
    return [for (var i = 0; i < json.length; i++) parse(json[i], '$where[$i]')];
  }

  String string(String key) {
    final value = _map[key];
    if (value is String) return value;
    throw ContractViolation('$_where.$key', 'se esperaba texto, llegó ${_type(value)}');
  }

  int integer(String key, {int? min, int? max}) {
    final value = _map[key];
    if (value is! num || value != value.roundToDouble()) {
      throw ContractViolation('$_where.$key', 'se esperaba un entero, llegó ${_type(value)}');
    }
    final n = value.toInt();
    if ((min != null && n < min) || (max != null && n > max)) {
      throw ContractViolation('$_where.$key', '$n fuera del rango [$min, $max]');
    }
    return n;
  }

  /// Fecha `YYYY-MM-DD` del contrato.
  DateTime date(String key) {
    final text = string(key);
    final parsed = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ? DateTime.tryParse(text) : null;
    if (parsed == null) throw ContractViolation('$_where.$key', '"$text" no es una fecha YYYY-MM-DD');
    return parsed;
  }

  /// Valor de un `enum` del contrato (por ejemplo `flow`: none|light|medium|heavy).
  T enumValue<T extends Enum>(String key, List<T> values) {
    final text = string(key);
    for (final v in values) {
      if (v.name == text) return v;
    }
    throw ContractViolation(
        '$_where.$key', '"$text" no es uno de ${values.map((v) => v.name).join('|')}');
  }

  static String _type(Object? v) => v == null ? 'null' : v.runtimeType.toString();
}
