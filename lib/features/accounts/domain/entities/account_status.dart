import 'account_type.dart';

class AccountStatus {
  final String id;
  final AccountType accountType;
  final String bankName;
  final String color;
  final String? balance;
  final String? creditLimit;
  final int? cutDay;
  final int? paymentDueDay;
  final String? currentCycleCharges;
  final String? totalOwed;
  final String? availableLimit;
  final double? utilizationPct;
  final String? nextPaymentAmount;
  final String? nextPaymentDate;
  final int? daysToCut;
  final int? daysToPayment;

  const AccountStatus({
    required this.id,
    required this.accountType,
    required this.bankName,
    required this.color,
    this.balance,
    this.creditLimit,
    this.cutDay,
    this.paymentDueDay,
    this.currentCycleCharges,
    this.totalOwed,
    this.availableLimit,
    this.utilizationPct,
    this.nextPaymentAmount,
    this.nextPaymentDate,
    this.daysToCut,
    this.daysToPayment,
  });
}
