import 'dart:math';
import 'dart:ui';

import 'package:bsteeleMusicLib/songs/chord.dart';

import 'SheetMusic.dart';

const double staffGaps = 4;   //  always!
const double staffMargin = 3;

//final String noteheadBlack = '\uE0A4';
//final String stem = '\uE210';
//final String repeat1Bar = '\uE500';

class SheetNoteSymbol {
  SheetNoteSymbol.glyphBBoxes(this._name, this._character, Point<double> bBoxNE, Point<double> bBoxSW)
      : _bounds = Rect.fromLTRB(bBoxSW.x, bBoxNE.y, bBoxNE.x, bBoxSW.y);

  SheetNoteSymbol.glyphBBoxesRest(
      this._name, this._character, Point<double> bBoxNE, Point<double> bBoxSW, this._restYOff)
      : _bounds = Rect.fromLTRB(bBoxSW.x, bBoxNE.y, bBoxNE.x, bBoxSW.y);

  get name => _name;
  String _name;

  get character => _character;
  String _character;

  get fontSizeStaffs => _fontSizeStaffs;
  double _fontSizeStaffs = 4;

  get bounds => _bounds;
  Rect _bounds;

  get isUp => _isUp;
  bool _isUp = true;

  get focusPoint => _focusPoint;
  Point<double> _focusPoint = Point(0, 0);

  get restYOff => _restYOff;
  double _restYOff;
}

//  notes
final SheetNoteSymbol noteWhole =
    SheetNoteSymbol.glyphBBoxes('noteWhole', '\uE1D2', GlyphBBoxesNoteWhole.bBoxNE, GlyphBBoxesNoteWhole.bBoxSW);
final SheetNoteSymbol noteHalfUp =
    SheetNoteSymbol.glyphBBoxes('noteHalfUp', '\uE1D3', GlyphBBoxesNoteHalfUp.bBoxNE, GlyphBBoxesNoteHalfUp.bBoxSW);
final SheetNoteSymbol noteHalfDown = SheetNoteSymbol.glyphBBoxes(
    'noteHalfDown', '\uE1D4', GlyphBBoxesNoteHalfDown.bBoxNE, GlyphBBoxesNoteHalfDown.bBoxSW).._isUp = false;
final SheetNoteSymbol noteQuarterUp = SheetNoteSymbol.glyphBBoxes(
    'noteQuarterUp', '\uE1D5', GlyphBBoxesNoteQuarterUp.bBoxNE, GlyphBBoxesNoteQuarterUp.bBoxSW);
final SheetNoteSymbol noteQuarterDown = SheetNoteSymbol.glyphBBoxes(
    'noteQuarterDown', '\uE1D6', GlyphBBoxesNoteQuarterDown.bBoxNE, GlyphBBoxesNoteQuarterDown.bBoxSW).._isUp = false;
final SheetNoteSymbol note8thUp =
    SheetNoteSymbol.glyphBBoxes('note8thUp', '\uE1D7', GlyphBBoxesNote8thUp.bBoxNE, GlyphBBoxesNote8thUp.bBoxSW);
final SheetNoteSymbol note8thDown =
    SheetNoteSymbol.glyphBBoxes('note8thDown', '\uE1D8', GlyphBBoxesNote8thDown.bBoxNE, GlyphBBoxesNote8thDown.bBoxSW)
      .._isUp = false;
final SheetNoteSymbol note16thUp =
    SheetNoteSymbol.glyphBBoxes('note16thUp', '\uE1D9', GlyphBBoxesNote16thUp.bBoxNE, GlyphBBoxesNote16thUp.bBoxSW);
final SheetNoteSymbol note16thDown = SheetNoteSymbol.glyphBBoxes(
    'note16thDown', '\uE1DA', GlyphBBoxesNote16thDown.bBoxNE, GlyphBBoxesNote16thDown.bBoxSW).._isUp = false;

//  rests
final SheetNoteSymbol restWhole =
    SheetNoteSymbol.glyphBBoxesRest('restWhole', '\uE4E3', GlyphBBoxesRestWhole.bBoxNE, GlyphBBoxesRestWhole.bBoxSW, 1);
final SheetNoteSymbol restHalf =
    SheetNoteSymbol.glyphBBoxesRest('restHalf', '\uE4E4', GlyphBBoxesRestHalf.bBoxNE, GlyphBBoxesRestHalf.bBoxSW, 2);
final SheetNoteSymbol restQuarter = SheetNoteSymbol.glyphBBoxesRest(
    'restQuarter', '\uE4E5', GlyphBBoxesRestQuarter.bBoxNE, GlyphBBoxesRestQuarter.bBoxSW, 2);
final SheetNoteSymbol rest8th =
    SheetNoteSymbol.glyphBBoxesRest('rest8th', '\uE4E6', GlyphBBoxesRest8th.bBoxNE, GlyphBBoxesRest8th.bBoxSW, 2);
final SheetNoteSymbol rest16th =
    SheetNoteSymbol.glyphBBoxesRest('rest16th', '\uE4E7', GlyphBBoxesRest16th.bBoxNE, GlyphBBoxesRest16th.bBoxSW, 2);

//  markers
final SheetNoteSymbol brace =
    SheetNoteSymbol.glyphBBoxes('brace', '\uE000', GlyphBBoxesBrace.bBoxNE, GlyphBBoxesBrace.bBoxSW)
      .._fontSizeStaffs = 2*4+2*staffMargin;
final SheetNoteSymbol barlineSingle = SheetNoteSymbol.glyphBBoxes(
    'barlineSingle', '\uE030', GlyphBBoxesBarlineSingle.bBoxNE, GlyphBBoxesBarlineSingle.bBoxSW);
final SheetNoteSymbol trebleClef //  i.e. gClef
    = SheetNoteSymbol.glyphBBoxes('trebleClef', '\uE050', GlyphBBoxesGClef.bBoxNE, GlyphBBoxesGClef.bBoxSW)
      .._restYOff = 3;
final SheetNoteSymbol bassClef //  i.e. fClef
    = SheetNoteSymbol.glyphBBoxes('bassClef', '\uE062', GlyphBBoxesFClef.bBoxNE, GlyphBBoxesFClef.bBoxSW)
      .._restYOff = 1.1;

//  accidentals
final SheetNoteSymbol accidentalFlat = SheetNoteSymbol.glyphBBoxes(
    'accidentalFlat', '\uE260', GlyphBBoxesAccidentalFlat.bBoxNE, GlyphBBoxesAccidentalFlat.bBoxSW);
final SheetNoteSymbol accidentalNatural = SheetNoteSymbol.glyphBBoxes(
    'accidentalNatural', '\uE261', GlyphBBoxesAccidentalNatural.bBoxNE, GlyphBBoxesAccidentalNatural.bBoxSW);
final SheetNoteSymbol accidentalSharp = SheetNoteSymbol.glyphBBoxes(
    'accidentalSharp', '\uE262', GlyphBBoxesAccidentalSharp.bBoxNE, GlyphBBoxesAccidentalSharp.bBoxSW);
final SheetNoteSymbol augmentationDot = SheetNoteSymbol.glyphBBoxes(
    'augmentationDot', '\uE1E7', GlyphBBoxesAugmentationDot.bBoxNE, GlyphBBoxesAugmentationDot.bBoxSW);


//  time signatures
final SheetNoteSymbol timeSig0 =
    SheetNoteSymbol.glyphBBoxes('timeSig0', '\uE080', GlyphBBoxesTimeSig0.bBoxNE, GlyphBBoxesTimeSig0.bBoxSW);
final SheetNoteSymbol timeSig1 =
    SheetNoteSymbol.glyphBBoxes('timeSig1', '\uE081', GlyphBBoxesTimeSig1.bBoxNE, GlyphBBoxesTimeSig1.bBoxSW);
final SheetNoteSymbol timeSig2 =
    SheetNoteSymbol.glyphBBoxes('timeSig2', '\uE082', GlyphBBoxesTimeSig2.bBoxNE, GlyphBBoxesTimeSig2.bBoxSW);
final SheetNoteSymbol timeSig3 =
    SheetNoteSymbol.glyphBBoxes('timeSig3', '\uE083', GlyphBBoxesTimeSig3.bBoxNE, GlyphBBoxesTimeSig3.bBoxSW);
final SheetNoteSymbol timeSig4 =
    SheetNoteSymbol.glyphBBoxes('timeSig4', '\uE084', GlyphBBoxesTimeSig4.bBoxNE, GlyphBBoxesTimeSig4.bBoxSW);
final SheetNoteSymbol timeSig5 =
    SheetNoteSymbol.glyphBBoxes('timeSig5', '\uE085', GlyphBBoxesTimeSig5.bBoxNE, GlyphBBoxesTimeSig5.bBoxSW);
final SheetNoteSymbol timeSig6 =
    SheetNoteSymbol.glyphBBoxes('timeSig6', '\uE086', GlyphBBoxesTimeSig6.bBoxNE, GlyphBBoxesTimeSig6.bBoxSW);
final SheetNoteSymbol timeSig7 =
    SheetNoteSymbol.glyphBBoxes('timeSig7', '\uE087', GlyphBBoxesTimeSig7.bBoxNE, GlyphBBoxesTimeSig7.bBoxSW);
final SheetNoteSymbol timeSig8 =
    SheetNoteSymbol.glyphBBoxes('timeSig8', '\uE088', GlyphBBoxesTimeSig8.bBoxNE, GlyphBBoxesTimeSig8.bBoxSW);
final SheetNoteSymbol timeSig9 =
    SheetNoteSymbol.glyphBBoxes('timeSig9', '\uE089', GlyphBBoxesTimeSig9.bBoxNE, GlyphBBoxesTimeSig9.bBoxSW);
final SheetNoteSymbol timeSigCommon = SheetNoteSymbol.glyphBBoxes(
    'timeSigCommon', '\uE08A', GlyphBBoxesTimeSigCommon.bBoxNE, GlyphBBoxesTimeSigCommon.bBoxSW);

enum ClefEnum {
  treble,
  bass,
}

enum InstrumentEnum {
  guitar,
  bass,
  piano,
}

class SheetNote {
  bool isNote; //  or a rest
  bool get isRest => !isNote;
  InstrumentEnum instrument;

  int stringNumber; //  guitar, bass
  int fret;

  double noteDuration;
  Chord chord;

  String lyrics;
  bool tied;
  int line;
  int m; //  ????

  SheetNoteSymbol symbol;
}
