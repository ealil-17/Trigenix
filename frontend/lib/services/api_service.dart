import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sna.selfmade.fun/Trigenix/Backend',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> uploadEcgFile(String fileName, List<int> bytes) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType('text', 'csv'),
        ),
      });

      var response = await _dio.post('/predict', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to upload and predict. Ensure the backend is running. Error: $e');
    }
  }
}
