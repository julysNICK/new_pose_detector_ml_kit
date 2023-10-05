import 'package:new_pose_test/class/arm_flexion_repetition_calculation.dart';

class ArmFlexionExercise {
  ArmFlexionExercise();

  RepetitionCalculationArmFlexion repetitionCalculation =
      RepetitionCalculationArmFlexion();

  int calculationRepetition(double angle) {
    print('angle: $angle');
    return repetitionCalculation.calculationRepetition(angle.roundToDouble());
  }
}
