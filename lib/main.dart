import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:bsteeleMusicLib/songs/pitch.dart';
import 'package:bsteeleMusicLib/songs/scaleNote.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';

import 'package:bassStudy/readJson.dart';
import 'package:bassStudy/sheetNote.dart';
import 'package:bsteeleMusicLib/appLogger.dart';
import 'package:bsteeleMusicLib/songs/key.dart' as musicalKey;
import 'package:bsteeleMusicLib/songs/musicConstants.dart';
import 'package:bsteeleMusicLib/util/util.dart';
import 'package:flutter/material.dart';

import 'sheetMusicFontParameters.dart';

const bool _debug = false; //  true false

void main() {
  Logger.level = Level.info;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bass Study',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _myHomePage,
    );
  }

  final MyHomePage _myHomePage = MyHomePage(title: 'bsteele Bass Study');
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key) {
    //  for dev only:
    //  generateGlyphsWithAlternates();
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

  /// generate the sheetMusicFontParameters.dart file
  /// note normally used!
  void generateGlyphsWithAlternates() {
    File('fonts/bravura_metadata.json').readAsString().then((String contents) {
      stdout.write('\n//  generated code!\n'
          '\n//  do not modify by hand.\n'
          '\n//  units are staff spaces\n\n');

      Map userMap = jsonDecode(contents);
      if (userMap != null && userMap.isNotEmpty) {
        for (var e in userMap.keys) {
          switch (e) {
            case 'engravingDefaults':
              {
                stdout.write('  class  ${Util.firstToUpper(e)} {\n');
                var uMe = userMap[e];
                for (var k in uMe.keys) {
                  var value = uMe[k];
                  stdout.write('\tstatic const double $k = $value;\n');
                }
                stdout.write('\t}\n');
              }
              break;
            case 'glyphBBoxes':
            case 'glyphsWithAnchors':
              {
                String E = Util.firstToUpper(e);
                stdout.write('// $E:\n');
                var uMe = userMap[e];
                for (var k in uMe.keys) {
                  var values = uMe[k];
                  stdout.write('  class  $E${Util.firstToUpper(k)} {\n');
                  for (var kvk in values.keys) {
                    List coordinates = values[kvk];
                    stdout
                        .write('\tstatic final Point<double> $kvk = Point( ${coordinates[0]}, ${coordinates[1]} );\n');
                  }
                  stdout.write('\t}\n');
                }
              }
              break;
            default:
              stdout.write('//\tunknown: "$e"\n');
              break;
          }
        }
      }
    });
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            fit: StackFit.passthrough,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _PlotPainter(),
                  isComplex: true,
                  willChange: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 800.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const double staffSpace = 16;

class _PlotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    //  clear the plot
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _white);

    //  initialize staff locations
    _yOff = 2 * staffSpace;
    _yOffTreble = _yOff + staffMargin * staffSpace;
    _yOffBass = _yOffTreble + (staffGaps + 2 * staffMargin) * staffSpace;
    _xSpaceAll(10);

    _renderSheetFixedYSymbol(Clef.treble, brace);
    _xSpaceAll(1.5 * staffSpace);

    _startClef(Clef.treble);
    renderStaff(size.width - _xOffTreble - 10, _yOffTreble);
    _startClef(Clef.bass);
    renderStaff(size.width - _xOffTreble - 10, _yOffBass);

    _renderBarlineSingle();

    _xSpaceAll(0.5 * staffSpace);

    _startClef(Clef.treble);
    _renderSheetFixedYSymbol(Clef.treble, trebleClef);
    _startClef(Clef.bass);
    _renderSheetFixedYSymbol(Clef.bass, bassClef);

    _xSpaceAll(1 * staffSpace);

    _testSong();
//    {
//      //  hand rendering
//      _yOff = _yOffTreble;
//      renderSheetNoteSymbol(accidentalSharp, 0);
//      _yOff = _yOffBass;
//      _xOff += renderSheetNoteSymbol(accidentalSharp, 1);
//
//      _xOff += 1 * staffSpace;
//      _yOff = _yOffBass;
//
//      double staffPosition = staffGaps;
//      renderSheetNoteSymbol(timeSig4, staffPosition - 3);
//      renderSheetNoteSymbol(timeSig4, staffPosition - 1);
//
//      _yOff = _yOffTreble;
//      renderSheetNoteSymbol(timeSigCommon, 2);
//      _yOff = _yOffBass;
//
//      _xOff += 3 * staffSpace;
//
//      double xOffBass = _xOff;
//      double xOffTreble = _xOff;
//
//      //  treble note samples
//      _yOff = _yOffTreble;
//
//      //  beat 1
//      renderSheetNoteSymbol(noteQuarterUp, 4);
//      renderSheetNoteSymbol(noteQuarterUp, 3);
//      _xOff += renderSheetNoteSymbol(noteQuarterUp, 2);
//      _xOff += 3 * staffSpace;
//
//      //  beat 2
//      {
//        double firstChordRoot = 2;
//        double secondChordRoot = 2.5;
//
//        //  barred note sample
//        double firstX = _xOff + (noteQuarterUp.bounds.right - EngravingDefaults.stemThickness) * staffSpace;
//        double secondX = _xOff + (noteQuarterUp.bounds.width + 1 + noteQuarterUp.bounds.right) * staffSpace;
//        double firstY = _yOff + (firstChordRoot - GlyphBBoxesStem.bBoxNE.y) * staffSpace;
//        double secondY = _yOff + (secondChordRoot - GlyphBBoxesStem.bBoxNE.y) * staffSpace;
//
//        Path path = Path();
//        path.moveTo(firstX, firstY);
//        path.lineTo(firstX, firstY + EngravingDefaults.beamThickness * staffSpace);
//        path.lineTo(secondX, secondY + EngravingDefaults.beamThickness * staffSpace);
//        path.lineTo(secondX, secondY);
//        path.lineTo(firstX, firstY);
//
//        canvas.drawPath(path, _blackFill);
//
//        renderSheetNoteSymbol(noteQuarterUp, firstChordRoot + 2);
//        renderSheetNoteSymbol(noteQuarterUp, firstChordRoot + 1);
//        _xOff += renderSheetNoteSymbol(noteQuarterUp, firstChordRoot);
//        _xOff += 1 * staffSpace;
//
//        renderSheetNoteSymbol(noteQuarterUp, secondChordRoot + 2);
//        renderSheetNoteSymbol(noteQuarterUp, secondChordRoot + 1);
//        _xOff += renderSheetNoteSymbol(noteQuarterUp, secondChordRoot);
//        _xOff += 3 * staffSpace;
//      }
//
//      //  beat 3
//      renderSheetNoteSymbol(noteQuarterUp, 4.5);
//      renderSheetNoteSymbol(noteQuarterUp, 3.5);
//      _xOff += renderSheetNoteSymbol(note8thUp, 2.5);
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetFixedYSymbol(rest8th);
//      _xOff += 3 * staffSpace;
//
//      //  beat 4
//      _xOff += renderSheetFixedYSymbol(restQuarter);
//      _xOff += 3 * staffSpace;
//
//      xOffTreble = _xOff;
//
//      //  bass note samples
//      _xOff = xOffBass;
//      _yOff = _yOffBass;
//
//      {
//        //  barred note sample
//        double minX = _xOff + (noteQuarterUp.bounds.right - EngravingDefaults.stemThickness) * staffSpace;
//        double maxX = _xOff + (noteQuarterUp.bounds.width + 1 + noteQuarterUp.bounds.right) * staffSpace;
//        double minY = _yOff + (staffPosition - GlyphBBoxesStem.bBoxNE.y - EngravingDefaults.stemThickness) * staffSpace;
//        double maxY = _yOff +
//            (staffPosition -
//                    GlyphBBoxesStem.bBoxNE.y -
//                    EngravingDefaults.stemThickness +
//                    EngravingDefaults.beamThickness) *
//                staffSpace;
//
//        Path path = Path();
//        path.moveTo(minX, minY);
//        path.lineTo(maxX, minY - 1 * staffSpace);
//        path.lineTo(maxX, maxY - 1 * staffSpace);
//        path.lineTo(minX, maxY);
//        path.lineTo(minX, minY);
//
//        canvas.drawPath(path, _blackFill);
//
//        _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition);
//        _xOff += 1 * staffSpace;
//
//        _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition - 1);
//        _xOff += 1 * staffSpace;
//      }
//
//      staffPosition = 0.0;
//
//      _xOff += renderSheetNoteSymbol(noteQuarterDown, staffPosition - 1.5);
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetNoteSymbol(noteHalfDown, staffPosition + 1);
//      _xOff += 1 * staffSpace;
//
//      _xOff = max(_xOff, xOffTreble);
//
//      _xOff += renderBarlineSingle();
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetNoteSymbol(noteWhole, staffPosition + 4);
//      _xOff += 1 * staffSpace;
//      _xOff += renderBarlineSingle();
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetNoteSymbol(noteWhole, staffPosition + 5);
//
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderBarlineSingle();
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetNoteSymbol(noteHalfUp, staffPosition + 2.5);
//      _xOff += 1 * staffSpace;
//      _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition + 2);
//      _xOff += 0.25 * staffSpace;
//      _xOff += renderSheetNoteSymbol(augmentationDot, staffPosition + 2);
//
//      _xOff += 1 * staffSpace;
//      _xOff += renderSheetNoteSymbol(note8thDown, staffPosition);
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderBarlineSingle();
//      _xOff += 1 * staffSpace;
//
//      _xOff += renderSheetFixedYSymbol(restQuarter);
//      _xOff += 1 * staffSpace;
//
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  /// render the key symbols (sharps or flats)
  void _renderKeyStaffSymbols(Clef clef) {
    if (_key == null || _key == musicalKey.Key.getDefault()) {
      return;
    }

    _startClef(clef);

    int clefYOff = clef == Clef.bass ? 0 : -1;

    //  key
    List<double> locations = (_key.isSharp ? keySharpLocations : keyFlatLocations);
    SheetNoteSymbol symbol = (_key.isSharp ? accidentalSharp : accidentalFlat);
    for (int i = 1; i <= _key.getKeyValue().abs(); i++) {
      //  compute height of sharp/flat from note
      //if (doRender)
      _renderSheetNoteSymbol(symbol, locations[i] + clefYOff);
      _xSpace(symbol.width / 2);
    }

    //  end at the end of the last character
    _xSpace(symbol.width / 2);
  }

  //  flats:                                B♭,E♭,A♭,D♭, G♭,  C♭,F♭
  //  at bass locations
  List<double> keyFlatLocations = /* */ [0, 3, 1.5, 3.5, 2, 4, 2.5, 4.5];

  //	sharps:                               F♯,C♯, G♯, D♯, A♯,  E♯,  B♯
  //  at bass locations
  List<double> keySharpLocations = /**/ [0, 1, 2.5, 0.5, 2, 3.5, 1.5, 3];

  void renderStaff(double width, double y) {
    final black = Paint();
    black.color = Colors.black;
    black.style = PaintingStyle.stroke;
    black.strokeWidth = _staffLineThickness * staffSpace;

    for (int line = 0; line < 5; line++) {
      _canvas.drawLine(Offset(_xOff, y + line * staffSpace), Offset(_xOff + width, y + line * staffSpace), black);
    }
  }

  void renderStaves(SheetNoteSymbol symbol, double staffPosition) {
    //  truncate to staff line height
    staffPosition = staffPosition.toInt().toDouble();

    if (staffPosition >= 0 && staffPosition <= staffGaps) {
      return;
    }

    final black = Paint();
    black.color = Colors.black;
    black.style = PaintingStyle.stroke;
    black.strokeWidth = _staffLineThickness * staffSpace;

    while (staffPosition < 0) {
      _canvas.drawLine(Offset(_xOff + (symbol.bounds.left - 0.5) * staffSpace, _yOff + staffPosition * staffSpace),
          Offset(_xOff + (symbol.bounds.right + 0.5) * staffSpace, _yOff + staffPosition * staffSpace), black);
      staffPosition++;
    }

    while (staffPosition > staffGaps) {
      _canvas.drawLine(Offset(_xOff + (symbol.bounds.left - 0.5) * staffSpace, _yOff + staffPosition * staffSpace),
          Offset(_xOff + (symbol.bounds.right + 0.5) * staffSpace, _yOff + staffPosition * staffSpace), black);
      staffPosition--;
    }
  }

  void _renderBarlineSingle() {
    final black = Paint();
    black.color = Colors.black;
    black.style = PaintingStyle.stroke;
    final width = (GlyphBBoxesBarlineSingle.bBoxNE.x - GlyphBBoxesBarlineSingle.bBoxSW.x) * staffSpace;
    black.strokeWidth = width;

    _endClef();
    _xAlign();

    _canvas.drawLine(Offset(_xOff, _yOffTreble), Offset(_xOff, _yOffBass + staffGaps * staffSpace), black);

    _xSpaceAll(width);
  }

  void _renderSheetFixedY(Clef clef, SheetNote rest) {
    _startClef(clef);
    _renderSheetNoteSymbol(rest.symbol, rest.symbol.fixedYOff, isStave: false);
    _endClef();
  }

  Accidental _accidentalFromPitch(Pitch pitch) {
    if (pitch.isSharp) return Accidental.sharp;
    if (pitch.isFlat) return Accidental.flat;
    return Accidental.natural;
  }
  Accidental _accidentalFromScaleNote(ScaleNote scaleNote) {
    if (scaleNote.isSharp) return Accidental.sharp;
    if (scaleNote.isFlat) return Accidental.flat;
    return Accidental.natural;
  }

  ///
  void _renderSheetNote(Clef clef, SheetNote sn) {
    _startClef(clef);

    Pitch pitch = _key.mappedPitch(sn.pitch);
    ScaleNote mappedScaleNote  = _key.getMajorScaleByNote(sn.pitch.cScaleNumber);
    double staffPosition = musicalKey.Key.getStaffPosition(clef, pitch);

    logger.v('_measureAccidentals[$staffPosition]: ${_measureAccidentals[staffPosition]}');
    logger.v('_key.getMajorScaleByNote(${pitch.cScaleNumber}): ${_key.getMajorScaleByNote(pitch.cScaleNumber)}');

    Accidental accidental = _measureAccidentals[staffPosition] // prior notes in the measure
        ??
        _accidentalFromScaleNote(mappedScaleNote); //  from the key and mapped pitch

    logger.i('sn.pitch: ${sn.pitch.toString().padLeft(3)}, pitch: ${pitch.toString().padLeft(3)}'
        ', key: $_key, cScaleNumber: ${pitch.cScaleNumber}'
            ', mappedScaleNote: $mappedScaleNote'
        ', accidental: $accidental');
    if (pitch.isSharp && accidental != Accidental.sharp) {
      _renderSheetNoteSymbol(accidentalSharp, staffPosition);
      _xSpace(_accidentalStaffSpace * staffSpace);
    } else if (pitch.isFlat && accidental != Accidental.flat) {
      _renderSheetNoteSymbol(accidentalFlat, staffPosition);
      _xSpace(_accidentalStaffSpace * staffSpace);
    } else if (pitch.isNatural && accidental != Accidental.natural) {
      _renderSheetNoteSymbol(accidentalNatural, staffPosition);
      _xSpace(_accidentalStaffSpace * staffSpace);
    }
    _measureAccidentals[staffPosition] = _accidentalFromPitch(pitch);
    logger.i('_measureAccidentals[$staffPosition] = ${_accidentalFromPitch(pitch)}');
    _renderSheetNoteSymbol(sn.symbol, staffPosition);
  }

  void _startClef(Clef clef) {
    if (clef == _clef) return;

    //  remember the other stuff
    _endClef();

    //  select the current
    _clef = clef;
    switch (_clef) {
      case Clef.treble:
        _xOff = _xOffTreble;
        _yOff = _yOffTreble;
        break;
      case Clef.bass:
        _xOff = _xOffBass;
        _yOff = _yOffBass;
        break;
    }
  }

  void _endClef() {
    switch (_clef) {
      case Clef.treble:
        _xOffTreble = _xOff;
        _yOffTreble = _yOff;
        break;
      case Clef.bass:
        _xOffBass = _xOff;
        _yOffBass = _yOff;
        break;
    }
  }

  void _renderSheetFixedYSymbol(Clef clef, SheetNoteSymbol symbol) {
    _startClef(clef);
    _renderSheetNoteSymbol(symbol, symbol.fixedYOff, isStave: false);
    _endClef();
  }

  void _renderSheetNoteSymbol(SheetNoteSymbol symbol, double staffPosition, {bool isStave: true}) {
    double w = symbol.fontSizeStaffs * staffSpace;

    if (_debug)
      _canvas.drawRect(
          Rect.fromLTRB(
              _xOff + symbol.bounds.left * staffSpace,
              _yOff + (-symbol.bounds.top + staffPosition) * staffSpace,
              _xOff + symbol.bounds.right * staffSpace,
              _yOff + (-symbol.bounds.bottom + staffPosition) * staffSpace),
          _grey);

    TextPainter(
      text: TextSpan(
        text: symbol.character,
        style: TextStyle(
          fontFamily: 'Bravura',
          color: _black.color,
          fontSize: w,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: w,
      )
      ..paint(_canvas, Offset(_xOff + symbol.bounds.left, (_yOff ?? 0) + -2 * w + (staffPosition - 0.05) * staffSpace));

    if (isStave) {
      renderStaves(symbol, staffPosition);
    }

    _xSpace(symbol.bounds.width * staffSpace);
  }

  /// align all clefs and add a space
  void _xSpaceAll(double space) {
    _endClef();
    _xOff = max(_xOffTreble, _xOffBass);
    _xOff += space;
    _xOffBass = _xOffTreble = _xOff;
  }

  ///  add spacing to the current clef
  void _xSpace(double space) {
    _xOff += space;
  }

  /// align all clefs to the current maximum of the clefs
  void _xAlign() {
    _xOff = max(_xOffTreble, _xOffBass);
    _xOffBass = _xOffTreble = _xOff;
  }

  /// only a test song
  void _testSong() {
    //  sample song.... temp!
    String songAsJsonString = """
{"warning":"File generated by Robert Steele's Bass Study Tool.  Any modifications by hand are likely to be wrong.","version":"0.0","keyN":0,"beatsPerBar":4,"notesPerBar":4,"bpm":80,"isSwing8":false,"hiHatRhythm":"X   x x   x X   x x   x","swingType":3,"sheetNotes":[
{"isNote":true,"string":0,"fret":5,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"verse","tied":false},
{"isNote":true,"string":0,"fret":7,"noteDuration":4,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-2,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":7,"noteDuration":4,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-2,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":4,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":5,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":1},
{"isNote":true,"string":1,"fret":5,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":7,"noteDuration":4,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-2,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":7,"noteDuration":4,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-2,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":4,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":5,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":1},
{"isNote":true,"string":0,"fret":5,"noteDuration":2,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"chorus","tied":false},
{"isNote":true,"string":1,"fret":4,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":4},
{"isNote":true,"string":1,"fret":4,"noteDuration":4,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":5,"noteDuration":2,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-4,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":4,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":4},
{"isNote":true,"string":1,"fret":4,"noteDuration":4,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-7,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":5,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-4,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":4,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":7,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":5,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":4},
{"isNote":true,"string":1,"fret":5,"noteDuration":4,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":7,"noteDuration":3,"chordN":0,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":6,"noteDuration":3,"chordN":0,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":3,"fret":4,"noteDuration":3,"chordN":0,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":5,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":3},
{"isNote":true,"string":1,"fret":0,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":1,"noteDuration":3,"chordN":6,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":2,"noteDuration":3,"chordN":7,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":3,"noteDuration":3,"chordN":8,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":4,"noteDuration":3,"chordN":9,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":5,"noteDuration":3,"chordN":10,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":6,"noteDuration":3,"chordN":11,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":7,"noteDuration":3,"chordN":12,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":0,"noteDuration":3,"chordN":0,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":1,"noteDuration":3,"chordN":1,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":4,"noteDuration":3,"chordN":4,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":5,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":6,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":0,"lyrics":"","tied":false},
{"isNote":true,"string":0,"fret":7,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-2,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":4,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":3,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":5,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-4,"lyrics":"","tied":false},
{"isNote":true,"string":1,"fret":7,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":5,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":4,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-6,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":6,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":-7,"lyrics":"","tied":false},
{"isNote":true,"string":2,"fret":7,"noteDuration":3,"chordN":5,"chordModifier":"","minorMajor":"major","minorMajorSelectIndex":0,"scaleN":1,"lyrics":"","tied":false},
{"isNote":false,"noteDuration":1}
]}
    """;
    logger.d('debugging:');
    List<SheetNote> sheetNotes = parseJsonBsstVerion0_0(songAsJsonString);

    _key = musicalKey.Key.get(musicalKey.KeyEnum.A);

    //  fixme: fill in the key accidentals
    //  hand rendering
    _xAlign();
    _renderKeyStaffSymbols(Clef.treble);
    _renderKeyStaffSymbols(Clef.bass);
    _xSpaceAll(1 * staffSpace);

    //  fill in the time signature
    _xAlign();
    _startClef(Clef.treble);
    _renderSheetNoteSymbol(
        timeSigCommon, 2); //  fixme: fill in the time signature with something other than common time
    _endClef();
    _xAlign();

    double duration = 0;
    _clearMeasureAccidentals();
    for (SheetNote sn in sheetNotes) {
      if (sn.isNote) {
        //  fixme: sharp/flat key designation
        //  fixme: sharp/flat notes based on key!!!
        //  fixme: default sharp/flat notes based on key within the measure (i.e. don't sharp a sharp from the key)
        //  fixme: pitch to trebleClef location
        //  fixme: sharp/flat/natural prefix according to key
        //  fixme: avoid sharp/flat/natural prefix within the single measure
        //  fixme: dotted
        //  fixme: tied
        //  fixme: beamed
        //  fixme: align treble and bass measures
        //  fixme: even measure widths
        //  fixme: align notes with their durations
        //  fixme: control line overflow
        //  fixme: staff selection (e.g. bass only, treble + bass, etc)
        _renderSheetNote(Clef.bass, sn);
      } else
        _renderSheetFixedY(Clef.bass, sn);

      _xSpace(1.25 * staffSpace);

      duration += sn.noteDuration;
      if (duration >= 1) {
        _renderBarlineSingle();
        duration = 0;
        _xSpace(2 * staffSpace);
        _clearMeasureAccidentals();
      }
    }
  }

  void _clearMeasureAccidentals() {
    _measureAccidentals.clear();
  }

  Map<double, Accidental> _measureAccidentals = {};
  Canvas _canvas;
  static const double _staffLineThickness = EngravingDefaults.staffLineThickness / 2; //  style basis only
  static const double _accidentalStaffSpace = 0.25;
  musicalKey.Key _key = musicalKey.Key.get(musicalKey.KeyEnum.C);
  Clef _clef; //  current clef
  double _xOff = 0;
  double _yOff = 0;
  double _xOffTreble = 0;
  double _xOffBass = 0;
  double _yOffTreble = 0;
  double _yOffBass = 0;
}

final _white = Paint()..color = Colors.white;
final _grey = Paint()..color = Colors.grey;
final _black = Paint()..color = Colors.black;
//final _blackFill = Paint()
//  ..color = Colors.black
//  ..style = PaintingStyle.fill;
