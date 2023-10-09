import 'dart:math';

import 'package:new_pose_test/class/exercise.dart';
import 'package:new_pose_test/class/repetition_calculation.dart';

class BarbellExercise implements Exercise {
  BarbellExercise();

  RepetitionCalculationBarbelSide repetitionCalculation =
      RepetitionCalculationBarbelSide();

  @override
  int calculationRepetition(double angle) {
    print('angle: $angle');
    return repetitionCalculation.calculationRepetition(angle);
  }

  @override
  Exercise createExercise() {
    return BarbellExercise();
  }
}
