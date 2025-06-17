import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

/// A palette of colors to be used in the game.
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  /// The main color, used for background
  PaletteEntry get backgroundMain => const PaletteEntry(Colors.blueGrey);
  PaletteEntry get backgroundMainDark => PaletteEntry(Color.fromARGB(255, 49, 49, 49));

  /// The secondary color, used for various elements
  PaletteEntry get backgroundSecondary => PaletteEntry(Colors.orange[200]!);
}
