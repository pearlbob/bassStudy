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
                    height: 600.0,
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
    //  clear the plot
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _white);

    //  practice staff
    final double yOff = 5 * staffSpace;
    _black.style = PaintingStyle.stroke;
    _black.strokeWidth = EngravingDefaults.staffLineThickness * staffSpace;
    for (int line = 0; line < 5; line++) {
      canvas.drawLine(Offset(0, yOff + line * staffSpace), Offset(size.width, yOff + line * staffSpace), _black);
    }

    double xOff = bassClef(canvas, yOff);
    _grey.strokeWidth = EngravingDefaults.stemThickness * staffSpace;
    canvas.drawLine(Offset(xOff, yOff), Offset(xOff, yOff + 4 * staffSpace), _grey);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double bassClef(Canvas canvas, final double yOff) {
    const double xOff = 0.5 * staffSpace;

    TextPainter(
      text: TextSpan(
        text: MusicConstants.bassClef,
        style: TextStyle(
          fontFamily: 'Bravura',
          color: _black.color,
          fontSize: (GlyphBBoxesFClef.bBoxNE.y - GlyphBBoxesFClef.bBoxSW.y) * staffSpace,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: (GlyphBBoxesFClef.bBoxNE.x - GlyphBBoxesFClef.bBoxSW.x) * staffSpace,
      )
      ..paint(canvas, Offset(xOff, -1.25 * staffSpace));

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

//  class  GlyphBBoxesGClef {
//  static final Point<double> bBoxNE = Point( 2.684, 4.392 );
//  static final Point<double> bBoxSW = Point( 0.0, -2.632 );

}

final _white = Paint()..color = Colors.white;
final _grey = Paint()..color = Colors.grey;
final _black = Paint()..color = Colors.black;
