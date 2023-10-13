import 'dart:math';

import 'package:new_pose_test/class/exercise.dart';
import 'package:new_pose_test/class/repetition_calculation.dart';
import 'package:new_pose_test/class/repetition_calculation_front.dart';

class BarbellExercise implements Exercise {
  BarbellExercise();

  RepetitionCalculationBarbelFront repetitionCalculation =
      RepetitionCalculationBarbelFront();

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
