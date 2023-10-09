import 'dart:math';

import 'package:new_pose_test/class/exercise.dart';
import 'package:new_pose_test/class/repetition_calculation_squart.dart';

class SquatExercise implements Exercise {
  SquatExercise();

  RepetitionCalculationSquatFront repetitionCalculation =
      RepetitionCalculationSquatFront();

  @override
  int calculationRepetition(double angle) {
    print('angle: $angle');
    return repetitionCalculation.calculationRepetition(angle.roundToDouble());
  }

  @override
  Exercise createExercise() {
    return SquatExercise();
  }
}
