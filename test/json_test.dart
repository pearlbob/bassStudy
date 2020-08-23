import 'dart:math';

import 'package:bsteeleMusicLib/appLogger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  Logger.level = Level.debug;

  test('Optimizer test', ()
  {
    logger.d('debugging:');
  });
}