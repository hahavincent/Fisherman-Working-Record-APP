import 'dart:typed_data';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show WriteBuffer; // ← 必加
import 'package:camera/camera.dart';

// ML Kit
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// 專案
import 'package:flutter_project/locator.dart';
import 'package:flutter_project/services/camera.service.dart';

class FaceDetectorService {
  final CameraService _cameraService = locator<CameraService>();

  late final FaceDetector _faceDetector;
  List<Face> _faces = [];
  List<Face> get faces => _faces;
  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    // 1) 合併 planes → bytes
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane p in image.planes) {
      allBytes.putUint8List(p.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    // 2) 影像大小與旋轉
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation rotation =
        _cameraService.cameraRotation ?? InputImageRotation.rotation0deg;

    // 3) 影像格式
    final InputImageFormat format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            (Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21);

    // 4) Metadata（你這版沒有 planeData，bytesPerRow 必填）
    final InputImageMetadata metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    // 5) 建 InputImage 丟給 FaceDetector
    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
    _faces = await _faceDetector.processImage(inputImage);
  }

  void dispose() {
    _faceDetector.close();
  }
}
