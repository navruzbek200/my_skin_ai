import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/features/skin_scan/domain/nv21_converter.dart';

/// Builds a luma plane whose every pixel equals `row * 10 + col`, padded out to
/// [rowStride] with 0xFF so any stride bug shows up as those markers leaking
/// into the output instead of as a subtly wrong picture.
Uint8List _lumaPlane(int width, int height, int rowStride) {
  final bytes = Uint8List(rowStride * height)..fillRange(0, rowStride * height, 0xFF);
  for (var row = 0; row < height; row++) {
    for (var col = 0; col < width; col++) {
      bytes[row * rowStride + col] = row * 10 + col;
    }
  }
  return bytes;
}

void main() {
  group('planar layout (separate U and V planes, pixelStride 1)', () {
    test('luma is copied without the row padding', () {
      const w = 4, h = 4, stride = 8; // 4 bytes of padding per row
      final out = yuv420ToNv21(
        width: w,
        height: h,
        yBytes: _lumaPlane(w, h, stride),
        uBytes: Uint8List(4)..fillRange(0, 4, 111),
        vBytes: Uint8List(4)..fillRange(0, 4, 222),
        yRowStride: stride,
        uRowStride: 2,
        vRowStride: 2,
        uPixelStride: 1,
        vPixelStride: 1,
      );

      expect(out.length, w * h + (w * h) ~/ 2);
      // Row-major, tightly packed, no 0xFF padding markers anywhere.
      expect(out.sublist(0, 16), [
        0, 1, 2, 3, //
        10, 11, 12, 13, //
        20, 21, 22, 23, //
        30, 31, 32, 33, //
      ]);
      expect(out.sublist(0, 16), isNot(contains(0xFF)));
    });

    test('chroma is interleaved V first, then U', () {
      const w = 2, h = 2;
      final out = yuv420ToNv21(
        width: w,
        height: h,
        yBytes: Uint8List(4),
        uBytes: Uint8List.fromList([111]),
        vBytes: Uint8List.fromList([222]),
        yRowStride: 2,
        uRowStride: 1,
        vRowStride: 1,
        uPixelStride: 1,
        vPixelStride: 1,
      );

      // NV21, not NV12: V comes first. Swapping these is the classic bug that
      // turns skin blue and stops ML Kit finding a face.
      expect(out.sublist(4), [222, 111]);
    });
  });

  group('semi-planar layout (interleaved chroma, pixelStride 2)', () {
    test('reads every other byte from each chroma plane', () {
      // What most phones actually deliver: one VUVUVU buffer exposed as two
      // planes offset by a byte, both with pixelStride 2.
      const w = 4, h = 2;
      final interleaved = Uint8List.fromList([222, 111, 223, 112]);

      final out = yuv420ToNv21(
        width: w,
        height: h,
        yBytes: Uint8List(8),
        uBytes: interleaved.sublist(1), // U starts one byte in
        vBytes: interleaved,
        yRowStride: 4,
        uRowStride: 4,
        vRowStride: 4,
        uPixelStride: 2,
        vPixelStride: 2,
      );

      expect(out.sublist(8), [222, 111, 223, 112]);
    });
  });

  test('output is always exactly 1.5 bytes per pixel', () {
    for (final size in const [[640, 480], [1280, 720], [320, 240]]) {
      final w = size[0], h = size[1];
      final out = yuv420ToNv21(
        width: w,
        height: h,
        yBytes: Uint8List(w * h),
        uBytes: Uint8List(w * h ~/ 4),
        vBytes: Uint8List(w * h ~/ 4),
        yRowStride: w,
        uRowStride: w ~/ 2,
        vRowStride: w ~/ 2,
        uPixelStride: 1,
        vPixelStride: 1,
      );
      expect(out.length, w * h * 3 ~/ 2, reason: '$w x $h');
    }
  });

  test('a short chroma plane greys out instead of throwing', () {
    // Legal in the format, and this runs inside a camera callback where an
    // exception would go unhandled and kill the stream.
    expect(
      () => yuv420ToNv21(
        width: 4,
        height: 4,
        yBytes: Uint8List(16),
        uBytes: Uint8List(1), // far too short
        vBytes: Uint8List(1),
        yRowStride: 4,
        uRowStride: 2,
        vRowStride: 2,
        uPixelStride: 1,
        vPixelStride: 1,
      ),
      returnsNormally,
    );
  });
}
