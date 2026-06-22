import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/infrastructure/datasources/account_remote_data_source.dart';
import 'features/accounts/infrastructure/repositories/account_repository_impl.dart';

import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/infrastructure/datasources/category_remote_data_source.dart';
import 'features/categories/infrastructure/repositories/category_repository_impl.dart';

import 'features/income/domain/repositories/income_repository.dart';
import 'features/income/infrastructure/datasources/income_remote_data_source.dart';
import 'features/income/infrastructure/repositories/income_repository_impl.dart';

import 'features/debt_cards/domain/repositories/debt_card_repository.dart';
import 'features/debt_cards/infrastructure/datasources/debt_card_remote_data_source.dart';
import 'features/debt_cards/infrastructure/repositories/debt_card_repository_impl.dart';

void main() {
  final dio = DioClient();
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>(
          create: (_) => AccountRepositoryImpl(AccountRemoteDataSource(dio)),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) => CategoryRepositoryImpl(CategoryRemoteDataSource(dio)),
        ),
        RepositoryProvider<IncomeRepository>(
          create: (_) => IncomeRepositoryImpl(IncomeRemoteDataSource(dio)),
        ),
        RepositoryProvider<DebtCardRepository>(
          create: (_) => DebtCardRepositoryImpl(DebtCardRemoteDataSource(dio)),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TraceMoney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
