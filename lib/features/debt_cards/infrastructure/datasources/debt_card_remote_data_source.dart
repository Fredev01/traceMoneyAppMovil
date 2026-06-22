import 'package:trace_money/core/network/dio_client.dart';
import '../models/credit_card_model.dart';

class DebtCardRemoteDataSource {
  final DioClient _client;
  const DebtCardRemoteDataSource(this._client);

  Future<List<CreditCardModel>> getDebtCards() async {
    final res = await _client.dio.get('/debts/cards');
    return (res.data as List)
        .map((e) => CreditCardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createDebtCard(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/debts/cards', data: body);
    return res.data['id'] as String;
  }

  Future<void> updateDebtCard(String id, Map<String, dynamic> body) async {
    await _client.dio.put('/debts/cards/$id', data: body);
  }
}
