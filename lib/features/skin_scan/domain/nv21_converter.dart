import 'dart:typed_data';

/// Repacks an Android camera frame into the byte layout ML Kit expects.
///
/// Android hands out `YUV_420_888`, which is a *family* of layouts rather than
/// one: the three planes may be planar or semi-planar, the chroma planes may be
/// interleaved with each other, and every plane carries its own row stride that
/// is often wider than the image because the hardware pads each line. ML Kit,
/// meanwhile, wants NV21: the full luma plane followed by V and U interleaved,
/// tightly packed with no padding at all.
///
/// Getting this wrong does not crash. It produces a skewed or false-coloured
/// image in which no face is ever found, and the scan simply times out — which
/// is why this lives in its own pure function with tests rather than inline in
/// a camera callback where it can only be checked by holding up a face.
Uint8List yuv420ToNv21({
  required int width,
  required int height,
  required Uint8List yBytes,
  required Uint8List uBytes,
  required Uint8List vBytes,
  required int yRowStride,
  required int uRowStride,
  required int vRowStride,
  required int uPixelStride,
  required int vPixelStride,
}) {
  final ySize = width * height;
  // Chroma is quarter resolution in each axis and two components per sample,
  // so exactly half the luma size.
  final out = Uint8List(ySize + ySize ~/ 2);

  // Luma, one row at a time: copying the plane wholesale would drag in the
  // stride padding at the end of every line and shear the image.
  var idx = 0;
  for (var row = 0; row < height; row++) {
    out.setRange(idx, idx + width, yBytes, row * yRowStride);
    idx += width;
  }

  // Chroma, V before U — that ordering is the whole difference between NV21
  // and NV12, and swapping it turns skin tones blue.
  for (var row = 0; row < height ~/ 2; row++) {
    for (var col = 0; col < width ~/ 2; col++) {
      final vi = row * vRowStride + col * vPixelStride;
      final ui = row * uRowStride + col * uPixelStride;
      // Guarded reads: a short final row is legal in the format, and 128 is
      // neutral chroma, so a truncated plane greys out rather than throwing
      // inside a camera callback where nothing would catch it.
      out[idx++] = vi < vBytes.length ? vBytes[vi] : 128;
      out[idx++] = ui < uBytes.length ? uBytes[ui] : 128;
    }
  }

  return out;
}
