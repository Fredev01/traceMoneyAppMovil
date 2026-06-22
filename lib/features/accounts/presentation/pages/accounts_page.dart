import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trace_money/router/routes.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../cubit/accounts_cubit.dart';
import '../cubit/accounts_state.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(Routes.accountNew.name),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<AccountsCubit, AccountsState>(
        builder: (context, state) => switch (state) {
          AccountsInitial() => const SizedBox.shrink(),
          AccountsLoading() =>
            const Center(child: CircularProgressIndicator()),
          AccountsError(:final message) =>
            _ErrorView(message: message, onRetry: () => context.read<AccountsCubit>().loadAccounts()),
          AccountsLoaded(:final accounts) when accounts.isEmpty =>
            const Center(child: Text('Sin cuentas. Crea una con el botón +')),
          AccountsLoaded(:final accounts) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _AccountTile(account: accounts[i]),
            ),
        },
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final Account account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context) {
    final isCredit = account.accountType == AccountType.credito;
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: _parseColor(account.color),
        child: Icon(
          isCredit ? Icons.credit_card : Icons.account_balance,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(account.bankName),
      subtitle: Text(isCredit ? 'Crédito' : 'Débito'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.goNamed(
        Routes.accountDetail.name,
        pathParameters: {'accountId': account.id},
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.indigo;
    }
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
