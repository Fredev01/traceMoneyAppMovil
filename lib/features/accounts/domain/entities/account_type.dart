enum AccountType { debito, credito }

extension AccountTypeX on AccountType {
  String toApiString() => switch (this) {
        AccountType.debito => 'DEBITO',
        AccountType.credito => 'CREDITO',
      };

  static AccountType fromApiString(String v) => switch (v) {
        'DEBITO' => AccountType.debito,
        'CREDITO' => AccountType.credito,
        _ => throw ArgumentError('Unknown AccountType: $v'),
      };
}
