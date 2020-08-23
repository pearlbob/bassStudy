import 'dart:math';
import 'dart:ui';

import 'package:bsteeleMusicLib/songs/chord.dart';

import 'SheetMusic.dart';

//final String noteheadWhole = '\uE0A2';
final String noteheadBlack = '\uE0A4';
final String stem = '\uE210';

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

class SheetNoteSymbol {
  SheetNoteSymbol.glyphBBoxes(this._name, this._character, Point<double> bBoxNE, Point<double> bBoxSW)
      : _bounds = Rect.fromLTRB(bBoxSW.x, bBoxNE.y, bBoxNE.x, bBoxSW.y);

  SheetNoteSymbol.glyphBBoxesRest(
      this._name, this._character, Point<double> bBoxNE, Point<double> bBoxSW, double this._restYOff)
      : _bounds = Rect.fromLTRB(bBoxSW.x, bBoxNE.y, bBoxNE.x, bBoxSW.y );

  get name => _name;
  String _name;

  get character => _character;
  String _character;

  get fontSizeStaffs => _fontSizeStaffs;
  double _fontSizeStaffs = 4;

  get bounds => _bounds;
  Rect _bounds;

  get focusPoint => _focusPoint;
  Point<double> _focusPoint = Point(0, 0);

  get restYOff => _restYOff;
  double _restYOff;
}

final SheetNoteSymbol noteWhole =
    SheetNoteSymbol.glyphBBoxes('noteWhole', '\uE1D2', GlyphBBoxesNoteWhole.bBoxNE, GlyphBBoxesNoteWhole.bBoxSW);
final SheetNoteSymbol noteHalfUp =
    SheetNoteSymbol.glyphBBoxes('noteHalfUp', '\uE1D3', GlyphBBoxesNoteHalfUp.bBoxNE, GlyphBBoxesNoteHalfUp.bBoxSW);
final SheetNoteSymbol noteHalfDown = SheetNoteSymbol.glyphBBoxes(
    'noteHalfDown', '\uE1D4', GlyphBBoxesNoteHalfDown.bBoxNE, GlyphBBoxesNoteHalfDown.bBoxSW);
final SheetNoteSymbol noteQuarterUp = SheetNoteSymbol.glyphBBoxes(
    'noteQuarterUp', '\uE1D5', GlyphBBoxesNoteQuarterUp.bBoxNE, GlyphBBoxesNoteQuarterUp.bBoxSW);
final SheetNoteSymbol noteQuarterDown = SheetNoteSymbol.glyphBBoxes(
    'noteQuarterDown', '\uE1D6', GlyphBBoxesNoteQuarterDown.bBoxNE, GlyphBBoxesNoteQuarterDown.bBoxSW);
final SheetNoteSymbol note8thUp =
    SheetNoteSymbol.glyphBBoxes('note8thUp', '\uE1D7', GlyphBBoxesNote8thUp.bBoxNE, GlyphBBoxesNote8thUp.bBoxSW);
final SheetNoteSymbol note8thDown =
    SheetNoteSymbol.glyphBBoxes('note8thDown', '\uE1D8', GlyphBBoxesNote8thDown.bBoxNE, GlyphBBoxesNote8thDown.bBoxSW);
final SheetNoteSymbol note16thUp =
    SheetNoteSymbol.glyphBBoxes('note16thUp', '\uE1D9', GlyphBBoxesNote16thUp.bBoxNE, GlyphBBoxesNote16thUp.bBoxSW);
final SheetNoteSymbol note16thDown = SheetNoteSymbol.glyphBBoxes(
    'note16thDown', '\uE1DA', GlyphBBoxesNote16thDown.bBoxNE, GlyphBBoxesNote16thDown.bBoxSW);

final SheetNoteSymbol brace =
    SheetNoteSymbol.glyphBBoxes('brace', '\uE000', GlyphBBoxesBrace.bBoxNE, GlyphBBoxesBrace.bBoxSW)
      .._fontSizeStaffs = 12;

final SheetNoteSymbol barlineSingle = SheetNoteSymbol.glyphBBoxes(
    'barlineSingle', '\uE030', GlyphBBoxesBarlineSingle.bBoxNE, GlyphBBoxesBarlineSingle.bBoxSW);

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

}
