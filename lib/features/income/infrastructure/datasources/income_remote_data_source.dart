import 'package:trace_money/core/network/dio_client.dart';
import '../models/income_model.dart';

class IncomeRemoteDataSource {
  final DioClient _client;
  const IncomeRemoteDataSource(this._client);

  Future<List<IncomeModel>> getIncomeByMonth(int year, int month) async {
    final res = await _client.dio
        .get('/income/month', queryParameters: {'year': year, 'month': month});
    return (res.data as List)
        .map((e) => IncomeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createIncome(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/income', data: body);
    return res.data['id'] as String;
  }

  Future<void> updateIncome(String id, Map<String, dynamic> body) async {
    await _client.dio.put('/income/$id', data: body);
  }

  Future<void> deleteIncome(String id) async {
    await _client.dio.delete('/income/$id');
  }
}
