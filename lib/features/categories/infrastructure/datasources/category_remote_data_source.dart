import 'package:trace_money/core/network/dio_client.dart';
import '../models/category_model.dart';

class CategoryRemoteDataSource {
  final DioClient _client;
  const CategoryRemoteDataSource(this._client);

  Future<List<CategoryModel>> getCategories() async {
    final res = await _client.dio.get('/expenses/categories');
    return (res.data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> createCategory(Map<String, dynamic> body) async {
    final res =
        await _client.dio.post('/expenses/categories', data: body);
    return res.data['id'] as String;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> body) async {
    await _client.dio.put('/expenses/categories/$id', data: body);
  }
}
