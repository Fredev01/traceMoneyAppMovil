import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/credit_card.dart';
import '../cubit/debt_cards_cubit.dart';
import '../cubit/debt_cards_state.dart';
import 'debt_card_form_page.dart';

class DebtCardsPage extends StatefulWidget {
  const DebtCardsPage({super.key});

  @override
  State<DebtCardsPage> createState() => _DebtCardsPageState();
}

class _DebtCardsPageState extends State<DebtCardsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DebtCardsCubit>().loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarjetas (Deudas)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, null),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<DebtCardsCubit, DebtCardsState>(
        listener: (context, state) {
          if (state is DebtCardFormSuccess) {
            context.read<DebtCardsCubit>().loadCards();
          }
          if (state is DebtCardFormError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) => switch (state) {
          DebtCardsInitial() => const SizedBox.shrink(),
          DebtCardsLoading() || DebtCardFormLoading() =>
            const Center(child: CircularProgressIndicator()),
          DebtCardsError(:final message) => Center(child: Text(message)),
          DebtCardsLoaded(:final cards) when cards.isEmpty =>
            const Center(child: Text('Sin tarjetas. Agrega una con el botón +')),
          DebtCardsLoaded(:final cards) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _CardTile(
                card: cards[i],
                onEdit: () => _openForm(context, cards[i]),
              ),
            ),
          DebtCardFormSuccess() => const SizedBox.shrink(),
          DebtCardFormError() => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _openForm(BuildContext context, CreditCard? edit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<DebtCardsCubit>(),
        child: DebtCardFormPage(editCard: edit),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CreditCard card;
  final VoidCallback onEdit;
  const _CardTile({required this.card, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(
        backgroundColor: _parseColor(card.color),
        child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
      ),
      title: Text(card.bankName),
      subtitle: Text('Límite: \$${card.creditLimit}'),
      trailing: IconButton(
        icon: const Icon(Icons.edit_outlined),
        onPressed: onEdit,
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
