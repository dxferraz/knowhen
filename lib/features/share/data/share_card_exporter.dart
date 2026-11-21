import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captura o card (um [RepaintBoundary]) em PNG e abre a folha de compartilhamento nativa.
class ShareCardExporter {
  const ShareCardExporter._();

  /// PNG do conteúdo de [boundary] com [pixelRatio] (3.0 sobre 360×640 = 1080×1920).
  static Future<Uint8List> capturePng(RenderRepaintBoundary boundary, {required double pixelRatio}) async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Não foi possível codificar o card em PNG');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  /// Grava [png] num arquivo temporário e abre a folha de compartilhamento com [text].
  static Future<ShareResult> sharePng(Uint8List png, {required String text, required String fileName, Rect? origin}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}
