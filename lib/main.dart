import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bassStudy/sheetNote.dart';
import 'package:bsteeleMusicLib/util/util.dart';
import 'package:flutter/material.dart';

import 'SheetMusic.dart';

const bool _debug = false; //  true false

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

const double staffSpace = 19;

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

    _xOff += renderSheetNoteSymbol(brace, 12);
    _xOff += 1.5 * staffSpace;

    staff(size.width - _xOff - 10, _yOffTreble);
    _xOff += renderSheetNoteSymbol(barlineSingle, 4);

    _yOff = _yOffBass;
    staff(size.width - _xOff - 10, _yOffBass);
    _xOff += renderSheetNoteSymbol(barlineSingle, 4);

    _xOff += 0.5 * staffSpace;

    {
      _yOff =_yOffTreble;
      double width = renderSheetFixedYSymbol(trebleClef );
      _yOff =_yOffBass;
      _xOff += max(width, renderSheetFixedYSymbol(bassClef));
    }
    _xOff += 1 * staffSpace;

    double staffPosition = 3.5;


    _yOff = _yOffTreble;
    renderSheetNoteSymbol(accidentalSharp, 0);
    _yOff = _yOffBass;
    _xOff += renderSheetNoteSymbol(accidentalSharp,  1);

    _xOff += 1 * staffSpace;
    _yOff = _yOffBass;
    renderSheetNoteSymbol(timeSig4, staffPosition - 0.5);
    renderSheetNoteSymbol(timeSig4, staffPosition - 2.5);

    _yOff = _yOffTreble;
    renderSheetNoteSymbol(timeSigCommon, 2);
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
      double minX = _xOff + (noteQuarterUp.bounds.right - EngravingDefaults.stemThickness) * staffSpace;
      double maxX = _xOff + (noteQuarterUp.bounds.width + 1 + noteQuarterUp.bounds.right) * staffSpace;
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

      _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition);
      _xOff += 1 * staffSpace;

      _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition - 1);
      _xOff += 1 * staffSpace;
    }

    staffPosition = 0.0;

//    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
//    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxSW.x + EngravingDefaults.stemThickness / 2,
//        staffPosition + GlyphBBoxesStem.bBoxNE.y + EngravingDefaults.stemThickness);
//    _xOff += (GlyphBBoxesNoteheadBlack.bBoxNE.x - GlyphBBoxesNoteheadBlack.bBoxSW.x + 0.25) * staffSpace;

    {
      double width = renderSheetNoteSymbol(noteQuarterDown, staffPosition - 1.5);
      stave(_xOff - 0.5 * staffSpace, _xOff + 1.5 * staffSpace, _yOff - 1 * staffSpace);
      _xOff += width;
      _xOff += 1 * staffSpace;
    }

    _xOff += renderSheetNoteSymbol(noteHalfDown, staffPosition + 1);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(noteWhole, staffPosition + 4);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;
    {
      double width = renderSheetNoteSymbol(noteWhole, staffPosition + 5);
      stave(_xOff - 0.5 * staffSpace, _xOff + 2.5 * staffSpace, _yOff + 5 * staffSpace);
      _xOff += width;
    }
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(noteHalfUp, staffPosition + 2.5);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(noteQuarterUp, staffPosition + 2);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(noteQuarterDown, staffPosition);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetFixedYSymbol(restQuarter);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(note8thUp, staffPosition + 3);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(note8thDown, staffPosition);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(note16thUp, staffPosition + 2.5);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(note16thDown, staffPosition);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetFixedYSymbol(restWhole);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetFixedYSymbol(restHalf);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetFixedYSymbol(restQuarter);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetFixedYSymbol(rest8th);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetFixedYSymbol(rest16th);
    _xOff += 1 * staffSpace;
    _xOff += renderSheetFixedYSymbol(rest16th);
    _xOff += 1 * staffSpace;

    _xOff += renderSheetNoteSymbol(barlineSingle, 4);
    _xOff += 1 * staffSpace;
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

  double renderSheetFixedYSymbol(SheetNoteSymbol symbol) {
    return renderSheetNoteSymbol(symbol, symbol.restYOff);
  }

  double renderSheetNoteSymbol(SheetNoteSymbol symbol, double staffPosition) {
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
    return symbol.bounds.width * staffSpace;
  }

  Canvas _canvas;
  double _staffLineThickness;
  double _xOff;
  double _yOff;
  double _yOffTreble;
  double _yOffBass;
}

final _white = Paint()..color = Colors.white;
final _grey = Paint()..color = Colors.grey;
final _black = Paint()..color = Colors.black;
final _blackFill = Paint()
  ..color = Colors.black
  ..style = PaintingStyle.fill;
