import 'dart:math';

/// Determine a random number between the min and max
double randomInRange(int min, int max) {
  final random = Random();
  return (min + random.nextInt(max - min + 1)).toDouble();
}
