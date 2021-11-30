class BitUnit {
  String bit;

  String unit;

  BitUnit(this.bit, this.unit);
}

BitUnit bitToUnit(int bitNum) {
  late BitUnit result;
  if (bitNum < 1024) {
    result = BitUnit(bitNum.toString(), '');
  } else if (bitNum < 1024 * 1024) {
    result = BitUnit((bitNum / 1024).toStringAsFixed(1), "K");
  } else if (bitNum < 1024 * 1024 * 1024) {
    result = BitUnit((bitNum / (1024 * 1024)).toStringAsFixed(1), 'M');
  } else if (bitNum < 1024 * 1024 * 1024 * 1024) {
    result = BitUnit((bitNum / (1024 * 1024 * 1024)).toStringAsFixed(1), 'G');
  } else {
    result =
        BitUnit((bitNum / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(1), 'T');
  }
  return result;
}

String formatFileSize(bitSpeed) {
  BitUnit bitUnit = bitToUnit(bitSpeed);
  return "${bitUnit.bit}${bitUnit.unit}B";
}

String formatSpeed(bitSpeed) => "${formatFileSize(bitSpeed)}/s";
