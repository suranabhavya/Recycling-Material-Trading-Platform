import 'dart:io';
import 'package:dio/dio.dart';

class UploadRepository {
  final Dio _dio;

  UploadRepository(this._dio);

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create multipart request
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Upload to backend
      final response = await _dio.post(
        '/upload/image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data != null && response.data['url'] != null) {
          return response.data['url'] as String;
        } else {
          throw Exception('No URL in response: ${response.data}');
        }
      } else {
        throw Exception('Upload failed with status ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          throw Exception('Server error: ${e.response?.statusCode} - ${e.response?.data}');
        } else {
          throw Exception('Network error: ${e.message}');
        }
      }
      throw Exception('Upload failed: $e');
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];
    final List<String> errors = [];

    for (final file in imageFiles) {
      try {
        final url = await uploadImage(file);
        uploadedUrls.add(url);
      } catch (e) {
        // Collect errors but continue uploading other images
        errors.add('${file.path.split('/').last}: $e');
      }
    }

    // If all uploads failed, throw an error with details
    if (uploadedUrls.isEmpty && errors.isNotEmpty) {
      throw Exception('All uploads failed:\n${errors.join('\n')}');
    }

    // If some uploads failed, we still return the successful ones
    // but you could log the errors here if needed
    return uploadedUrls;
  }
}

