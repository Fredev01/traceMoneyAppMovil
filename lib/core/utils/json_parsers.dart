/// Helpers de parseo JSON tolerantes a discrepancias con el contrato.
///
/// `docs/api-reference.md` define los montos como string decimal (`"1500.00"`),
/// pero el backend los serializa como número JSON (`8000.0`). Estas funciones
/// aceptan ambos formatos y normalizan a string decimal, evitando el
/// `type 'double' is not a subtype of type 'String'` al parsear.
library;

/// Convierte un valor JSON (número o string) a string decimal, o `null`.
String? asDecimalStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toStringAsFixed(2);
  return value.toString();
}

/// Igual que [asDecimalStringOrNull] pero para campos requeridos.
String asDecimalString(dynamic value) =>
    asDecimalStringOrNull(value) ?? '0.00';
