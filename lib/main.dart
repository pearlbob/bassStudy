import 'dart:convert';
import 'dart:io';

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

const double staffSpace = 40;

class _PlotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;
    //  clear the plot
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _white);

    double staffLineThickness = EngravingDefaults.staffLineThickness / 2; //  style basis only

    //  practice staff
    _yOff = 3 * staffSpace;
    _black.style = PaintingStyle.stroke;
    _black.strokeWidth = staffLineThickness * staffSpace;
    for (int line = 0; line < 5; line++) {
      canvas.drawLine(Offset(0, _yOff + line * staffSpace), Offset(size.width, _yOff + line * staffSpace), _black);
    }

    _xOff = 10;
    _xOff = bassClef(canvas, _yOff);

    double staffPosition = 3.5;


    canvas.drawRect(
        Rect.fromLTRB(
            _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x- EngravingDefaults.stemThickness/2)*staffSpace,
            _yOff +
                (staffPosition  - GlyphBBoxesStem.bBoxNE.y- EngravingDefaults.stemThickness ) *
                    staffSpace,
            _xOff + (GlyphBBoxesNoteheadBlack.bBoxNE.x- EngravingDefaults.stemThickness/2 + 2)*staffSpace,
            _yOff +
                (staffPosition - GlyphBBoxesStem.bBoxNE.y- EngravingDefaults.stemThickness +EngravingDefaults.beamThickness) *
                    staffSpace),
        _blackFill);

    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxNE.x- EngravingDefaults.stemThickness/2,
        staffPosition- EngravingDefaults.stemThickness);
    _xOff += 2 * staffSpace;

    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxNE.x- EngravingDefaults.stemThickness/2,
        staffPosition- EngravingDefaults.stemThickness);
    _xOff += 2* staffSpace;

    staffPosition = 0.0;

    noteHead(noteheadBlack, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    noteHead(stem, GlyphBBoxesNoteheadBlack.bBoxSW.x + EngravingDefaults.stemThickness / 2,
        staffPosition  +GlyphBBoxesStem.bBoxNE.y + EngravingDefaults.stemThickness);
    _xOff += (GlyphBBoxesNoteheadBlack.bBoxNE.x - GlyphBBoxesNoteheadBlack.bBoxSW.x + 0.25) * staffSpace;

    noteHead(noteWhole, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+0.5);
    _xOff += 2*staffSpace;
        noteHead(noteHalfUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+1);
    _xOff += 2*staffSpace;
    noteHead(noteHalfDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+1.5);
    _xOff += 2*staffSpace;
    noteHead(noteQuarterUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+2);
    _xOff += 2*staffSpace;
    noteHead(noteQuarterDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 2*staffSpace;
    noteHead(note8thUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+3);
    _xOff += 3*staffSpace;
    noteHead(note8thDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 2*staffSpace;
    noteHead(note16thUp, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition+2.5);
    _xOff += 3*staffSpace;
    noteHead(note16thDown, GlyphBBoxesNoteheadBlack.bBoxSW.x, staffPosition);
    _xOff += 3*staffSpace;
    noteHead(barlineSingle, GlyphBBoxesNoteheadBlack.bBoxSW.x, 4);
    _xOff += 2*staffSpace;
    noteHead(restWhole, GlyphBBoxesNoteheadBlack.bBoxSW.x, 1);
    _xOff += 3*staffSpace;
    noteHead(restHalf, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3*staffSpace;
    noteHead(restQuarter, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3*staffSpace;
    noteHead(rest8th, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3*staffSpace;
    noteHead(rest16th, GlyphBBoxesNoteheadBlack.bBoxSW.x, 2);
    _xOff += 3*staffSpace;

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double bassClef(Canvas canvas, final double yOff) {
    const double xOff = 0.5 * staffSpace;
    final double fontSize = (GlyphBBoxesFClef.bBoxNE.y - GlyphBBoxesFClef.bBoxSW.y) * staffSpace;

    //    where should it be
//    canvas.drawRect(
//        Rect.fromLTWH(xOff, yOff, (GlyphBBoxesFClef.bBoxNE.x - GlyphBBoxesFClef.bBoxSW.x) * staffSpace,
//            (GlyphBBoxesFClef.bBoxNE.y - GlyphBBoxesFClef.bBoxSW.y) * staffSpace),
//        _grey);

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

    return xOff + GlyphBBoxesFClef.bBoxNE.x * staffSpace;
  }

  double trebleClef(Canvas canvas, final double yOff) {
    const double xOff = 0.5 * staffSpace;

    TextPainter(
      text: TextSpan(
        text: MusicConstants.trebleClef,
        style: TextStyle(
          fontFamily: 'Bravura',
          color: _black.color,
          fontSize: 3.8 * staffSpace,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: (GlyphBBoxesGClef.bBoxNE.x - GlyphBBoxesGClef.bBoxSW.x) * staffSpace,
      )
      ..paint(canvas, Offset(xOff, 0.3 * staffSpace));

    return xOff + GlyphBBoxesGClef.bBoxNE.x * staffSpace;
  }

  void noteHead(final String text, double x, double staffPosition) {
    double w = 4*staffSpace;
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
      ..paint(_canvas, Offset(_xOff + x * staffSpace, (_yOff ?? 0) + -2*w + (staffPosition - 0.05) * staffSpace));
  }

  Canvas _canvas;
  double _xOff;
  double _yOff;
}

final String noteheadWhole = '\uE0A2';
final String noteheadBlack = '\uE0A4';
final String stem = '\uE210';
final String brace = '\uE000';
final String barlineSingle = '\uE030';
final String timeSigCommon = '\uE08A';
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


final _white = Paint()..color = Colors.white;
final _grey = Paint()..color = Colors.grey;
final _black = Paint()..color = Colors.black;
final _blackFill = Paint()..color = Colors.black .. style= PaintingStyle.fill;

