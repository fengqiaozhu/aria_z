String bitToUnit(int bitNum) {
  String result = '';
  if (bitNum < 1024) {
    result = "$bitNum B";
  } else if (bitNum < 1024 * 1024) {
    result = "${(bitNum / 1024).toStringAsFixed(1)} KB";
  } else if (bitNum < 1024 * 1024 * 1024) {
    result = "${(bitNum / (1024 * 1024)).toStringAsFixed(1)} MB";
  } else if (bitNum < 1024 * 1024 * 1024 * 1024) {
    result = "${(bitNum / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB";
  } else {
    result = "${(bitNum / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1)} TB";
  }
  return result;
}