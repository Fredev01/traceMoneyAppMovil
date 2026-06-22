enum MovementType { capitalInicial, ajusteCapital, transferIn, transferOut }

extension MovementTypeX on MovementType {
  static MovementType fromApiString(String v) => switch (v) {
        'CAPITAL_INICIAL' => MovementType.capitalInicial,
        'AJUSTE_CAPITAL' => MovementType.ajusteCapital,
        'TRANSFER_IN' => MovementType.transferIn,
        'TRANSFER_OUT' => MovementType.transferOut,
        _ => throw ArgumentError('Unknown MovementType: $v'),
      };
}
