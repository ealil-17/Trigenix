import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class ApiServiceException implements Exception {
  final String message;
  final int? statusCode;

  const ApiServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://ealil-hack.portos.cloud',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  List<int> _buildCanonicalEcgCsv(List<int> originalBytes) {
    final decoded = utf8.decode(originalBytes, allowMalformed: true);
    final numberPattern = RegExp(r'[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?');
    final matches = numberPattern.allMatches(decoded);

    if (matches.length < 187) {
      throw const ApiServiceException(
        'Invalid ECG file. Could not find at least 187 numeric ECG values.',
        statusCode: 400,
      );
    }

    final normalizedValues = matches
        .take(187)
        .map((m) => m.group(0)!)
        .join(',');

    return utf8.encode('$normalizedValues\n');
  }

  Future<Map<String, dynamic>> uploadEcgFile(String fileName, List<int> bytes) async {
    try {
      final normalizedBytes = _buildCanonicalEcgCsv(bytes);
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          normalizedBytes,
          filename: fileName,
          contentType: MediaType('text', 'csv'),
        ),
      });

      var response = await _dio.post('/predict', data: formData);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiServiceException('Unexpected response format from server.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String? serverMessage;
      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];
        final message = responseData['message'];
        serverMessage = (detail ?? message)?.toString();
      } else if (responseData is String && responseData.isNotEmpty) {
        serverMessage = responseData;
      }

      if (statusCode == 400) {
        throw ApiServiceException(
          serverMessage ?? 'Invalid CSV format. Please upload a valid ECG CSV with 187 data points.',
          statusCode: statusCode,
        );
      }

      if (statusCode == 500) {
        throw ApiServiceException(
          serverMessage ?? 'Server failed to process this ECG file. Please try another CSV sample.',
          statusCode: statusCode,
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const ApiServiceException('Network error. Please check your internet connection and try again.');
      }

      throw ApiServiceException(
        serverMessage ?? 'Failed to upload ECG data. Please try again.',
        statusCode: statusCode,
      );
    }
  }
}
