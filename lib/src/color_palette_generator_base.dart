import 'dart:collection';

import 'package:swiss_knife/swiss_knife.dart';

typedef GenerateColorFunction = String Function(
    String name, int index, int total);

/// Color generator for Charts Series/Categories.
abstract class ColorGenerator {
  /// Generate a HTML color using the entry [index] and [total] elements in the
  /// Charts as reference. The [name] of the Series/Category is supplied for
  /// advanced implementations.
  String generateColor(String name, int index, int total);

  /// Same as [generateColor] but for disabled element.
  String generateDisabledColor(String name, int index, int total);

  /// Builds a Map with a color for each provided key from parameter [keys].
  Map<C, String> buildColors<C>(List<C> keys) {
    return buildDColorsFromFunction(keys, generateColor);
  }

  /// Builds a Map with a disabled color for each provided key from parameter [keys].
  Map<C, String> buildDisabledColors<C>(List<C> keys) {
    return buildDColorsFromFunction(keys, generateDisabledColor);
  }

  /// Builds a Map with a color for each provided key from parameter [keys] using [generateColorFunction].
  static Map<C, String> buildDColorsFromFunction<C>(
      List<C> keys, GenerateColorFunction generateColorFunction) {
    var colors = <C, String>{};

    var total = keys.length;
    var index = 0;

    for (var k in keys) {
      colors[k] = generateColorFunction('$k', index, total);
      index++;
    }

    return colors;
  }
}

/// Color generator based in a Map of [_schemes]
class SchemeColorGenerator extends ColorGenerator {
  /// The Map of schemes, with scheme name as Key and A List of HTML colors as values.
  final Map<String, List<String>> _schemes;

  /// The current main scheme name.
  String mainScheme;

  SchemeColorGenerator(Map<String, List<String>> schemes, this.mainScheme)
      : _schemes = Map.from(schemes).cast();

  /// Returns a List of scheme names/keys.
  List<String> get schemeNames => _schemes.keys.toList();

  String get defaultSchemeName => _schemes.entries
      .firstWhere((e) => !e.key.contains('disabled'))
      .key
      .replaceFirst(RegExp(r'\d+$'), '');

  String get defaultDisabledSchemeName => _schemes.entries
      .firstWhere((e) {
        var name = e.key.toLowerCase();
        return name.contains('disabled') ||
            name.contains('grey') ||
            name.contains('gray');
      })
      .key
      .replaceFirst(RegExp(r'\d+$'), '');

  List<String> getDefaultSchemeColors(int size) =>
      getSchemeColors(defaultSchemeName, size);

  List<String> getDefaultDisabledSchemeColors(int size) =>
      getSchemeColors(defaultDisabledSchemeName, size);

  final Map<String, List<String>> _resolvedCache = {};

  /// Returns the scheme colors using the [schemeName] and desired [size].
  List<String> getSchemeColors(String schemeName, int size) {
    return _getSchemeColorsCached(schemeName, size, false);
  }

  /// Returns the scheme colors using the [schemeName] and desired [size].
  List<String> getDisabledSchemeColors(String schemeName, int size) {
    var schemeNameDisabled = '${schemeName}Disabled';
    return _getSchemeColorsCached(schemeNameDisabled, size, true);
  }

  List<String> _getSchemeColorsCached(
      String schemeName, int size, bool disabled) {
    var cacheKey = '$schemeName:$size';

    var cached = _resolvedCache[cacheKey];
    if (cached != null) return cached;

    var colors = _getSchemeColorsImpl(schemeName, size, disabled);
    colors ??= disabled
        ? getDefaultDisabledSchemeColors(size)
        : getDefaultSchemeColors(size);

    _resolvedCache[cacheKey] = colors;

    return colors;
  }

  List<String>? _getSchemeColorsImpl(
      String schemeName, int size, bool disabled) {
    var keys = <String>[schemeName];

    for (var i = size; i <= 15; i++) {
      var k = '$schemeName$i';
      keys.add(k);
    }

    for (var i = size - 1; i >= 3; i--) {
      var k = '$schemeName$i';
      keys.add(k);
    }

    var colors = findKeyValue(_schemes, keys, true);

    if (colors == null) {
      keys = keys.map((e) => e.toLowerCase()).toList();
      keys.add(keys.removeAt(0));

      for (var k in keys) {
        for (var schemeK in _schemes.keys) {
          var schemeKLC = schemeK.toLowerCase();
          if (schemeKLC.contains(k)) {
            colors = _schemes[schemeK];
            break;
          }
        }
      }
    }

    return colors;
  }

  @override
  String generateColor(String name, int index, int total) {
    var colors = getSchemeColors(mainScheme, total);
    var idx = index % colors.length;
    var color = colors[idx];
    return color;
  }

  @override
  String generateDisabledColor(String name, int index, int total) {
    var colors = getDisabledSchemeColors(mainScheme, total);
    var idx = index % colors.length;
    var color = colors[idx];
    return color;
  }
}

class StandardColorGenerator extends SchemeColorGenerator {
  /// ColorBrewer: https://github.com/axismaps/colorbrewer/
  /// Apache License 2.0: https://github.com/axismaps/colorbrewer/blob/master/LICENCE.txt
  static const Map<String, List<String>> standardSchemes = {
    'disabled3': [
      'rgba(0,0,0, 0.20)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.60)',
    ],

    'disabled4': [
      'rgba(0,0,0, 0.20)',
      'rgba(0,0,0, 0.33)',
      'rgba(0,0,0, 0.46)',
      'rgba(0,0,0, 0.59)',
    ],

    'disabled5': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.25)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.55)',
      'rgba(0,0,0, 0.70)',
    ],

    'disabled6': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.22)',
      'rgba(0,0,0, 0.34)',
      'rgba(0,0,0, 0.46)',
      'rgba(0,0,0, 0.58)',
      'rgba(0,0,0, 0.70)',
    ],

    'disabled7': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.20)',
      'rgba(0,0,0, 0.30)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.50)',
      'rgba(0,0,0, 0.60)',
      'rgba(0,0,0, 0.70)',
    ],

    'disabled8': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.18)',
      'rgba(0,0,0, 0.26)',
      'rgba(0,0,0, 0.34)',
      'rgba(0,0,0, 0.42)',
      'rgba(0,0,0, 0.50)',
      'rgba(0,0,0, 0.58)',
      'rgba(0,0,0, 0.66)',
    ],

    'disabled9': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.17)',
      'rgba(0,0,0, 0.24)',
      'rgba(0,0,0, 0.31)',
      'rgba(0,0,0, 0.38)',
      'rgba(0,0,0, 0.45)',
      'rgba(0,0,0, 0.52)',
      'rgba(0,0,0, 0.59)',
      'rgba(0,0,0, 0.66)',
    ],

    'disabled10': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.16)',
      'rgba(0,0,0, 0.22)',
      'rgba(0,0,0, 0.28)',
      'rgba(0,0,0, 0.34)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.46)',
      'rgba(0,0,0, 0.52)',
      'rgba(0,0,0, 0.58)',
      'rgba(0,0,0, 0.64)',
    ],

    'disabled11': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.16)',
      'rgba(0,0,0, 0.22)',
      'rgba(0,0,0, 0.28)',
      'rgba(0,0,0, 0.34)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.46)',
      'rgba(0,0,0, 0.52)',
      'rgba(0,0,0, 0.58)',
      'rgba(0,0,0, 0.64)',
      'rgba(0,0,0, 0.70)',
    ],

    'disabled12': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.15)',
      'rgba(0,0,0, 0.20)',
      'rgba(0,0,0, 0.25)',
      'rgba(0,0,0, 0.30)',
      'rgba(0,0,0, 0.35)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.45)',
      'rgba(0,0,0, 0.50)',
      'rgba(0,0,0, 0.55)',
      'rgba(0,0,0, 0.60)',
      'rgba(0,0,0, 0.65)',
    ],

    'disabled13': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.15)',
      'rgba(0,0,0, 0.20)',
      'rgba(0,0,0, 0.25)',
      'rgba(0,0,0, 0.30)',
      'rgba(0,0,0, 0.35)',
      'rgba(0,0,0, 0.40)',
      'rgba(0,0,0, 0.45)',
      'rgba(0,0,0, 0.50)',
      'rgba(0,0,0, 0.55)',
      'rgba(0,0,0, 0.60)',
      'rgba(0,0,0, 0.65)',
      'rgba(0,0,0, 0.70)',
    ],

    'disabled14': [
      'rgba(0,0,0, 0.10)',
      'rgba(0,0,0, 0.14)',
      'rgba(0,0,0, 0.18)',
      'rgba(0,0,0, 0.22)',
      'rgba(0,0,0, 0.26)',
      'rgba(0,0,0, 0.30)',
      'rgba(0,0,0, 0.34)',
      'rgba(0,0,0, 0.38)',
      'rgba(0,0,0, 0.42)',
      'rgba(0,0,0, 0.46)',
      'rgba(0,0,0, 0.50)',
      'rgba(0,0,0, 0.54)',
      'rgba(0,0,0, 0.58)',
      'rgba(0,0,0, 0.62)',
    ],

    'brewer.YlGn3': ['#f7fcb9', '#addd8e', '#31a354'],
    'brewer.YlGn4': ['#ffffcc', '#c2e699', '#78c679', '#238443'],
    'brewer.YlGn5': ['#ffffcc', '#c2e699', '#78c679', '#31a354', '#006837'],
    'brewer.YlGn6': [
      '#ffffcc',
      '#d9f0a3',
      '#addd8e',
      '#78c679',
      '#31a354',
      '#006837'
    ],
    'brewer.YlGn7': [
      '#ffffcc',
      '#d9f0a3',
      '#addd8e',
      '#78c679',
      '#41ab5d',
      '#238443',
      '#005a32'
    ],
    'brewer.YlGn8': [
      '#ffffe5',
      '#f7fcb9',
      '#d9f0a3',
      '#addd8e',
      '#78c679',
      '#41ab5d',
      '#238443',
      '#005a32'
    ],
    'brewer.YlGn9': [
      '#ffffe5',
      '#f7fcb9',
      '#d9f0a3',
      '#addd8e',
      '#78c679',
      '#41ab5d',
      '#238443',
      '#006837',
      '#004529'
    ],

    'brewer.YlGnBu3': ['#edf8b1', '#7fcdbb', '#2c7fb8'],
    'brewer.YlGnBu4': ['#ffffcc', '#a1dab4', '#41b6c4', '#225ea8'],
    'brewer.YlGnBu5': ['#ffffcc', '#a1dab4', '#41b6c4', '#2c7fb8', '#253494'],
    'brewer.YlGnBu6': [
      '#ffffcc',
      '#c7e9b4',
      '#7fcdbb',
      '#41b6c4',
      '#2c7fb8',
      '#253494'
    ],
    'brewer.YlGnBu7': [
      '#ffffcc',
      '#c7e9b4',
      '#7fcdbb',
      '#41b6c4',
      '#1d91c0',
      '#225ea8',
      '#0c2c84'
    ],
    'brewer.YlGnBu8': [
      '#ffffd9',
      '#edf8b1',
      '#c7e9b4',
      '#7fcdbb',
      '#41b6c4',
      '#1d91c0',
      '#225ea8',
      '#0c2c84'
    ],
    'brewer.YlGnBu9': [
      '#ffffd9',
      '#edf8b1',
      '#c7e9b4',
      '#7fcdbb',
      '#41b6c4',
      '#1d91c0',
      '#225ea8',
      '#253494',
      '#081d58'
    ],

    'brewer.GnBu3': ['#e0f3db', '#a8ddb5', '#43a2ca'],
    'brewer.GnBu4': ['#f0f9e8', '#bae4bc', '#7bccc4', '#2b8cbe'],
    'brewer.GnBu5': ['#f0f9e8', '#bae4bc', '#7bccc4', '#43a2ca', '#0868ac'],
    'brewer.GnBu6': [
      '#f0f9e8',
      '#ccebc5',
      '#a8ddb5',
      '#7bccc4',
      '#43a2ca',
      '#0868ac'
    ],
    'brewer.GnBu7': [
      '#f0f9e8',
      '#ccebc5',
      '#a8ddb5',
      '#7bccc4',
      '#4eb3d3',
      '#2b8cbe',
      '#08589e'
    ],
    'brewer.GnBu8': [
      '#f7fcf0',
      '#e0f3db',
      '#ccebc5',
      '#a8ddb5',
      '#7bccc4',
      '#4eb3d3',
      '#2b8cbe',
      '#08589e'
    ],
    'brewer.GnBu9': [
      '#f7fcf0',
      '#e0f3db',
      '#ccebc5',
      '#a8ddb5',
      '#7bccc4',
      '#4eb3d3',
      '#2b8cbe',
      '#0868ac',
      '#084081'
    ],

    'brewer.BuGn3': ['#e5f5f9', '#99d8c9', '#2ca25f'],
    'brewer.BuGn4': ['#edf8fb', '#b2e2e2', '#66c2a4', '#238b45'],
    'brewer.BuGn5': ['#edf8fb', '#b2e2e2', '#66c2a4', '#2ca25f', '#006d2c'],
    'brewer.BuGn6': [
      '#edf8fb',
      '#ccece6',
      '#99d8c9',
      '#66c2a4',
      '#2ca25f',
      '#006d2c'
    ],
    'brewer.BuGn7': [
      '#edf8fb',
      '#ccece6',
      '#99d8c9',
      '#66c2a4',
      '#41ae76',
      '#238b45',
      '#005824'
    ],
    'brewer.BuGn8': [
      '#f7fcfd',
      '#e5f5f9',
      '#ccece6',
      '#99d8c9',
      '#66c2a4',
      '#41ae76',
      '#238b45',
      '#005824'
    ],
    'brewer.BuGn9': [
      '#f7fcfd',
      '#e5f5f9',
      '#ccece6',
      '#99d8c9',
      '#66c2a4',
      '#41ae76',
      '#238b45',
      '#006d2c',
      '#00441b'
    ],

    'brewer.PuBuGn3': ['#ece2f0', '#a6bddb', '#1c9099'],
    'brewer.PuBuGn4': ['#f6eff7', '#bdc9e1', '#67a9cf', '#02818a'],
    'brewer.PuBuGn5': ['#f6eff7', '#bdc9e1', '#67a9cf', '#1c9099', '#016c59'],
    'brewer.PuBuGn6': [
      '#f6eff7',
      '#d0d1e6',
      '#a6bddb',
      '#67a9cf',
      '#1c9099',
      '#016c59'
    ],
    'brewer.PuBuGn7': [
      '#f6eff7',
      '#d0d1e6',
      '#a6bddb',
      '#67a9cf',
      '#3690c0',
      '#02818a',
      '#016450'
    ],
    'brewer.PuBuGn8': [
      '#fff7fb',
      '#ece2f0',
      '#d0d1e6',
      '#a6bddb',
      '#67a9cf',
      '#3690c0',
      '#02818a',
      '#016450'
    ],
    'brewer.PuBuGn9': [
      '#fff7fb',
      '#ece2f0',
      '#d0d1e6',
      '#a6bddb',
      '#67a9cf',
      '#3690c0',
      '#02818a',
      '#016c59',
      '#014636'
    ],

    'brewer.PuBu3': ['#ece7f2', '#a6bddb', '#2b8cbe'],
    'brewer.PuBu4': ['#f1eef6', '#bdc9e1', '#74a9cf', '#0570b0'],
    'brewer.PuBu5': ['#f1eef6', '#bdc9e1', '#74a9cf', '#2b8cbe', '#045a8d'],
    'brewer.PuBu6': [
      '#f1eef6',
      '#d0d1e6',
      '#a6bddb',
      '#74a9cf',
      '#2b8cbe',
      '#045a8d'
    ],
    'brewer.PuBu7': [
      '#f1eef6',
      '#d0d1e6',
      '#a6bddb',
      '#74a9cf',
      '#3690c0',
      '#0570b0',
      '#034e7b'
    ],
    'brewer.PuBu8': [
      '#fff7fb',
      '#ece7f2',
      '#d0d1e6',
      '#a6bddb',
      '#74a9cf',
      '#3690c0',
      '#0570b0',
      '#034e7b'
    ],
    'brewer.PuBu9': [
      '#fff7fb',
      '#ece7f2',
      '#d0d1e6',
      '#a6bddb',
      '#74a9cf',
      '#3690c0',
      '#0570b0',
      '#045a8d',
      '#023858'
    ],

    'brewer.BuPu3': ['#e0ecf4', '#9ebcda', '#8856a7'],
    'brewer.BuPu4': ['#edf8fb', '#b3cde3', '#8c96c6', '#88419d'],
    'brewer.BuPu5': ['#edf8fb', '#b3cde3', '#8c96c6', '#8856a7', '#810f7c'],
    'brewer.BuPu6': [
      '#edf8fb',
      '#bfd3e6',
      '#9ebcda',
      '#8c96c6',
      '#8856a7',
      '#810f7c'
    ],
    'brewer.BuPu7': [
      '#edf8fb',
      '#bfd3e6',
      '#9ebcda',
      '#8c96c6',
      '#8c6bb1',
      '#88419d',
      '#6e016b'
    ],
    'brewer.BuPu8': [
      '#f7fcfd',
      '#e0ecf4',
      '#bfd3e6',
      '#9ebcda',
      '#8c96c6',
      '#8c6bb1',
      '#88419d',
      '#6e016b'
    ],
    'brewer.BuPu9': [
      '#f7fcfd',
      '#e0ecf4',
      '#bfd3e6',
      '#9ebcda',
      '#8c96c6',
      '#8c6bb1',
      '#88419d',
      '#810f7c',
      '#4d004b'
    ],

    'brewer.RdPu3': ['#fde0dd', '#fa9fb5', '#c51b8a'],
    'brewer.RdPu4': ['#feebe2', '#fbb4b9', '#f768a1', '#ae017e'],
    'brewer.RdPu5': ['#feebe2', '#fbb4b9', '#f768a1', '#c51b8a', '#7a0177'],
    'brewer.RdPu6': [
      '#feebe2',
      '#fcc5c0',
      '#fa9fb5',
      '#f768a1',
      '#c51b8a',
      '#7a0177'
    ],
    'brewer.RdPu7': [
      '#feebe2',
      '#fcc5c0',
      '#fa9fb5',
      '#f768a1',
      '#dd3497',
      '#ae017e',
      '#7a0177'
    ],
    'brewer.RdPu8': [
      '#fff7f3',
      '#fde0dd',
      '#fcc5c0',
      '#fa9fb5',
      '#f768a1',
      '#dd3497',
      '#ae017e',
      '#7a0177'
    ],
    'brewer.RdPu9': [
      '#fff7f3',
      '#fde0dd',
      '#fcc5c0',
      '#fa9fb5',
      '#f768a1',
      '#dd3497',
      '#ae017e',
      '#7a0177',
      '#49006a'
    ],

    'brewer.PuRd3': ['#e7e1ef', '#c994c7', '#dd1c77'],
    'brewer.PuRd4': ['#f1eef6', '#d7b5d8', '#df65b0', '#ce1256'],
    'brewer.PuRd5': ['#f1eef6', '#d7b5d8', '#df65b0', '#dd1c77', '#980043'],
    'brewer.PuRd6': [
      '#f1eef6',
      '#d4b9da',
      '#c994c7',
      '#df65b0',
      '#dd1c77',
      '#980043'
    ],
    'brewer.PuRd7': [
      '#f1eef6',
      '#d4b9da',
      '#c994c7',
      '#df65b0',
      '#e7298a',
      '#ce1256',
      '#91003f'
    ],
    'brewer.PuRd8': [
      '#f7f4f9',
      '#e7e1ef',
      '#d4b9da',
      '#c994c7',
      '#df65b0',
      '#e7298a',
      '#ce1256',
      '#91003f'
    ],
    'brewer.PuRd9': [
      '#f7f4f9',
      '#e7e1ef',
      '#d4b9da',
      '#c994c7',
      '#df65b0',
      '#e7298a',
      '#ce1256',
      '#980043',
      '#67001f'
    ],

    'brewer.OrRd3': ['#fee8c8', '#fdbb84', '#e34a33'],
    'brewer.OrRd4': ['#fef0d9', '#fdcc8a', '#fc8d59', '#d7301f'],
    'brewer.OrRd5': ['#fef0d9', '#fdcc8a', '#fc8d59', '#e34a33', '#b30000'],
    'brewer.OrRd6': [
      '#fef0d9',
      '#fdd49e',
      '#fdbb84',
      '#fc8d59',
      '#e34a33',
      '#b30000'
    ],
    'brewer.OrRd7': [
      '#fef0d9',
      '#fdd49e',
      '#fdbb84',
      '#fc8d59',
      '#ef6548',
      '#d7301f',
      '#990000'
    ],
    'brewer.OrRd8': [
      '#fff7ec',
      '#fee8c8',
      '#fdd49e',
      '#fdbb84',
      '#fc8d59',
      '#ef6548',
      '#d7301f',
      '#990000'
    ],
    'brewer.OrRd9': [
      '#fff7ec',
      '#fee8c8',
      '#fdd49e',
      '#fdbb84',
      '#fc8d59',
      '#ef6548',
      '#d7301f',
      '#b30000',
      '#7f0000'
    ],

    'brewer.YlOrRd3': ['#ffeda0', '#feb24c', '#f03b20'],
    'brewer.YlOrRd4': ['#ffffb2', '#fecc5c', '#fd8d3c', '#e31a1c'],
    'brewer.YlOrRd5': ['#ffffb2', '#fecc5c', '#fd8d3c', '#f03b20', '#bd0026'],
    'brewer.YlOrRd6': [
      '#ffffb2',
      '#fed976',
      '#feb24c',
      '#fd8d3c',
      '#f03b20',
      '#bd0026'
    ],
    'brewer.YlOrRd7': [
      '#ffffb2',
      '#fed976',
      '#feb24c',
      '#fd8d3c',
      '#fc4e2a',
      '#e31a1c',
      '#b10026'
    ],
    'brewer.YlOrRd8': [
      '#ffffcc',
      '#ffeda0',
      '#fed976',
      '#feb24c',
      '#fd8d3c',
      '#fc4e2a',
      '#e31a1c',
      '#b10026'
    ],
    'brewer.YlOrRd9': [
      '#ffffcc',
      '#ffeda0',
      '#fed976',
      '#feb24c',
      '#fd8d3c',
      '#fc4e2a',
      '#e31a1c',
      '#bd0026',
      '#800026'
    ],

    'brewer.YlOrBr3': ['#fff7bc', '#fec44f', '#d95f0e'],
    'brewer.YlOrBr4': ['#ffffd4', '#fed98e', '#fe9929', '#cc4c02'],
    'brewer.YlOrBr5': ['#ffffd4', '#fed98e', '#fe9929', '#d95f0e', '#993404'],
    'brewer.YlOrBr6': [
      '#ffffd4',
      '#fee391',
      '#fec44f',
      '#fe9929',
      '#d95f0e',
      '#993404'
    ],
    'brewer.YlOrBr7': [
      '#ffffd4',
      '#fee391',
      '#fec44f',
      '#fe9929',
      '#ec7014',
      '#cc4c02',
      '#8c2d04'
    ],
    'brewer.YlOrBr8': [
      '#ffffe5',
      '#fff7bc',
      '#fee391',
      '#fec44f',
      '#fe9929',
      '#ec7014',
      '#cc4c02',
      '#8c2d04'
    ],
    'brewer.YlOrBr9': [
      '#ffffe5',
      '#fff7bc',
      '#fee391',
      '#fec44f',
      '#fe9929',
      '#ec7014',
      '#cc4c02',
      '#993404',
      '#662506'
    ],

    'brewer.Purples3': ['#efedf5', '#bcbddc', '#756bb1'],
    'brewer.Purples4': ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#6a51a3'],
    'brewer.Purples5': ['#f2f0f7', '#cbc9e2', '#9e9ac8', '#756bb1', '#54278f'],
    'brewer.Purples6': [
      '#f2f0f7',
      '#dadaeb',
      '#bcbddc',
      '#9e9ac8',
      '#756bb1',
      '#54278f'
    ],
    'brewer.Purples7': [
      '#f2f0f7',
      '#dadaeb',
      '#bcbddc',
      '#9e9ac8',
      '#807dba',
      '#6a51a3',
      '#4a1486'
    ],
    'brewer.Purples8': [
      '#fcfbfd',
      '#efedf5',
      '#dadaeb',
      '#bcbddc',
      '#9e9ac8',
      '#807dba',
      '#6a51a3',
      '#4a1486'
    ],
    'brewer.Purples9': [
      '#fcfbfd',
      '#efedf5',
      '#dadaeb',
      '#bcbddc',
      '#9e9ac8',
      '#807dba',
      '#6a51a3',
      '#54278f',
      '#3f007d'
    ],

    'brewer.Blues3': ['#deebf7', '#9ecae1', '#3182bd'],
    'brewer.Blues4': ['#eff3ff', '#bdd7e7', '#6baed6', '#2171b5'],
    'brewer.Blues5': ['#eff3ff', '#bdd7e7', '#6baed6', '#3182bd', '#08519c'],
    'brewer.Blues6': [
      '#eff3ff',
      '#c6dbef',
      '#9ecae1',
      '#6baed6',
      '#3182bd',
      '#08519c'
    ],
    'brewer.Blues7': [
      '#eff3ff',
      '#c6dbef',
      '#9ecae1',
      '#6baed6',
      '#4292c6',
      '#2171b5',
      '#084594'
    ],
    'brewer.Blues8': [
      '#f7fbff',
      '#deebf7',
      '#c6dbef',
      '#9ecae1',
      '#6baed6',
      '#4292c6',
      '#2171b5',
      '#084594'
    ],
    'brewer.Blues9': [
      '#f7fbff',
      '#deebf7',
      '#c6dbef',
      '#9ecae1',
      '#6baed6',
      '#4292c6',
      '#2171b5',
      '#08519c',
      '#08306b'
    ],

    'brewer.Greens3': ['#e5f5e0', '#a1d99b', '#31a354'],
    'brewer.Greens4': ['#edf8e9', '#bae4b3', '#74c476', '#238b45'],
    'brewer.Greens5': ['#edf8e9', '#bae4b3', '#74c476', '#31a354', '#006d2c'],
    'brewer.Greens6': [
      '#edf8e9',
      '#c7e9c0',
      '#a1d99b',
      '#74c476',
      '#31a354',
      '#006d2c'
    ],
    'brewer.Greens7': [
      '#edf8e9',
      '#c7e9c0',
      '#a1d99b',
      '#74c476',
      '#41ab5d',
      '#238b45',
      '#005a32'
    ],
    'brewer.Greens8': [
      '#f7fcf5',
      '#e5f5e0',
      '#c7e9c0',
      '#a1d99b',
      '#74c476',
      '#41ab5d',
      '#238b45',
      '#005a32'
    ],
    'brewer.Greens9': [
      '#f7fcf5',
      '#e5f5e0',
      '#c7e9c0',
      '#a1d99b',
      '#74c476',
      '#41ab5d',
      '#238b45',
      '#006d2c',
      '#00441b'
    ],

    'brewer.Oranges3': ['#fee6ce', '#fdae6b', '#e6550d'],
    'brewer.Oranges4': ['#feedde', '#fdbe85', '#fd8d3c', '#d94701'],
    'brewer.Oranges5': ['#feedde', '#fdbe85', '#fd8d3c', '#e6550d', '#a63603'],
    'brewer.Oranges6': [
      '#feedde',
      '#fdd0a2',
      '#fdae6b',
      '#fd8d3c',
      '#e6550d',
      '#a63603'
    ],
    'brewer.Oranges7': [
      '#feedde',
      '#fdd0a2',
      '#fdae6b',
      '#fd8d3c',
      '#f16913',
      '#d94801',
      '#8c2d04'
    ],
    'brewer.Oranges8': [
      '#fff5eb',
      '#fee6ce',
      '#fdd0a2',
      '#fdae6b',
      '#fd8d3c',
      '#f16913',
      '#d94801',
      '#8c2d04'
    ],
    'brewer.Oranges9': [
      '#fff5eb',
      '#fee6ce',
      '#fdd0a2',
      '#fdae6b',
      '#fd8d3c',
      '#f16913',
      '#d94801',
      '#a63603',
      '#7f2704'
    ],

    'brewer.Reds3': ['#fee0d2', '#fc9272', '#de2d26'],
    'brewer.Reds4': ['#fee5d9', '#fcae91', '#fb6a4a', '#cb181d'],
    'brewer.Reds5': ['#fee5d9', '#fcae91', '#fb6a4a', '#de2d26', '#a50f15'],
    'brewer.Reds6': [
      '#fee5d9',
      '#fcbba1',
      '#fc9272',
      '#fb6a4a',
      '#de2d26',
      '#a50f15'
    ],
    'brewer.Reds7': [
      '#fee5d9',
      '#fcbba1',
      '#fc9272',
      '#fb6a4a',
      '#ef3b2c',
      '#cb181d',
      '#99000d'
    ],
    'brewer.Reds8': [
      '#fff5f0',
      '#fee0d2',
      '#fcbba1',
      '#fc9272',
      '#fb6a4a',
      '#ef3b2c',
      '#cb181d',
      '#99000d'
    ],
    'brewer.Reds9': [
      '#fff5f0',
      '#fee0d2',
      '#fcbba1',
      '#fc9272',
      '#fb6a4a',
      '#ef3b2c',
      '#cb181d',
      '#a50f15',
      '#67000d'
    ],

    'brewer.Greys3': ['#f0f0f0', '#bdbdbd', '#636363'],
    'brewer.Greys4': ['#f7f7f7', '#cccccc', '#969696', '#525252'],
    'brewer.Greys5': ['#f7f7f7', '#cccccc', '#969696', '#636363', '#252525'],
    'brewer.Greys6': [
      '#f7f7f7',
      '#d9d9d9',
      '#bdbdbd',
      '#969696',
      '#636363',
      '#252525'
    ],
    'brewer.Greys7': [
      '#f7f7f7',
      '#d9d9d9',
      '#bdbdbd',
      '#969696',
      '#737373',
      '#525252',
      '#252525'
    ],
    'brewer.Greys8': [
      '#ffffff',
      '#f0f0f0',
      '#d9d9d9',
      '#bdbdbd',
      '#969696',
      '#737373',
      '#525252',
      '#252525'
    ],
    'brewer.Greys9': [
      '#ffffff',
      '#f0f0f0',
      '#d9d9d9',
      '#bdbdbd',
      '#969696',
      '#737373',
      '#525252',
      '#252525',
      '#000000'
    ],

    // Diverging
    'brewer.PuOr3': ['#f1a340', '#f7f7f7', '#998ec3'],
    'brewer.PuOr4': ['#e66101', '#fdb863', '#b2abd2', '#5e3c99'],
    'brewer.PuOr5': ['#e66101', '#fdb863', '#f7f7f7', '#b2abd2', '#5e3c99'],
    'brewer.PuOr6': [
      '#b35806',
      '#f1a340',
      '#fee0b6',
      '#d8daeb',
      '#998ec3',
      '#542788'
    ],
    'brewer.PuOr7': [
      '#b35806',
      '#f1a340',
      '#fee0b6',
      '#f7f7f7',
      '#d8daeb',
      '#998ec3',
      '#542788'
    ],
    'brewer.PuOr8': [
      '#b35806',
      '#e08214',
      '#fdb863',
      '#fee0b6',
      '#d8daeb',
      '#b2abd2',
      '#8073ac',
      '#542788'
    ],
    'brewer.PuOr9': [
      '#b35806',
      '#e08214',
      '#fdb863',
      '#fee0b6',
      '#f7f7f7',
      '#d8daeb',
      '#b2abd2',
      '#8073ac',
      '#542788'
    ],
    'brewer.PuOr10': [
      '#7f3b08',
      '#b35806',
      '#e08214',
      '#fdb863',
      '#fee0b6',
      '#d8daeb',
      '#b2abd2',
      '#8073ac',
      '#542788',
      '#2d004b'
    ],
    'brewer.PuOr11': [
      '#7f3b08',
      '#b35806',
      '#e08214',
      '#fdb863',
      '#fee0b6',
      '#f7f7f7',
      '#d8daeb',
      '#b2abd2',
      '#8073ac',
      '#542788',
      '#2d004b'
    ],

    'brewer.BrBG3': ['#d8b365', '#f5f5f5', '#5ab4ac'],
    'brewer.BrBG4': ['#a6611a', '#dfc27d', '#80cdc1', '#018571'],
    'brewer.BrBG5': ['#a6611a', '#dfc27d', '#f5f5f5', '#80cdc1', '#018571'],
    'brewer.BrBG6': [
      '#8c510a',
      '#d8b365',
      '#f6e8c3',
      '#c7eae5',
      '#5ab4ac',
      '#01665e'
    ],
    'brewer.BrBG7': [
      '#8c510a',
      '#d8b365',
      '#f6e8c3',
      '#f5f5f5',
      '#c7eae5',
      '#5ab4ac',
      '#01665e'
    ],
    'brewer.BrBG8': [
      '#8c510a',
      '#bf812d',
      '#dfc27d',
      '#f6e8c3',
      '#c7eae5',
      '#80cdc1',
      '#35978f',
      '#01665e'
    ],
    'brewer.BrBG9': [
      '#8c510a',
      '#bf812d',
      '#dfc27d',
      '#f6e8c3',
      '#f5f5f5',
      '#c7eae5',
      '#80cdc1',
      '#35978f',
      '#01665e'
    ],
    'brewer.BrBG10': [
      '#543005',
      '#8c510a',
      '#bf812d',
      '#dfc27d',
      '#f6e8c3',
      '#c7eae5',
      '#80cdc1',
      '#35978f',
      '#01665e',
      '#003c30'
    ],
    'brewer.BrBG11': [
      '#543005',
      '#8c510a',
      '#bf812d',
      '#dfc27d',
      '#f6e8c3',
      '#f5f5f5',
      '#c7eae5',
      '#80cdc1',
      '#35978f',
      '#01665e',
      '#003c30'
    ],

    'brewer.PRGn3': ['#af8dc3', '#f7f7f7', '#7fbf7b'],
    'brewer.PRGn4': ['#7b3294', '#c2a5cf', '#a6dba0', '#008837'],
    'brewer.PRGn5': ['#7b3294', '#c2a5cf', '#f7f7f7', '#a6dba0', '#008837'],
    'brewer.PRGn6': [
      '#762a83',
      '#af8dc3',
      '#e7d4e8',
      '#d9f0d3',
      '#7fbf7b',
      '#1b7837'
    ],
    'brewer.PRGn7': [
      '#762a83',
      '#af8dc3',
      '#e7d4e8',
      '#f7f7f7',
      '#d9f0d3',
      '#7fbf7b',
      '#1b7837'
    ],
    'brewer.PRGn8': [
      '#762a83',
      '#9970ab',
      '#c2a5cf',
      '#e7d4e8',
      '#d9f0d3',
      '#a6dba0',
      '#5aae61',
      '#1b7837'
    ],
    'brewer.PRGn9': [
      '#762a83',
      '#9970ab',
      '#c2a5cf',
      '#e7d4e8',
      '#f7f7f7',
      '#d9f0d3',
      '#a6dba0',
      '#5aae61',
      '#1b7837'
    ],
    'brewer.PRGn10': [
      '#40004b',
      '#762a83',
      '#9970ab',
      '#c2a5cf',
      '#e7d4e8',
      '#d9f0d3',
      '#a6dba0',
      '#5aae61',
      '#1b7837',
      '#00441b'
    ],
    'brewer.PRGn11': [
      '#40004b',
      '#762a83',
      '#9970ab',
      '#c2a5cf',
      '#e7d4e8',
      '#f7f7f7',
      '#d9f0d3',
      '#a6dba0',
      '#5aae61',
      '#1b7837',
      '#00441b'
    ],

    'brewer.PiYG3': ['#e9a3c9', '#f7f7f7', '#a1d76a'],
    'brewer.PiYG4': ['#d01c8b', '#f1b6da', '#b8e186', '#4dac26'],
    'brewer.PiYG5': ['#d01c8b', '#f1b6da', '#f7f7f7', '#b8e186', '#4dac26'],
    'brewer.PiYG6': [
      '#c51b7d',
      '#e9a3c9',
      '#fde0ef',
      '#e6f5d0',
      '#a1d76a',
      '#4d9221'
    ],
    'brewer.PiYG7': [
      '#c51b7d',
      '#e9a3c9',
      '#fde0ef',
      '#f7f7f7',
      '#e6f5d0',
      '#a1d76a',
      '#4d9221'
    ],
    'brewer.PiYG8': [
      '#c51b7d',
      '#de77ae',
      '#f1b6da',
      '#fde0ef',
      '#e6f5d0',
      '#b8e186',
      '#7fbc41',
      '#4d9221'
    ],
    'brewer.PiYG9': [
      '#c51b7d',
      '#de77ae',
      '#f1b6da',
      '#fde0ef',
      '#f7f7f7',
      '#e6f5d0',
      '#b8e186',
      '#7fbc41',
      '#4d9221'
    ],
    'brewer.PiYG10': [
      '#8e0152',
      '#c51b7d',
      '#de77ae',
      '#f1b6da',
      '#fde0ef',
      '#e6f5d0',
      '#b8e186',
      '#7fbc41',
      '#4d9221',
      '#276419'
    ],
    'brewer.PiYG11': [
      '#8e0152',
      '#c51b7d',
      '#de77ae',
      '#f1b6da',
      '#fde0ef',
      '#f7f7f7',
      '#e6f5d0',
      '#b8e186',
      '#7fbc41',
      '#4d9221',
      '#276419'
    ],

    'brewer.RdBu3': ['#ef8a62', '#f7f7f7', '#67a9cf'],
    'brewer.RdBu4': ['#ca0020', '#f4a582', '#92c5de', '#0571b0'],
    'brewer.RdBu5': ['#ca0020', '#f4a582', '#f7f7f7', '#92c5de', '#0571b0'],
    'brewer.RdBu6': [
      '#b2182b',
      '#ef8a62',
      '#fddbc7',
      '#d1e5f0',
      '#67a9cf',
      '#2166ac'
    ],
    'brewer.RdBu7': [
      '#b2182b',
      '#ef8a62',
      '#fddbc7',
      '#f7f7f7',
      '#d1e5f0',
      '#67a9cf',
      '#2166ac'
    ],
    'brewer.RdBu8': [
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#d1e5f0',
      '#92c5de',
      '#4393c3',
      '#2166ac'
    ],
    'brewer.RdBu9': [
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#f7f7f7',
      '#d1e5f0',
      '#92c5de',
      '#4393c3',
      '#2166ac'
    ],
    'brewer.RdBu10': [
      '#67001f',
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#d1e5f0',
      '#92c5de',
      '#4393c3',
      '#2166ac',
      '#053061'
    ],
    'brewer.RdBu11': [
      '#67001f',
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#f7f7f7',
      '#d1e5f0',
      '#92c5de',
      '#4393c3',
      '#2166ac',
      '#053061'
    ],

    'brewer.RdGy3': ['#ef8a62', '#ffffff', '#999999'],
    'brewer.RdGy4': ['#ca0020', '#f4a582', '#bababa', '#404040'],
    'brewer.RdGy5': ['#ca0020', '#f4a582', '#ffffff', '#bababa', '#404040'],
    'brewer.RdGy6': [
      '#b2182b',
      '#ef8a62',
      '#fddbc7',
      '#e0e0e0',
      '#999999',
      '#4d4d4d'
    ],
    'brewer.RdGy7': [
      '#b2182b',
      '#ef8a62',
      '#fddbc7',
      '#ffffff',
      '#e0e0e0',
      '#999999',
      '#4d4d4d'
    ],
    'brewer.RdGy8': [
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#e0e0e0',
      '#bababa',
      '#878787',
      '#4d4d4d'
    ],
    'brewer.RdGy9': [
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#ffffff',
      '#e0e0e0',
      '#bababa',
      '#878787',
      '#4d4d4d'
    ],
    'brewer.RdGy10': [
      '#67001f',
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#e0e0e0',
      '#bababa',
      '#878787',
      '#4d4d4d',
      '#1a1a1a'
    ],
    'brewer.RdGy11': [
      '#67001f',
      '#b2182b',
      '#d6604d',
      '#f4a582',
      '#fddbc7',
      '#ffffff',
      '#e0e0e0',
      '#bababa',
      '#878787',
      '#4d4d4d',
      '#1a1a1a'
    ],

    'brewer.RdYlBu3': ['#fc8d59', '#ffffbf', '#91bfdb'],
    'brewer.RdYlBu4': ['#d7191c', '#fdae61', '#abd9e9', '#2c7bb6'],
    'brewer.RdYlBu5': ['#d7191c', '#fdae61', '#ffffbf', '#abd9e9', '#2c7bb6'],
    'brewer.RdYlBu6': [
      '#d73027',
      '#fc8d59',
      '#fee090',
      '#e0f3f8',
      '#91bfdb',
      '#4575b4'
    ],
    'brewer.RdYlBu7': [
      '#d73027',
      '#fc8d59',
      '#fee090',
      '#ffffbf',
      '#e0f3f8',
      '#91bfdb',
      '#4575b4'
    ],
    'brewer.RdYlBu8': [
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee090',
      '#e0f3f8',
      '#abd9e9',
      '#74add1',
      '#4575b4'
    ],
    'brewer.RdYlBu9': [
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee090',
      '#ffffbf',
      '#e0f3f8',
      '#abd9e9',
      '#74add1',
      '#4575b4'
    ],
    'brewer.RdYlBu10': [
      '#a50026',
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee090',
      '#e0f3f8',
      '#abd9e9',
      '#74add1',
      '#4575b4',
      '#313695'
    ],
    'brewer.RdYlBu11': [
      '#a50026',
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee090',
      '#ffffbf',
      '#e0f3f8',
      '#abd9e9',
      '#74add1',
      '#4575b4',
      '#313695'
    ],

    'brewer.Spectral3': ['#fc8d59', '#ffffbf', '#99d594'],
    'brewer.Spectral4': ['#d7191c', '#fdae61', '#abdda4', '#2b83ba'],
    'brewer.Spectral5': ['#d7191c', '#fdae61', '#ffffbf', '#abdda4', '#2b83ba'],
    'brewer.Spectral6': [
      '#d53e4f',
      '#fc8d59',
      '#fee08b',
      '#e6f598',
      '#99d594',
      '#3288bd'
    ],
    'brewer.Spectral7': [
      '#d53e4f',
      '#fc8d59',
      '#fee08b',
      '#ffffbf',
      '#e6f598',
      '#99d594',
      '#3288bd'
    ],
    'brewer.Spectral8': [
      '#d53e4f',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#e6f598',
      '#abdda4',
      '#66c2a5',
      '#3288bd'
    ],
    'brewer.Spectral9': [
      '#d53e4f',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#ffffbf',
      '#e6f598',
      '#abdda4',
      '#66c2a5',
      '#3288bd'
    ],
    'brewer.Spectral10': [
      '#9e0142',
      '#d53e4f',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#e6f598',
      '#abdda4',
      '#66c2a5',
      '#3288bd',
      '#5e4fa2'
    ],
    'brewer.Spectral11': [
      '#9e0142',
      '#d53e4f',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#ffffbf',
      '#e6f598',
      '#abdda4',
      '#66c2a5',
      '#3288bd',
      '#5e4fa2'
    ],

    'brewer.RdYlGn3': ['#fc8d59', '#ffffbf', '#91cf60'],
    'brewer.RdYlGn4': ['#d7191c', '#fdae61', '#a6d96a', '#1a9641'],
    'brewer.RdYlGn5': ['#d7191c', '#fdae61', '#ffffbf', '#a6d96a', '#1a9641'],
    'brewer.RdYlGn6': [
      '#d73027',
      '#fc8d59',
      '#fee08b',
      '#d9ef8b',
      '#91cf60',
      '#1a9850'
    ],
    'brewer.RdYlGn7': [
      '#d73027',
      '#fc8d59',
      '#fee08b',
      '#ffffbf',
      '#d9ef8b',
      '#91cf60',
      '#1a9850'
    ],
    'brewer.RdYlGn8': [
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#d9ef8b',
      '#a6d96a',
      '#66bd63',
      '#1a9850'
    ],
    'brewer.RdYlGn9': [
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#ffffbf',
      '#d9ef8b',
      '#a6d96a',
      '#66bd63',
      '#1a9850'
    ],
    'brewer.RdYlGn10': [
      '#a50026',
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#d9ef8b',
      '#a6d96a',
      '#66bd63',
      '#1a9850',
      '#006837'
    ],
    'brewer.RdYlGn11': [
      '#a50026',
      '#d73027',
      '#f46d43',
      '#fdae61',
      '#fee08b',
      '#ffffbf',
      '#d9ef8b',
      '#a6d96a',
      '#66bd63',
      '#1a9850',
      '#006837'
    ],

    // Qualitative
    'brewer.Accent3': ['#7fc97f', '#beaed4', '#fdc086'],
    'brewer.Accent4': ['#7fc97f', '#beaed4', '#fdc086', '#ffff99'],
    'brewer.Accent5': ['#7fc97f', '#beaed4', '#fdc086', '#ffff99', '#386cb0'],
    'brewer.Accent6': [
      '#7fc97f',
      '#beaed4',
      '#fdc086',
      '#ffff99',
      '#386cb0',
      '#f0027f'
    ],
    'brewer.Accent7': [
      '#7fc97f',
      '#beaed4',
      '#fdc086',
      '#ffff99',
      '#386cb0',
      '#f0027f',
      '#bf5b17'
    ],
    'brewer.Accent8': [
      '#7fc97f',
      '#beaed4',
      '#fdc086',
      '#ffff99',
      '#386cb0',
      '#f0027f',
      '#bf5b17',
      '#666666'
    ],

    'brewer.DarkTwo3': ['#1b9e77', '#d95f02', '#7570b3'],
    'brewer.DarkTwo4': ['#1b9e77', '#d95f02', '#7570b3', '#e7298a'],
    'brewer.DarkTwo5': ['#1b9e77', '#d95f02', '#7570b3', '#e7298a', '#66a61e'],
    'brewer.DarkTwo6': [
      '#1b9e77',
      '#d95f02',
      '#7570b3',
      '#e7298a',
      '#66a61e',
      '#e6ab02'
    ],
    'brewer.DarkTwo7': [
      '#1b9e77',
      '#d95f02',
      '#7570b3',
      '#e7298a',
      '#66a61e',
      '#e6ab02',
      '#a6761d'
    ],
    'brewer.DarkTwo8': [
      '#1b9e77',
      '#d95f02',
      '#7570b3',
      '#e7298a',
      '#66a61e',
      '#e6ab02',
      '#a6761d',
      '#666666'
    ],

    'brewer.Paired3': ['#a6cee3', '#1f78b4', '#b2df8a'],
    'brewer.Paired4': ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c'],
    'brewer.Paired5': ['#a6cee3', '#1f78b4', '#b2df8a', '#33a02c', '#fb9a99'],
    'brewer.Paired6': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c'
    ],
    'brewer.Paired7': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f'
    ],
    'brewer.Paired8': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f',
      '#ff7f00'
    ],
    'brewer.Paired9': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f',
      '#ff7f00',
      '#cab2d6'
    ],
    'brewer.Paired10': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f',
      '#ff7f00',
      '#cab2d6',
      '#6a3d9a'
    ],
    'brewer.Paired11': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f',
      '#ff7f00',
      '#cab2d6',
      '#6a3d9a',
      '#ffff99'
    ],
    'brewer.Paired12': [
      '#a6cee3',
      '#1f78b4',
      '#b2df8a',
      '#33a02c',
      '#fb9a99',
      '#e31a1c',
      '#fdbf6f',
      '#ff7f00',
      '#cab2d6',
      '#6a3d9a',
      '#ffff99',
      '#b15928'
    ],

    'brewer.Single3': ['#1f78b4', '#33a02c', '#e31a1c'],
    'brewer.Single4': ['#1f78b4', '#33a02c', '#e31a1c', '#ff7f00'],
    'brewer.Single5': ['#1f78b4', '#33a02c', '#e31a1c', '#ff7f00', '#6a3d9a'],
    'brewer.Single6': [
      '#1f78b4',
      '#33a02c',
      '#e31a1c',
      '#ff7f00',
      '#6a3d9a',
      '#b15928'
    ],

    'brewer.SingleLight3': ['#a6cee3', '#b2df8a', '#fb9a99'],
    'brewer.SingleLight4': ['#a6cee3', '#b2df8a', '#fb9a99', '#fdbf6f'],
    'brewer.SingleLight5': [
      '#a6cee3',
      '#b2df8a',
      '#fb9a99',
      '#fdbf6f',
      '#cab2d6'
    ],
    'brewer.SingleLight6': [
      '#a6cee3',
      '#b2df8a',
      '#fb9a99',
      '#fdbf6f',
      '#cab2d6',
      '#ffff99'
    ],

    'brewer.Financial3': ['#1f78b4', '#2e1fb4', '#761fb4'],
    'brewer.Financial4': ['#1f78b4', '#2e1fb4', '#761fb4', '#1fa8b4'],
    'brewer.Financial5': [
      '#1f78b4',
      '#2e1fb4',
      '#761fb4',
      '#1fa8b4',
      '#b4a31f'
    ],
    'brewer.Financial6': [
      '#1f78b4',
      '#2e1fb4',
      '#761fb4',
      '#1fa8b4',
      '#b4a31f',
      '#b4801f'
    ],

    'brewer.PastelOne3': ['#fbb4ae', '#b3cde3', '#ccebc5'],
    'brewer.PastelOne4': ['#fbb4ae', '#b3cde3', '#ccebc5', '#decbe4'],
    'brewer.PastelOne5': [
      '#fbb4ae',
      '#b3cde3',
      '#ccebc5',
      '#decbe4',
      '#fed9a6'
    ],
    'brewer.PastelOne6': [
      '#fbb4ae',
      '#b3cde3',
      '#ccebc5',
      '#decbe4',
      '#fed9a6',
      '#ffffcc'
    ],
    'brewer.PastelOne7': [
      '#fbb4ae',
      '#b3cde3',
      '#ccebc5',
      '#decbe4',
      '#fed9a6',
      '#ffffcc',
      '#e5d8bd'
    ],
    'brewer.PastelOne8': [
      '#fbb4ae',
      '#b3cde3',
      '#ccebc5',
      '#decbe4',
      '#fed9a6',
      '#ffffcc',
      '#e5d8bd',
      '#fddaec'
    ],
    'brewer.PastelOne9': [
      '#fbb4ae',
      '#b3cde3',
      '#ccebc5',
      '#decbe4',
      '#fed9a6',
      '#ffffcc',
      '#e5d8bd',
      '#fddaec',
      '#f2f2f2'
    ],

    'brewer.PastelTwo3': ['#b3e2cd', '#fdcdac', '#cbd5e8'],
    'brewer.PastelTwo4': ['#b3e2cd', '#fdcdac', '#cbd5e8', '#f4cae4'],
    'brewer.PastelTwo5': [
      '#b3e2cd',
      '#fdcdac',
      '#cbd5e8',
      '#f4cae4',
      '#e6f5c9'
    ],
    'brewer.PastelTwo6': [
      '#b3e2cd',
      '#fdcdac',
      '#cbd5e8',
      '#f4cae4',
      '#e6f5c9',
      '#fff2ae'
    ],
    'brewer.PastelTwo7': [
      '#b3e2cd',
      '#fdcdac',
      '#cbd5e8',
      '#f4cae4',
      '#e6f5c9',
      '#fff2ae',
      '#f1e2cc'
    ],
    'brewer.PastelTwo8': [
      '#b3e2cd',
      '#fdcdac',
      '#cbd5e8',
      '#f4cae4',
      '#e6f5c9',
      '#fff2ae',
      '#f1e2cc',
      '#cccccc'
    ],

    'brewer.SetOne3': ['#e41a1c', '#377eb8', '#4daf4a'],
    'brewer.SetOne4': ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3'],
    'brewer.SetOne5': ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00'],
    'brewer.SetOne6': [
      '#e41a1c',
      '#377eb8',
      '#4daf4a',
      '#984ea3',
      '#ff7f00',
      '#ffff33'
    ],
    'brewer.SetOne7': [
      '#e41a1c',
      '#377eb8',
      '#4daf4a',
      '#984ea3',
      '#ff7f00',
      '#ffff33',
      '#a65628'
    ],
    'brewer.SetOne8': [
      '#e41a1c',
      '#377eb8',
      '#4daf4a',
      '#984ea3',
      '#ff7f00',
      '#ffff33',
      '#a65628',
      '#f781bf'
    ],
    'brewer.SetOne9': [
      '#e41a1c',
      '#377eb8',
      '#4daf4a',
      '#984ea3',
      '#ff7f00',
      '#ffff33',
      '#a65628',
      '#f781bf',
      '#999999'
    ],

    'brewer.SetTwo3': ['#66c2a5', '#fc8d62', '#8da0cb'],
    'brewer.SetTwo4': ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3'],
    'brewer.SetTwo5': ['#66c2a5', '#fc8d62', '#8da0cb', '#e78ac3', '#a6d854'],
    'brewer.SetTwo6': [
      '#66c2a5',
      '#fc8d62',
      '#8da0cb',
      '#e78ac3',
      '#a6d854',
      '#ffd92f'
    ],
    'brewer.SetTwo7': [
      '#66c2a5',
      '#fc8d62',
      '#8da0cb',
      '#e78ac3',
      '#a6d854',
      '#ffd92f',
      '#e5c494'
    ],
    'brewer.SetTwo8': [
      '#66c2a5',
      '#fc8d62',
      '#8da0cb',
      '#e78ac3',
      '#a6d854',
      '#ffd92f',
      '#e5c494',
      '#b3b3b3'
    ],

    'brewer.SetThree3': ['#8dd3c7', '#ffffb3', '#bebada'],
    'brewer.SetThree4': ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072'],
    'brewer.SetThree5': ['#8dd3c7', '#ffffb3', '#bebada', '#fb8072', '#80b1d3'],
    'brewer.SetThree6': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462'
    ],
    'brewer.SetThree7': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69'
    ],
    'brewer.SetThree8': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69',
      '#fccde5'
    ],
    'brewer.SetThree9': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69',
      '#fccde5',
      '#d9d9d9'
    ],
    'brewer.SetThree10': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69',
      '#fccde5',
      '#d9d9d9',
      '#bc80bd'
    ],
    'brewer.SetThree11': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69',
      '#fccde5',
      '#d9d9d9',
      '#bc80bd',
      '#ccebc5'
    ],
    'brewer.SetThree12': [
      '#8dd3c7',
      '#ffffb3',
      '#bebada',
      '#fb8072',
      '#80b1d3',
      '#fdb462',
      '#b3de69',
      '#fccde5',
      '#d9d9d9',
      '#bc80bd',
      '#ccebc5',
      '#ffed6f'
    ]
  };

  /// Constructs using default scheme 'brewer.Paired'.
  StandardColorGenerator() : super(standardSchemes, 'brewer.Paired');

  StandardColorGenerator.scheme(String schemeName)
      : super(standardSchemes, schemeName);
}

/// Represents a Color in [red], [green], [blue] and [alpha] format.
class HTMLColor implements Comparable<HTMLColor> {
  /// Parses and returns a flat list [List<HTMLColor>].
  static List<HTMLColor> toList(dynamic value) {
    var list = toFlatListOfStrings(value, delimiter: RegExp(r'[;|]+'));
    return list.map((e) => HTMLColor.from(e)).whereType<HTMLColor>().toList();
  }

  // ignore: non_constant_identifier_names
  static final RegExp COLOR_PATTERN_ARGS =
      RegExp(r'^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,?\s*(\d+(?:\.\d+)?)?\s*');

  // ignore: non_constant_identifier_names
  static final RegExp COLOR_PATTERN_RGBA = RegExp(
      r'^(?:rgba?)?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,?\s*(\d+(?:\.\d+)?)?\s*\)');

  // ignore: non_constant_identifier_names
  static final RegExp COLOR_PATTERN_HEX3 =
      RegExp(r'^#?([0-9a-f][0-9a-f][0-9a-f])$');

  // ignore: non_constant_identifier_names
  static final RegExp COLOR_PATTERN_HEX6 =
      RegExp(r'^#?([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])$');

  /// Red channel: 0..255
  final int red;

  /// Green channel: 0..255
  final int green;

  /// Blue channel: 0..255
  final int blue;

  /// Alpha channel: 0..1
  final double? alpha;

  HTMLColor(this.red, this.green, this.blue, [this.alpha]) {
    _checkInRange('red', red, 0, 255);
    _checkInRange('green', green, 0, 255);
    _checkInRange('blue', blue, 0, 255);
    if (alpha != null) {
      _checkInRange('alpha', alpha!, 0, 1);
    }
  }

  void _checkInRange(String name, num value, num min, num max) {
    if (!_isInRange(value, min, max)) {
      throw ArgumentError("'$name' not in range $min .. $max: $value");
    }
  }

  bool _isInRange(num value, num min, num max) {
    if (value < min) return false;
    if (value > max) return false;
    return true;
  }

  /// Parses from a HTMLColor instance or a string:
  ///  - #FF0000
  ///  - rgba(255,0,0, 0.5)
  static HTMLColor? from(String? color) {
    if (color == null) return null;
    color = color.trim().toLowerCase();
    if (color.isEmpty) return null;

    var matchRGBA = COLOR_PATTERN_RGBA.firstMatch(color);

    if (matchRGBA != null) {
      var r = int.parse(matchRGBA[1]!);
      var g = int.parse(matchRGBA[2]!);
      var b = int.parse(matchRGBA[3]!);
      var a = matchRGBA[4] != null ? double.parse(matchRGBA[4]!) : null;
      return HTMLColor(r, g, b, a);
    }

    var matchHex3 = COLOR_PATTERN_HEX3.firstMatch(color);

    if (matchHex3 != null) {
      var hex = matchHex3.group(1)!;

      var sR = hex.substring(0, 1);
      var sG = hex.substring(1, 2);
      var sB = hex.substring(2, 3);

      var r = int.tryParse(sR + sR, radix: 16)!;
      var g = int.tryParse(sG + sG, radix: 16)!;
      var b = int.tryParse(sB + sB, radix: 16)!;

      return HTMLColor(r, g, b);
    }

    var matchHex6 = COLOR_PATTERN_HEX6.firstMatch(color);

    if (matchHex6 != null) {
      var hex = matchHex6.group(1)!;

      var r = int.tryParse(hex.substring(0, 2), radix: 16)!;
      var g = int.tryParse(hex.substring(2, 4), radix: 16)!;
      var b = int.tryParse(hex.substring(4, 6), radix: 16)!;

      return HTMLColor(r, g, b);
    }

    var matchARGS = COLOR_PATTERN_ARGS.firstMatch(color);

    if (matchARGS != null) {
      var r = int.parse(matchARGS[1]!);
      var g = int.parse(matchARGS[2]!);
      var b = int.parse(matchARGS[3]!);
      var a = matchARGS[4] != null ? double.parse(matchARGS[4]!) : null;
      return HTMLColor(r, g, b, a);
    }

    return null;
  }

  /// Creates a copy of this instance, overwriting the passed parameters.
  HTMLColor copyWith({int? red, int? green, int? blue, double? alpha}) =>
      HTMLColor(
        red ?? this.red,
        green ?? this.green,
        blue ?? this.blue,
        alpha ?? this.alpha,
      );

  /// Returns [true] if this color has [alpha] channel lower than 1.
  bool get hasAlpha => alpha != null && alpha != 1;

  /// Converts to a HTML Color string. If alpha is present uses `rgba()` format.
  @override
  String toString([bool forceRGBA = false]) {
    var rgbaMode = hasAlpha || forceRGBA;

    if (rgbaMode) {
      var a = alpha ?? 1;
      return 'rgba($red, $green, $blue, $a)';
    } else {
      var sR = _toHex(red);
      var sG = _toHex(green);
      var sB = _toHex(blue);

      return '#$sR$sG$sB';
    }
  }

  String _toHex(int n) {
    return n.toRadixString(16).padLeft(2, '0');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HTMLColor &&
          runtimeType == other.runtimeType &&
          red == other.red &&
          green == other.green &&
          blue == other.blue &&
          alpha == other.alpha;

  @override
  int get hashCode =>
      red.hashCode ^ green.hashCode ^ blue.hashCode ^ alpha.hashCode;

  /// Returns a brighter color using [amount] (from 0 to 255) to increase bright.
  ///
  /// [def] The default color to return if it's not possible to generate a brighter color.
  HTMLColor? brighter([int? amount, HTMLColor? def]) {
    var space = getBrighterSpace();
    if (def != null && space <= 2) return def;

    amount ??= _colorChangeAmount(space);

    var minAmount = Math.min(amount ~/ 2, 10);

    if (space < amount) {
      if (space < minAmount) return def;
      amount = space;
    }

    return HTMLColor(_clip(red + amount), _clip(green + amount),
        _clip(blue + amount), alpha);
  }

  /// Returns a darker color using [amount] (from 0 to 255) to decrease bright.
  ///
  /// [def] The default color to return if it's not possible to generate a darker color.
  HTMLColor? darker([int? amount, HTMLColor? def]) {
    var space = getDarkerSpace();
    if (def != null && space <= 2) return def;

    amount ??= _colorChangeAmount(space);

    var minAmount = Math.min(amount ~/ 2, 10);

    if (space < amount) {
      if (space < minAmount) return def;
      amount = space;
    }

    return HTMLColor(_clip(red - amount), _clip(green - amount),
        _clip(blue - amount), alpha);
  }

  int _colorChangeAmount(int space) {
    if (space > 16) {
      return (8 + ((space - 8) ~/ 4));
    } else if (space > 8) {
      return (4 + ((space - 4) ~/ 2));
    } else if (space > 4) {
      return space ~/ 2;
    } else {
      return space;
    }
  }

  /// Returns the amount of space for a brighter color.
  int getBrighterSpace() {
    var min = Math.minInList([red, green, blue])!;
    var space = 195 - min;
    return space;
  }

  /// Returns the amount of space for a darker color.
  int getDarkerSpace() {
    var max = Math.maxInList([red, green, blue])!;
    var space = max - 80;
    return space;
  }

  int _clip(int n) {
    if (n < 0) return 0;
    if (n > 255) return 255;
    return n;
  }

  /// Brightness of the color.
  int get brightness => (red + green + blue) ~/ 3;

  /// Compares using [brightness]: from brighter to darker.
  @override
  int compareTo(HTMLColor other) {
    return other.brightness.compareTo(brightness);
  }

  /// Returns a grey scale version of this color.
  HTMLColor greyScale() {
    var m = Math.mean([red, green, blue]).toInt();
    return HTMLColor(m, m, m, alpha);
  }
}

/// Holds a color palette ([List<HTMLColor>]).
class ColorPalette {
  final List<HTMLColor> _basicColors;

  /// Returns the basic colors of this palette.
  List<HTMLColor> get basicColors => List.from(_basicColors);

  ColorPalette(this._basicColors) {
    _check();
  }

  void _check() {
    if (basicColors.isEmpty) throw ArgumentError('Empty basicColors');

    var set = Set.from(_basicColors);
    if (set.length < _basicColors.length) {
      throw ArgumentError(
          'Duplicated colors in basicColors list: $_basicColors');
    }
  }

  factory ColorPalette.from(dynamic basicColors) {
    return ColorPalette(HTMLColor.toList(basicColors));
  }

  /// Same as [generatePalette], but returns HTML string colors.
  List<String> generateHTMLPalette(int size) {
    var palette = generatePalette(size);
    if (palette.isEmpty) return [];
    return palette.map((e) => e.toString()).toList();
  }

  /// Generates a new palette with specific color [size].
  List<HTMLColor> generatePalette(int size) {
    if (size <= _basicColors.length) {
      var palette = <HTMLColor>[];
      while (palette.length < size) {
        palette.add(_basicColors[palette.length]);
      }
      return palette;
    }

    var blocks = LinkedHashMap<HTMLColor, List<HTMLColor>>.fromEntries(
        _basicColors.map((e) => MapEntry(e, <HTMLColor>[])));

    var colorsSize = blocks.length;

    var colorsPerBlock = Math.max((_basicColors.length / size) - 1, 1) + 1;

    while (colorsSize < size) {
      var colorsSizeMark = colorsSize;

      for (var entry in blocks.entries) {
        var keyColor = entry.key;

        var changeDarkAmount = keyColor.getDarkerSpace() ~/ colorsPerBlock;
        var changeBrightAmount = keyColor.getBrighterSpace() ~/ colorsPerBlock;

        var blockColors = entry.value;

        var init = blockColors.isEmpty ? keyColor : blockColors[0];
        var end = blockColors.isEmpty
            ? keyColor
            : blockColors[blockColors.length - 1];

        var c1 = changeDarkAmount > 10 ? init.darker(changeDarkAmount) : null;
        var c2 =
            changeBrightAmount > 10 ? end.brighter(changeBrightAmount) : null;

        if (c1 != null) {
          blockColors.insert(0, c1);
          colorsSize++;
          if (colorsSize == size) break;
        }
        if (c2 != null) {
          blockColors.add(c2);
          colorsSize++;
          if (colorsSize == size) break;
        }
      }

      if (colorsSize == colorsSizeMark) break;
    }

    var blocksColors = blocks
        .map((key, value) =>
            MapEntry(key, value..insert(value.length ~/ 2, key)))
        .values;

    var palette = blocksColors.expand((e) => e).toList();
    palette.sort();
    return palette;
  }

  /// Returns a `<div>` with a visual palette of colors [_basicColors].
  String asHTML(
      {int? colorWidth,
      int? colorHeight,
      int colorMargin = 5,
      bool inlineBlock = false}) {
    colorWidth ??= colorHeight;
    colorHeight ??= colorWidth;

    colorWidth ??= 20;
    colorHeight ??= colorWidth;

    var styleDisplay = inlineBlock ? 'display: inline-block ;' : '';

    var html = '<div style="$styleDisplay">';
    for (var color in _basicColors) {
      html +=
          '<div style="display: inline-block ; background-color: ${color.toString()} ; margin: ${colorMargin}px ; width: ${colorWidth}px ; height: ${colorHeight}px"></div>';
    }
    html += '</div>';

    return html;
  }

  @override
  String toString([bool forceRGBA = false]) {
    return '[${_basicColors.map((e) => e.toString(forceRGBA)).join(', ')}]';
  }
}

/// Generates color palettes of different sizes using basic colors.
class ColorGeneratorFromBasicPalette extends ColorGenerator {
  final ColorPalette _basicPalette;

  ColorGeneratorFromBasicPalette(this._basicPalette);

  /// The basic palette to generate other palettes of bigger sizes.
  ColorPalette get basicPalette => _basicPalette;

  /// Constructor that accepts a list of colors of a ColorPalette instance.
  factory ColorGeneratorFromBasicPalette.from(dynamic basicColors) {
    if (basicColors is ColorPalette) {
      return ColorGeneratorFromBasicPalette(basicColors);
    }
    var colorsList = HTMLColor.toList(basicColors);
    return ColorGeneratorFromBasicPalette(ColorPalette(colorsList));
  }

  final Map<int, List<HTMLColor>> _cachedPalettes = {};

  /// Clears the palette cache.
  void clearCache() {
    _cachedPalettes.clear();
  }

  /// Generates a [List<HTMLColor>] of [size] and cache it.
  List<HTMLColor> getCachedPalette(int size) {
    var palette = _cachedPalettes[size];
    if (palette == null) {
      _cachedPalettes[size] = palette = generatePalette(size);
    }
    return palette;
  }

  /// Generates a [List<HTMLColor>] of [size]. See [getCachedPalette].
  List<HTMLColor> generatePalette(int size) {
    return _basicPalette.generatePalette(size);
  }

  List<String> generatePaletteAsString(int size) {
    return generatePalette(size).map((e) => e.toString()).toList();
  }

  ColorPalette generatePaletteAsColorPalette(int size) {
    var colors = generatePalette(size);
    return ColorPalette(colors);
  }

  /// Generates a specific color for [index] of palette fo size [total].
  @override
  String generateColor(String name, int index, int total) {
    var color = _generateColorImpl(index, total);
    return color.toString();
  }

  HTMLColor _generateColorImpl(int index, int total) {
    var palette = getCachedPalette(total);
    var idx = index % palette.length;
    return palette[idx];
  }

  /// Same as [generateColor], but for disabled color (grey scale).
  @override
  String generateDisabledColor(String name, int index, int total) {
    var color = _generateColorImpl(index, total);
    var colorGrey = color.greyScale();
    var colorGrey2 = colorGrey.brighter(32) ?? colorGrey;
    return colorGrey2.toString();
  }
}
