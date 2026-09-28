import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:plantcare_ai/core/services/remote_diagnosis_service.dart';

class _FakeHttpClient extends http.BaseClient {
  final String body;
  final bool expectDiseaseCapability;

  _FakeHttpClient({
    required this.body,
    this.expectDiseaseCapability = false,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (expectDiseaseCapability && request is http.MultipartRequest) {
      expect(request.fields['capability'], 'disease');
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode(body)),
      200,
      headers: const {'content-type': 'application/json'},
    );
  }
}

Future<File> _imageFixture() async {
  final directory = await Directory.systemTemp.createTemp('plantcare-test-');
  final file = File('${directory.path}/leaf.jpg');
  await file.writeAsBytes(const [0xFF, 0xD8, 0xFF]);
  return file;
}

void main() {
  group('RemoteDiagnosisService', () {
    late File image;

    setUp(() async {
      image = await _imageFixture();
    });

    tearDown(() async {
      if (await image.parent.exists()) {
        await image.parent.delete(recursive: true);
      }
    });

    test('forces expert review for low-confidence results', () async {
      final service = RemoteDiagnosisService(
        endpoint: 'https://inference.example.com/predict',
        client: _FakeHttpClient(
          body: jsonEncode({
            'schema_version': '1.1',
            'capability': 'disease',
            'model_id': 'plant-disease-mobilenetv3',
            'plant_name': 'Tomato',
            'condition': 'Early blight',
            'confidence': 0.41,
            'explanation': 'Leaf symptoms are not sufficiently certain.',
            'needs_expert_review': false,
            'model_version': 'plantvillage-mobilenetv3-38-class',
          }),
          expectDiseaseCapability: true,
        ),
      );

      final result = await service.diagnose(imagePath: image.path);

      expect(result.confidence, 0.41);
      expect(result.needsExpertReview, isTrue);
      expect(result.modelVersion, 'plantvillage-mobilenetv3-38-class');
      expect(result.capability, 'disease');
      expect(result.modelId, 'plant-disease-mobilenetv3');
    });

    test('rejects a response without a model version', () async {
      final service = RemoteDiagnosisService(
        endpoint: 'https://inference.example.com/predict',
        client: _FakeHttpClient(
          body: jsonEncode({
            'plant_name': 'Tomato',
            'condition': 'Healthy',
            'confidence': 0.91,
            'explanation': 'The model returned a healthy classification.',
          }),
        ),
      );

      expect(
        () => service.diagnose(imagePath: image.path),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects confidence values outside the valid range', () async {
      final service = RemoteDiagnosisService(
        endpoint: 'https://inference.example.com/predict',
        client: _FakeHttpClient(
          body: jsonEncode({
            'plant_name': 'Tomato',
            'condition': 'Healthy',
            'confidence': 1.4,
            'explanation': 'Invalid confidence.',
            'needs_expert_review': false,
            'model_version': 'test-model',
          }),
        ),
      );

      expect(
        () => service.diagnose(imagePath: image.path),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
