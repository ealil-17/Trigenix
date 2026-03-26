import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // Point this to your machine's local IP or localhost. For Android emulator, use 10.0.2.2.
    // For iOS emulator or web, use 127.0.0.1.
    baseUrl: 'http://127.0.0.1:8000',
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
      throw Exception('Failed to upload and predict. Ensure the backend is running at 127.0.0.1:8000. Error: $e');
    }
  }
}
