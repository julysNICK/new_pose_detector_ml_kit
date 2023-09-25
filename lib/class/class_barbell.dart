import 'dart:math';

import 'package:new_pose_test/class/repetition_calculation.dart';

class BarbellExercise {
  BarbellExercise();

  RepetitionCalculation repetitionCalculation = RepetitionCalculation();

  int calculationRepetition(double angle) {
    print('angle: $angle');
    return repetitionCalculation.calculationRepetition(angle);
  }
}
