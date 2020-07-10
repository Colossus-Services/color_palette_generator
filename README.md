# color_palette_generator

[![pub package](https://img.shields.io/pub/v/color_palette_generator.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/color_palette_generator)
[![CI](https://img.shields.io/github/workflow/status/Colossus-Services/color_palette_generator/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/Colossus-Services/color_palette_generator?logo=git&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator/releases)
[![New Commits](https://img.shields.io/github/commits-since/Colossus-Services/color_palette_generator/latest?logo=git&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator/network)
[![Last Commits](https://img.shields.io/github/last-commit/Colossus-Services/color_palette_generator?logo=git&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/Colossus-Services/color_palette_generator?logo=github&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/Colossus-Services/color_palette_generator?logo=github&logoColor=white)](https://github.com/Colossus-Services/color_palette_generator)
[![License](https://img.shields.io/github/license/Colossus-Services/color_palette_generator?logo=open-source-initiative&logoColor=green)](https://github.com/Colossus-Services/color_palette_generator/blob/master/LICENSE)

Color palette generator, capable to generate N colors using a set of basic colors.

Supports HEX and RGBA colors.

## Usage

A simple usage example:

```dart
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

```


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Colossus-Services/color_palette_generator/issues

## Colossus.Services

This is an open-source project from [Colossus.Services][colossus]:
the gateway for smooth solutions.

[colossus]: https://colossus.services/

## Author

Graciliano M. Passos: [gmpassos@GitHub][gmpassos_github].

[gmpassos_github]: https://github.com/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt
