import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_money/router/routes.dart';
import '../../domain/entities/account_movement.dart';
import '../../domain/entities/account_status.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/entities/movement_type.dart';
import '../cubit/account_detail_cubit.dart';
import '../cubit/account_detail_state.dart';

class AccountDetailPage extends StatefulWidget {
  final String accountId;
  const AccountDetailPage({super.key, required this.accountId});

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountDetailCubit>().loadDetail(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailCubit, AccountDetailState>(
      builder: (context, state) => switch (state) {
        AccountDetailInitial() => const Scaffold(),
        AccountDetailLoading() =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
        AccountDetailError(:final message) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(message)),
          ),
        AccountDetailLoaded(:final status, :final movements) =>
          _DetailView(status: status, movements: movements),
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final AccountStatus status;
  final List<AccountMovement> movements;
  const _DetailView({required this.status, required this.movements});

  @override
  Widget build(BuildContext context) {
    final isCredit = status.accountType == AccountType.credito;

    return Scaffold(
      appBar: AppBar(
        title: Text(status.bankName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.goNamed(
              Routes.accountEdit.name,
              pathParameters: {'accountId': status.id},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(status: status, isCredit: isCredit),
          const SizedBox(height: 24),
          Text('Movimientos',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (movements.isEmpty)
            const Text('Sin movimientos registrados.')
          else
            ...movements.map((m) => _MovementTile(movement: m)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AccountStatus status;
  final bool isCredit;
  const _StatusCard({required this.status, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCredit && status.balance != null)
              _Row('Saldo', '\$${status.balance}'),
            if (isCredit) ...[
              if (status.totalOwed != null)
                _Row('Total adeudado', '\$${status.totalOwed}'),
              if (status.availableLimit != null)
                _Row('Disponible', '\$${status.availableLimit}'),
              if (status.utilizationPct != null)
                _Row('Utilización', '${status.utilizationPct!.toStringAsFixed(1)}%'),
              if (status.nextPaymentDate != null)
                _Row('Próximo pago', status.nextPaymentDate!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final AccountMovement movement;
  const _MovementTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isOut = movement.movementType == MovementType.transferOut;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isOut ? Icons.arrow_upward : Icons.arrow_downward,
        color: isOut ? Colors.red : Colors.green,
      ),
      title: Text(movement.note ?? _label(movement.movementType)),
      subtitle: Text(movement.movementDate),
      trailing: Text(
        '\$${movement.amount}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isOut ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  String _label(MovementType t) => switch (t) {
        MovementType.capitalInicial => 'Capital inicial',
        MovementType.ajusteCapital => 'Ajuste de capital',
        MovementType.transferIn => 'Transferencia recibida',
        MovementType.transferOut => 'Transferencia enviada',
      };
}
