import 'package:trace_money/core/network/dio_client.dart';
import '../models/account_model.dart';
import '../models/account_movement_model.dart';
import '../models/account_status_model.dart';

class AccountRemoteDataSource {
  final DioClient _client;
  const AccountRemoteDataSource(this._client);

  Future<List<AccountModel>> getAccounts() async {
    final res = await _client.dio.get('/accounts');
    return (res.data as List)
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createAccount(Map<String, dynamic> body) async {
    final res = await _client.dio.post('/accounts', data: body);
    return res.data['id'] as String;
  }

  Future<void> updateAccount(String id, Map<String, dynamic> body) async {
    await _client.dio.put('/accounts/$id', data: body);
  }

  Future<void> deleteAccount(String id) async {
    await _client.dio.delete('/accounts/$id');
  }

  Future<void> assignCapital(
      String accountId, Map<String, dynamic> body) async {
    await _client.dio.post('/accounts/$accountId/capital', data: body);
  }

  Future<void> transfer(
      String sourceAccountId, Map<String, dynamic> body) async {
    await _client.dio.post('/accounts/$sourceAccountId/transfer', data: body);
  }

  Future<AccountStatusModel> getAccountStatus(String id) async {
    final res = await _client.dio.get('/accounts/$id/status');
    return AccountStatusModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<AccountMovementModel>> getAccountMovements(String id) async {
    final res = await _client.dio.get('/accounts/$id/movements');
    return (res.data as List)
        .map((e) => AccountMovementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
