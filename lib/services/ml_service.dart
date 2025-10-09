import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:flutter_project/class/Globals.dart';
import 'package:flutter_project/database/databse_helper.dart';
import 'package:flutter_project/services/image_converter.dart';

// image v4
import 'package:image/image.dart' as imglib;

// 重要：兩個套件都加別名，避免符號衝突 / 未解析
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as ml;

class MLService {
  tfl.Interpreter? _interpreter;
  tfl.Delegate? _gpuDelegate; // 記錄 GPU delegate（可選）

  double threshold = 0.5;

  List _predictedData = [];
  List get predictedData => _predictedData;

  Future<bool> initialize() async {
    final options = tfl.InterpreterOptions();

    // 嘗試加 GPU（不使用任何枚舉；舊版也能跑）
    try {
      if (Platform.isAndroid) {
        _gpuDelegate = tfl.GpuDelegateV2(
          options: tfl.GpuDelegateOptionsV2(), // 不設 enum，走預設
        );
        options.addDelegate(_gpuDelegate!);
      } else if (Platform.isIOS) {
        _gpuDelegate = tfl.GpuDelegate(
          options: tfl.GpuDelegateOptions(), // 不設 waitType enum
        );
        options.addDelegate(_gpuDelegate!);
      }
    } catch (_) {
      // 某些版本沒有 GPU 類別，直接忽略，讓它走 CPU
    }

    try {
      _interpreter = await tfl.Interpreter.fromAsset(
        'mobilefacenet.tflite',
        options: options,
      );
      return true;
    } catch (e) {
      debugPrint('TFLite 以 GPU 建立失敗，改走 CPU：$e');
      try {
        _interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite');
        return true;
      } catch (e2) {
        debugPrint('TFLite CPU 也失敗：$e2');
        return false;
      }
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, ml.Face? face) {
    if (face == null) throw Exception('Face is null');
    if (_interpreter == null) throw Exception('Interpreter is null');

    List input = _preProcess(cameraImage, face);
    input = input.reshape([1, 112, 112, 3]);

    final output = List.generate(1, (_) => List.filled(192, 0.0));
    _interpreter!.run(input, output);

    _predictedData = List.from(output.reshape([192]));
  }

  Future<User?> predict() async => _searchResult(_predictedData);

  // ======== 前處理 ========

  List _preProcess(CameraImage image, ml.Face faceDetected) {
    final imglib.Image croppedImage = _cropFace(image, faceDetected);
    final imglib.Image img = imglib.copyResizeCropSquare(
      croppedImage,
      size: 112, // v4 需要命名參數
    );
    final Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, ml.Face faceDetected) {
    final imglib.Image convertedImage = _convertCameraImage(image);
    final double x = faceDetected.boundingBox.left - 10.0;
    final double y = faceDetected.boundingBox.top - 10.0;
    final double w = faceDetected.boundingBox.width + 10.0;
    final double h = faceDetected.boundingBox.height + 10.0;

    return imglib.copyCrop(
      convertedImage,
      x: x.round(),
      y: y.round(),
      width: w.round(),
      height: h.round(),
    );
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    final imglib.Image img = convertToImage(image); // 你先前已修好的轉換
    return imglib.copyRotate(img, angle: -90);       // v4：命名參數
  }

  // v4：用 Pixel.r/g/b
  Float32List imageToByteListFloat32(imglib.Image src) {
    final convertedBytes = Float32List(112 * 112 * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int idx = 0;
    for (int i = 0; i < 112; i++) {
      for (int j = 0; j < 112; j++) {
        final p = src.getPixel(j, i);
        buffer[idx++] = (p.r - 128) / 128.0;
        buffer[idx++] = (p.g - 128) / 128.0;
        buffer[idx++] = (p.b - 128) / 128.0;
      }
    }
    return convertedBytes;
  }

  // ======== 比對 ========

  Future<User?> _searchResult(List predictedData) async {
    final db = DatabaseHelper.instance;
    final List<User> users = await db.queryAllUsers();

    double minDist = double.maxFinite;
    User? predictedResult;

    for (final u in users) {
      final d = _euclideanDistance(u.modelData, predictedData);
      if (d <= threshold && d < minDist) {
        minDist = d;
        predictedResult = u;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception('Null embedding');
    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) => _predictedData = value;

  void dispose() {
    _interpreter?.close();
    // _gpuDelegate 由 interpreter 管理，通常不需額外釋放
  }
}
