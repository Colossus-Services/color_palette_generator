import 'package:color_palette_generator/color_palette_generator.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {});

    test('Basic Test', () {
      var basicPalette = ColorPalette.from(['#ff0000', '#00ff00', '#0000ff']);

      var colorGenerator = ColorGeneratorFromBasicPalette(basicPalette);

      expect(colorGenerator.generatePaletteAsString(1), equals(['#ff0000']));

      expect(colorGenerator.generatePaletteAsString(3),
          equals(['#ff0000', '#00ff00', '#0000ff']));

      expect(
          colorGenerator.generatePaletteAsString(6),
          equals([
            '#ff6161',
            '#ff0000',
            '#00ff00',
            '#0000ff',
            '#a80000',
            '#00a800'
          ]));

      expect(
          colorGenerator.generatePaletteAsString(9),
          equals([
            '#ff6161',
            '#61ff61',
            '#6161ff',
            '#ff0000',
            '#00ff00',
            '#0000ff',
            '#a80000',
            '#00a800',
            '#0000a8'
          ]));
    });

    test('Color With Alpha Test', () {
      var basicPalette =
          ColorPalette.from(['#ff0000', 'rgba(0,255,0, 0.50)', '#0000ff']);

      var colorGenerator = ColorGeneratorFromBasicPalette(basicPalette);

      expect(colorGenerator.generatePaletteAsString(1), equals(['#ff0000']));

      expect(colorGenerator.generatePaletteAsString(3),
          equals(['#ff0000', 'rgba(0, 255, 0, 0.5)', '#0000ff']));

      expect(
          colorGenerator.generatePaletteAsString(6),
          equals([
            '#ff6161',
            '#ff0000',
            'rgba(0, 255, 0, 0.5)',
            '#0000ff',
            '#a80000',
            'rgba(0, 168, 0, 0.5)'
          ]));
    });

    test('Invalid Palette Test', () {
      expect(
          () => ColorPalette.from([]), throwsA(TypeMatcher<ArgumentError>()));

      expect(() => ColorPalette.from(['#ff0000', '#00ff00', '#ff0000']),
          throwsA(TypeMatcher<ArgumentError>()));
    });

    test('HTMLColor Test', () {
      expect(HTMLColor.from('000').toString(), equals('#000000'));
      expect(HTMLColor.from('000000').toString(), equals('#000000'));

      expect(HTMLColor.from('fff').toString(), equals('#ffffff'));
      expect(HTMLColor.from('ffffff').toString(), equals('#ffffff'));

      expect(HTMLColor.from('rgb(0,0,0)').toString(), equals('#000000'));
      expect(HTMLColor.from('(0,0,0)').toString(), equals('#000000'));

      expect(HTMLColor.from('rgb(0,255,0)').toString(), equals('#00ff00'));

      expect(HTMLColor.from('(0,255,0)').toString(), equals('#00ff00'));

      expect(HTMLColor.from('rgba(200,0,255,1)').toString(), equals('#c800ff'));
      expect(HTMLColor.from('(0,0,255,1)').toString(), equals('#0000ff'));
      expect(HTMLColor.from('(0,0,255,0)').toString(),
          equals('rgba(0, 0, 255, 0.0)'));

      expect(HTMLColor.from('(0,0,0, 0.5)').toString(),
          equals('rgba(0, 0, 0, 0.5)'));
      expect(HTMLColor.from('(10,128,200, 0.5)').toString(),
          equals('rgba(10, 128, 200, 0.5)'));
    });

    test('Invalid HTMLColor Test', () {
      expect(HTMLColor.from(''), isNull);
      expect(HTMLColor.from('!!!'), isNull);
      expect(HTMLColor.from('rgb(0,0,0, -10)'), isNull);

      expect(() => HTMLColor.from('(255,255,255,255)'),
          throwsA(TypeMatcher<ArgumentError>()));
      expect(() => HTMLColor.from('(0,255,0,10)'),
          throwsA(TypeMatcher<ArgumentError>()));

      expect(() => HTMLColor.from('rgba(255,255,255,255)'),
          throwsA(TypeMatcher<ArgumentError>()));
      expect(() => HTMLColor.from('rgba(0,255,0,10)'),
          throwsA(TypeMatcher<ArgumentError>()));
    });
  });

  test('Basic palette', () {
    var colorPalette =
        ColorPalette.from(['#ff0000', '#00ff00', 'rgba(0,0,255, 0.5)']);

    expect(colorPalette.basicColors[0], equals(HTMLColor(255, 0, 0)));
    expect(colorPalette.basicColors[1], equals(HTMLColor(0, 255, 0)));
    expect(colorPalette.basicColors[2], equals(HTMLColor(0, 0, 255, 0.5)));

    expect(colorPalette.generatePalette(1), equals([HTMLColor(255, 0, 0)]));
    expect(colorPalette.generatePalette(2),
        equals([HTMLColor(255, 0, 0), HTMLColor(0, 255, 0)]));
    expect(
        colorPalette.generatePalette(3),
        equals([
          HTMLColor(255, 0, 0),
          HTMLColor(0, 255, 0),
          HTMLColor(0, 0, 255, 0.5)
        ]));
  });

  test('Generate palette', () {
    var colorPalette = ColorPalette.from(['#ff0000', '#00ff00']);

    expect(colorPalette.generateHTMLPalette(3),
        equals(['#ff0000', '#00ff00', '#a80000']));
    expect(colorPalette.generateHTMLPalette(4),
        equals(['#ff6161', '#ff0000', '#00ff00', '#a80000']));
    expect(colorPalette.generateHTMLPalette(5),
        equals(['#ff6161', '#ff0000', '#00ff00', '#a80000', '#00a800']));
    expect(
        colorPalette.generateHTMLPalette(6),
        equals([
          '#ff6161',
          '#61ff61',
          '#ff0000',
          '#00ff00',
          '#a80000',
          '#00a800'
        ]));
    expect(
        colorPalette.generateHTMLPalette(7),
        equals([
          '#ff6161',
          '#61ff61',
          '#ff0000',
          '#00ff00',
          '#a80000',
          '#00a800',
          '#510000'
        ]));
    expect(
        colorPalette.generateHTMLPalette(8),
        equals([
          '#ffc2c2',
          '#ff6161',
          '#61ff61',
          '#ff0000',
          '#00ff00',
          '#a80000',
          '#00a800',
          '#510000'
        ]));
  });
}
