import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class OverlayImageProcessor {
  static Future<Uint8List?> applyOverlay({
    required Uint8List imageBytes,
    required String compassDirection,
    required String latitude,
    required String longitude,
    required String altitude,
    required String timestamp,
  }) async {
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // Draw the original image first
    canvas.drawImage(originalImage, Offset.zero, paint);

    // Text style for overlay
    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: ui.FontWeight.bold,
    );

    final textPaint = ui.Paint()..color = Colors.black.withOpacity(0.6);
    final textPadding = 6.0;

    // Function to draw text with a background
    void drawTextWithBackground(Canvas canvas, String text, Offset position) {
      final textSpan = TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: ui.FontWeight.bold,
          ));
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final backgroundRect = Rect.fromLTWH(
        position.dx - textPadding,
        position.dy - textPadding,
        textPainter.width + (2 * textPadding),
        textPainter.height + (2 * textPadding),
      );

      canvas.drawRect(backgroundRect, textPaint);
      textPainter.paint(canvas, position);
    }

    // Positioning elements
    final double padding = 20.0;
    final double imageWidth = originalImage.width.toDouble();
    final double imageHeight = originalImage.height.toDouble();

    // Draw compass direction (Top Center)
    drawTextWithBackground(canvas, "Direction: $compassDirection",
        Offset(imageWidth / 2 - 60, padding));

    // Draw GPS Coordinates (Bottom Left)
    drawTextWithBackground(canvas, "Lat: $latitude, Lng: $longitude",
        Offset(padding, imageHeight - 100));

    // Draw Altitude (Bottom Left below GPS)
    drawTextWithBackground(
        canvas, "Altitude: $altitude", Offset(padding, imageHeight - 70));

    // Draw Timestamp (Bottom Right)
    drawTextWithBackground(
        canvas, timestamp, Offset(imageWidth - 220, imageHeight - 40));

    final picture = recorder.endRecording();
    final img =
        await picture.toImage(originalImage.width, originalImage.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }
}
