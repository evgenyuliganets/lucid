import 'dart:io';
import 'dart:typed_data';

/// Encodes raw RGBA pixels (as `ui.Image.toByteData()` returns them) of a
/// [width] x [height] image as a PNG without an alpha channel.
///
/// `ui.Image` only encodes RGBA PNGs, but iOS rejects app icons with alpha and
/// Google Play wants 24-bit PNGs for the feature graphic and screenshots.
Uint8List encodeRgbPng(Uint8List rgba, int width, int height) {
  final raw = Uint8List(height * (1 + width * 3));
  var out = 0;
  for (var y = 0; y < height; y++) {
    raw[out++] = 0; // filter: none
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      raw[out++] = rgba[i];
      raw[out++] = rgba[i + 1];
      raw[out++] = rgba[i + 2];
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 2); // colour type: RGB
  return (BytesBuilder(copy: false)
        ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        ..add(_chunk('IHDR', header.buffer.asUint8List()))
        ..add(_chunk('IDAT', ZLibCodec(level: 9).encode(raw)))
        ..add(_chunk('IEND', Uint8List(0))))
      .takeBytes();
}

Uint8List _chunk(String type, List<int> data) {
  final chunk = ByteData(12 + data.length)..setUint32(0, data.length);
  final bytes = chunk.buffer.asUint8List()
    ..setRange(4, 8, type.codeUnits)
    ..setRange(8, 8 + data.length, data);
  // The CRC covers the chunk type and data, not the length.
  chunk.setUint32(8 + data.length, _crc32(bytes, 4, 8 + data.length));
  return bytes;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var bit = 0; bit < 8; bit++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(Uint8List bytes, int start, int end) {
  var crc = 0xFFFFFFFF;
  for (var i = start; i < end; i++) {
    crc = _crcTable[(crc ^ bytes[i]) & 0xFF] ^ (crc >> 8);
  }
  return crc ^ 0xFFFFFFFF;
}
