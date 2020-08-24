import 'dart:convert';

import 'package:bsteeleMusicLib/appLogger.dart';


void parseJsonBsstVerion0_0(String s) {
  logger.i('parseJsonBsstVerion0_0: s.length=${s.length}');

  Map<String, dynamic> map = jsonDecode(s);
  if (map == null) {
    return;
  }
  String version = map['version'];
  if (version == null) {
    logger.w('unknown bsst file version missing!');
    return;
  }
  switch (version) {
    case '0.0':
      for (String key in map.keys) {
        logger.d('key: "$key"');
        switch (key) {
          case 'keyN':
          case 'beatsPerBar':
          case 'notesPerBar':
          case 'bpm':
          case 'isSwing8':
          case 'hiHatRhythm':
          case 'swingType':
            logger.d('   $key: "${map[key]}"');
            break;
          case 'warning':
          case 'version':
            break; //  ignore
          case 'sheetNotes':
            var sheetNotes = map[key];
            if (sheetNotes is List) {
              int i = 0;
              for (var item in sheetNotes) {
                logger.d('${i++}:');
                if (item is Map) {
                  bool isNote = true;   //  default only

                  //  process these first
                  for (var attr in item.keys) {
                    switch (attr) {
                      case 'isNote':
                         isNote = item[attr];
                        logger.d('    $attr: ${isNote.toString()}');
                        break;
                    }
                  }

                  for (var attr in item.keys) {
                    switch (attr) {
                      case 'isNote':
                        break;
                      case 'string': //  which bass string!
                        int string = item[attr];
                        logger.d('    $attr: ${string.toString()}');
                        break;
                      case 'fret':
                        int fret = item[attr];
                        logger.d('    $attr: ${fret.toString()}');
                        break;
                      case 'noteDuration': //  encoded
                        _NoteDuration _noteDuration = (isNote?_noteDurations[item[attr]]:_restDurations[item[attr]]);
                        logger.d('    $attr: ${_noteDuration.toString()}');
                        break;
                      case 'chordN': //  encoded
                        int chordN = item[attr];
                        logger.d('    $attr: ${chordN.toString()}');
                        break;
                      case 'chordModifier':
                        String chordModifier = item[attr];
                        logger.d('    $attr: $chordModifier');
                        break;
                      case 'minorMajor':
                        String minorMajor = item[attr];
                        logger.d('    $attr: ${minorMajor.toString()}');
                        break;
                      case 'minorMajorSelectIndex':
                        int minorMajorSelectIndex = item[attr];
                        logger.d('    $attr: ${minorMajorSelectIndex.toString()}');
                        break;
                      case 'scaleN':
                        int scaleN = item[attr];
                        logger.d('    $attr: ${scaleN.toString()}');
                        break;
                      case 'lyrics':
                        String lyrics = item[attr];
                        logger.d('    $attr: "$lyrics"');
                        break;
                      case 'tied':
                        bool tied = item[attr];
                        logger.d('    $attr: ${tied.toString()}');
                        break;
                      default:
                        logger.w('unknown attribute: "$attr" = "${item[attr].toString()}"');
                        break;
                    }
                  }
                } else
                  logger.w('sheetNotes item wrong type: ${item.runtimeType.toString()}: ${item.toString()}');
              }
            } else
              logger.w('sheetNotes wrong type: ${sheetNotes.runtimeType.toString()}');
            break;
          default:
            logger.w('unknown bsst file key: $key = "${map[key].toString()}"');
            break;
        }
      }
      break;
    default:
      logger.w('unknown bsst file version: $version');
      return;
  }
}

class _NoteDuration {
  _NoteDuration(this.duration, this.dotted, this.name);

  @override
  String toString() {
    return '${duration.toStringAsFixed(4)} ${dotted ? ' dotted' : ''} $name';
  }

  String name;
  double duration;
  bool dotted = false;
}

/// map from json bsst values to note durations
List<_NoteDuration> _noteDurations = [
  //  un-dotted
  _NoteDuration(1, false, 'whole'),
  _NoteDuration(1 / 2, false, 'half'),
  _NoteDuration(1 / 4, false, 'quarter'),
  _NoteDuration(1 / 8, false, 'eighth'),
  _NoteDuration(1 / 16, false, 'sixteenth'),
  //  dotted
  _NoteDuration(1, true, 'whole'), //  placeholder
  _NoteDuration(3 / 4, true, 'half'),
  _NoteDuration(3 / 8, true, 'quarter'),
  _NoteDuration(3 / 16, true, 'eighth'),
  _NoteDuration(3 / 32, true, 'sixteenth'),
];

/// map from json bsst values to rest durations
List<_NoteDuration> _restDurations = [
  _NoteDuration(1, false, 'whole rest'),
  _NoteDuration(1 / 2, false, 'half rest'),
  _NoteDuration(1 / 4, false, 'quarter rest'),
  _NoteDuration(1 / 8, false, 'eighth rest'),
  _NoteDuration(1 / 16, false, 'sixteenth rest'),
];
