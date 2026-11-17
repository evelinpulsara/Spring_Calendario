library;

class ContractViolation extends FormatException {
  ContractViolation(String where, String problem) : super('$where: $problem');
}

class JsonObject {
  JsonObject._(this._map, this._where);

  final Map<String, dynamic> _map;
  final String _where;

  static JsonObject parse(Object? json, String where) {
    if (json is Map<String, dynamic>) return JsonObject._(json, where);
    throw ContractViolation(where, 'se esperaba un objeto JSON');
  }

  static List<JsonObject> parseList(Object? json, String where) {
    if (json is! List) throw ContractViolation(where, 'se esperaba una lista');
    return [for (var i = 0; i < json.length; i++) parse(json[i], '$where[$i]')];
  }

  String string(String key) {
    final value = _map[key];
    if (value is String) return value;
    throw ContractViolation('$_where.$key', 'se esperaba texto, llegó ${_type(value)}');
  }

  String? optionalString(String key) => _map[key] == null ? null : string(key);

  int? optionalInteger(String key) => _map[key] == null ? null : integer(key);

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

  DateTime date(String key) {
    final text = string(key);
    final parsed = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text) ? DateTime.tryParse(text) : null;
    if (parsed == null) throw ContractViolation('$_where.$key', '"$text" no es una fecha YYYY-MM-DD');
    return parsed;
  }

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
