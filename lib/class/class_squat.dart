import 'dart:math';

import 'package:new_pose_test/class/repetition_calculation_squart.dart';

class SquatExercise {
  SquatExercise();

  RepetitionCalculationSquat repetitionCalculation =
      RepetitionCalculationSquat();

  int calculationRepetition(double angle) {
    print('angle: $angle');
    return repetitionCalculation.calculationRepetition(angle.roundToDouble());
  }
}
