import 'package:color_palette_generator/color_palette_generator.dart';

void main() {
  // The basic color palette for color generation:
  var basicPalette =
      ColorPalette.from(['#ff0000', '#00ff00', 'rgba(0,0,255, 0.50)']);

  print('basicPalette: $basicPalette');
  // OUTPUT: basicPalette: [#ff0000, #00ff00, rgba(0, 0, 255, 0.5)]

  var colorGenerator = ColorGeneratorFromBasicPalette(basicPalette);

  // Generates a palette with 6 colors using `basicPalette` as reference.
  var expandedPalette = colorGenerator.generatePaletteAsColorPalette(6);

  print('expandedPalette: $expandedPalette');
  // OUTPUT: basicPalette: [#ff6161, #ff0000, #00ff00, rgba(0, 0, 255, 0.5), #a80000, #00a800]
}
