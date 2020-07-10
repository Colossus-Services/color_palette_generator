import 'package:color_palette_generator/color_palette_generator.dart';

void main() {

  var basicPalette = ColorPalette.from(['#ff0000','#00ff00','rgba(0,0,255, 0.50)']) ;

  print( 'basicPalette: $basicPalette' ) ;
  // OUTPUT: basicPalette: [#ff0000, #00ff00, rgba(0, 0, 255, 0.5)]

  var colorGenerator = ColorGeneratorFromBasicPalette(basicPalette) ;

  var expandedPalette = colorGenerator.generatePaletteAsColorPalette(6) ;

  print( 'expandedPalette: $expandedPalette' ) ;
  // OUTPUT: basicPalette: [#ff6161, #ff0000, #00ff00, rgba(0, 0, 255, 0.5), #a80000, #00a800]

}
