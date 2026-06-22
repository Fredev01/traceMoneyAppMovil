import '../../domain/entities/account_status.dart';
import '../../domain/entities/account_type.dart';

class AccountStatusModel {
  final String id;
  final String accountType;
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

  const AccountStatusModel({
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

  factory AccountStatusModel.fromJson(Map<String, dynamic> json) =>
      AccountStatusModel(
        id: json['id'] as String,
        accountType: json['account_type'] as String,
        bankName: json['bank_name'] as String,
        color: json['color'] as String,
        balance: json['balance'] as String?,
        creditLimit: json['credit_limit'] as String?,
        cutDay: json['cut_day'] as int?,
        paymentDueDay: json['payment_due_day'] as int?,
        currentCycleCharges: json['current_cycle_charges'] as String?,
        totalOwed: json['total_owed'] as String?,
        availableLimit: json['available_limit'] as String?,
        utilizationPct: (json['utilization_pct'] as num?)?.toDouble(),
        nextPaymentAmount: json['next_payment_amount'] as String?,
        nextPaymentDate: json['next_payment_date'] as String?,
        daysToCut: json['days_to_cut'] as int?,
        daysToPayment: json['days_to_payment'] as int?,
      );

  AccountStatus toEntity() => AccountStatus(
        id: id,
        accountType: AccountTypeX.fromApiString(accountType),
        bankName: bankName,
        color: color,
        balance: balance,
        creditLimit: creditLimit,
        cutDay: cutDay,
        paymentDueDay: paymentDueDay,
        currentCycleCharges: currentCycleCharges,
        totalOwed: totalOwed,
        availableLimit: availableLimit,
        utilizationPct: utilizationPct,
        nextPaymentAmount: nextPaymentAmount,
        nextPaymentDate: nextPaymentDate,
        daysToCut: daysToCut,
        daysToPayment: daysToPayment,
      );
}
