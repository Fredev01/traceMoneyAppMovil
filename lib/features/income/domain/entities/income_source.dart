enum IncomeSource { sueldo, freelance, bono, inversion, renta, otro }

extension IncomeSourceX on IncomeSource {
  String toApiString() => switch (this) {
        IncomeSource.sueldo => 'SUELDO',
        IncomeSource.freelance => 'FREELANCE',
        IncomeSource.bono => 'BONO',
        IncomeSource.inversion => 'INVERSION',
        IncomeSource.renta => 'RENTA',
        IncomeSource.otro => 'OTRO',
      };

  String get label => switch (this) {
        IncomeSource.sueldo => 'Sueldo',
        IncomeSource.freelance => 'Freelance',
        IncomeSource.bono => 'Bono',
        IncomeSource.inversion => 'Inversión',
        IncomeSource.renta => 'Renta',
        IncomeSource.otro => 'Otro',
      };

  static IncomeSource fromApiString(String v) => switch (v) {
        'SUELDO' => IncomeSource.sueldo,
        'FREELANCE' => IncomeSource.freelance,
        'BONO' => IncomeSource.bono,
        'INVERSION' => IncomeSource.inversion,
        'RENTA' => IncomeSource.renta,
        'OTRO' => IncomeSource.otro,
        _ => throw ArgumentError('Unknown IncomeSource: $v'),
      };
}
