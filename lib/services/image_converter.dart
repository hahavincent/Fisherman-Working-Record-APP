import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

imglib.Image convertToImage(CameraImage image) {
  if (image.format.group == ImageFormatGroup.yuv420) {
    return _convertYUV420(image);
  } else if (image.format.group == ImageFormatGroup.bgra8888) {
    return _convertBGRA8888(image);
  }
  throw UnsupportedError('Image format not supported: ${image.format.group}');
}

imglib.Image _convertBGRA8888(CameraImage image) {
  final p0 = image.planes[0];           // BGRA 平面
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: p0.bytes.buffer,             // ← 傳 ByteBuffer，而非 Uint8List
    rowStride: p0.bytesPerRow,          // 建議加，避免行補齊造成花屏
    numChannels: 4,
    order: imglib.ChannelOrder.bgra,    // v4 用 ChannelOrder
  );
}


imglib.Image _convertYUV420(CameraImage image) {
  final int width = image.width;
  final int height = image.height;

  final img = imglib.Image(width: width, height: height);

  final Uint8List y = image.planes[0].bytes;
  final Uint8List u = image.planes[1].bytes;
  final Uint8List v = image.planes[2].bytes;

  final int uvRowStride  = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1; // 有的裝置會是 null

  for (int py = 0; py < height; py++) {
    for (int px = 0; px < width; px++) {
      final int uvIndex = (py >> 1) * uvRowStride + (px >> 1) * uvPixelStride;

      final int yp = y[py * width + px];
      final int up = u[uvIndex];
      final int vp = v[uvIndex];

      // YUV420 → RGB（BT.601）
      final double yf = yp.toDouble();
      final double uf = up.toDouble() - 128.0;
      final double vf = vp.toDouble() - 128.0;

      int r = (yf + 1.402 * vf).round().clamp(0, 255);
      int g = (yf - 0.344136 * uf - 0.714136 * vf).round().clamp(0, 255);
      int b = (yf + 1.772 * uf).round().clamp(0, 255);

      img.setPixelRgba(px, py, r, g, b, 255);
    }
  }

  return img;
}

