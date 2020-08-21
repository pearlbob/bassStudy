import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:bsteeleMusicLib/songs/musicConstants.dart';
import 'package:flutter/material.dart';
import 'package:bsteeleMusicLib/util/util.dart';

import 'SheetMusic.dart';

void main() {
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

    double staffGap = 3;
    _staffLineThickness = EngravingDefaults.staffLineThickness / 2; //  style basis only
    _yOff = 3 * staffSpace;
    _yOffTreble = _yOff;
    _yOffBass = _yOff + (5 + staffGap) * staffSpace;
    _xOff = 10;

    noteHead(brace, GlyphBBoxesNoteheadBlack.bBoxSW.x, 12, fontsize: 12 * staffSpace);
    _xOff += 1.5 * staffSpace;

    staff(size.width - _xOff - 10, _yOffTreble);
    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);

    _yOff = _yOffBass;
    staff(size.width - _xOff - 10, _yOffBass);
    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);

    _xOff += 0.5 * staffSpace;

    _xOff += max(trebleClef(canvas, _xOff, _yOffTreble), bassClef(canvas, _xOff, _yOffBass));
    _xOff += 0.5 * staffSpace;

    double staffPosition = 3.5;

    _yOff = _yOffBass;
    noteHead(accidentalSharp, 0, 1);
    _yOff = _yOffTreble;
    noteHead(accidentalSharp, 0, 0);

    _xOff += 3 * staffSpace;
    _yOff = _yOffBass;
    noteHead(timeSig4, 0, staffPosition - 0.5);
    noteHead(timeSig4, 0, staffPosition - 2.5);


    _yOff = _yOffTreble;
    noteHead(timeSigCommon, 0, 2);
    _yOff = _yOffBass;


    _xOff += 3 * staffSpace;

//    canvas.drawRect(
//        Rect.fromLTRB(
//            _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2) * staffSpace,
//            _yOff + (staffPosition - GlyphBBoxesStem.bBoxNE.y - EngravingDefaults.stemThickness) * staffSpace,
//            _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2 + 2) * staffSpace,
//            _yOff +
//                (staffPosition -
//                        GlyphBBoxesStem.bBoxNE.y -
//                        EngravingDefaults.stemThickness +
//                        EngravingDefaults.beamThickness) *
//                    staffSpace),
//        _blackFill);

    {
      double minX = _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2) * staffSpace;
      double maxX = _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2 + 2) * staffSpace;
      double minY = _yOff + (staffPosition - GlyphBBoxesStem.bBoxNE.y - EngravingDefaults.stemThickness) * staffSpace;
      double maxY = _yOff +
          (staffPosition -
                  GlyphBBoxesStem.bBoxNE.y -
                  EngravingDefaults.stemThickness +
                  EngravingDefaults.beamThickness) *
              staffSpace;

      Path path = Path();
      path.moveTo(minX, minY);
      path.lineTo(maxX, minY - 1 * staffSpace);
      path.lineTo(maxX, maxY - 1 * staffSpace);
      path.lineTo(minX, maxY);
      path.lineTo(minX, minY);

      canvas.drawPath(path, _blackFill);
    }

    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2,
        staffPosition - EngravingDefaults.stemThickness);
    _xOff += 2 * staffSpace;

    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition - 1);
    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxNE.x - EngravingDefaults.stemThickness / 2,
        staffPosition - 1 - EngravingDefaults.stemThickness);
    _xOff += 2 * staffSpace;

    staffPosition = 0.0;

//    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
//    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxSW.x + EngravingDefaults.stemThickness / 2,
//        staffPosition + GlyphBBoxesStem.bBoxNE.y + EngravingDefaults.stemThickness);
//    _xOff += (GlyphBBoxesNoteheadBlack.bBoxNE.x - GlyphBBoxesNoteheadBlack.bBoxSW.x + 0.25) * staffSpace;

    noteHead(noteQuarterDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition - 1.5);
    stave(_xOff-0.5*staffSpace, _xOff + 1.5 * staffSpace, _yOff - 1 * staffSpace  );
    _xOff += 2 * staffSpace;

    noteHead(noteHalfDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 1);
    _xOff += 2 * staffSpace;

    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;

    noteHead(noteWhole, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 5);
    stave(_xOff-0.5*staffSpace, _xOff + 2.5 * staffSpace, _yOff+5 * staffSpace  );
    _xOff += 4 * staffSpace;

    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;

    noteHead(noteHalfUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 2.5);
    _xOff += 2 * staffSpace;
    noteHead(noteQuarterUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 2);
    _xOff += 2 * staffSpace;
    noteHead(noteQuarterDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 2 * staffSpace;

    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;

    noteHead(restQuarter, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;

    noteHead(note8thUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 3);
    _xOff += 3 * staffSpace;
    noteHead(note8thDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 2 * staffSpace;
    noteHead(note16thUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition + 2.5);
    _xOff += 3 * staffSpace;
    noteHead(note16thDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 3 * staffSpace;
    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;

    noteHead(restWhole, GlyphBBoxesNoteheadBlack.bBoxSW.x, 1);
    _xOff += 3 * staffSpace;

    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;

    noteHead(restHalf, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;
    noteHead(restQuarter, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;
    noteHead(rest8th, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;
    noteHead(rest16th, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;
    noteHead(rest16th, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3 * staffSpace;

    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2 * staffSpace;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void staff(double width, double y) {
    final black = Paint();
    black.color = Colors.black;
    black.style = PaintingStyle.stroke;
    black.strokeWidth = _staffLineThickness * staffSpace;

    for (int line = 0; line < 5; line++) {
      _canvas.drawLine(Offset(_xOff, y + line * staffSpace), Offset(_xOff + width, y + line * staffSpace), black);
    }
  }

  void stave(double x1, double x2, double y) {
    final black = Paint();
    black.color = Colors.black;
    black.style = PaintingStyle.stroke;
    black.strokeWidth = _staffLineThickness * staffSpace;
    _canvas.drawLine(Offset(x1, y), Offset(x2, y), black);
  }

  double trebleClef(Canvas canvas, final double x, final double yOff) {
    TextPainter(
      text: TextSpan(
        text: MusicConstants.trebleClef,
        style: TextStyle(
          fontFamily: 'Bravura',
          color: _black.color,
          fontSize: 4 * staffSpace,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: (GlyphBBoxesGClef.bBoxNE.x - GlyphBBoxesGClef.bBoxSW.x) * staffSpace,
      )
      ..paint(canvas, Offset(x, -2 * staffSpace));

    return GlyphBBoxesGClef.bBoxNE.x * staffSpace;
  }

  double bassClef(Canvas canvas, final double xOff, final double yOff) {
    final double fontSize = 4 * staffSpace;

    TextPainter(
      text: TextSpan(
        text: MusicConstants.bassClef,
        style: TextStyle(
          fontFamily: 'Bravura',
          color: _black.color,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: fontSize,
      )
      ..paint(canvas, Offset(xOff, yOff - 2 * fontSize + GlyphBBoxesFClef.bBoxNE.y * staffSpace));

    return GlyphBBoxesFClef.bBoxNE.x * staffSpace;
  }

  void noteHead(final String text, double x, double staffPosition, {fontsize: 4 * staffSpace}) {
    double w = fontsize;
    TextPainter(
      text: TextSpan(
        text: text,
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
      ..paint(_canvas, Offset(_xOff + x * staffSpace, (_yOff ?? 0) + -2 * w + (staffPosition - 0.05) * staffSpace));
  }

  Canvas _canvas;
  double _staffLineThickness;
  double _xOff;
  double _yOff;
  double _yOffTreble;
  double _yOffBass;
}

final String noteheadWhole = '\uE0A2';
final String noteheadBlack = '\uE0A4';
final String stem = '\uE210';
final String brace = '\uE000';
final String barlineSingle = '\uE030';
final String noteWhole = '\uE1D2';
final String noteHalfUp = '\uE1D3';
final String noteHalfDown = '\uE1D4';
final String noteQuarterUp = '\uE1D5';
final String noteQuarterDown = '\uE1D6';
final String note8thUp = '\uE1D7';
final String note8thDown = '\uE1D8';
final String note16thUp = '\uE1D9';
final String note16thDown = '\uE1DA';
final String restWhole = '\uE4E3';
final String restHalf = '\uE4E4';
final String restQuarter = '\uE4E5';
final String rest8th = '\uE4E6';
final String rest16th = '\uE4E7';
final String repeat1Bar = '\uE500';

final String timeSig0 = '\uE080';
final String timeSig1 = '\uE081';
final String timeSig2 = '\uE082';
final String timeSig3 = '\uE083';
final String timeSig4 = '\uE084';
final String timeSig5 = '\uE085';
final String timeSig6 = '\uE086';
final String timeSig7 = '\uE087';
final String timeSig8 = '\uE088';
final String timeSig9 = '\uE089';
final String timeSigCommon = '\uE08A';

final String accidentalFlat = '\uE260';
final String accidentalNatural = '\uE261';
final String accidentalSharp = '\uE262';

final _white = Paint()..color = Colors.white;
final _grey = Paint()..color = Colors.grey;
final _black = Paint()..color = Colors.black;
final _blackFill = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.fill;
