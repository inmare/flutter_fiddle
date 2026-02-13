import 'dart:typed_data';

Float32List bytesToFloat32(List<int> bytes) {
  Uint8List byteList = Uint8List.fromList(bytes);
  return Float32List.view(byteList.buffer);
}
