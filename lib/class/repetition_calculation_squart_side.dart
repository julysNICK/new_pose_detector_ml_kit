import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

const double squatLimit = 127;

const double limitHigherFallSquat = 175;

const double limitLowerFallSquat = 150;

const double limitHigherSquat = 150;

const double limitLowerRiseSquat = 120;

class RepetitionCalculationSquatSide {
  int historyLength = 5;

  double angleThresholdMin = 120.0;

  double angleThresholdMax = 175.0;

  ManipulationArray manipulationArray = ManipulationArray();

  AngleVerifier angleVerifier = AngleVerifier();

  RepetitionCalculationSquatSide({
    this.historyLength = 5,
    this.angleThresholdMin = 120.0,
    this.angleThresholdMax = 175.0,
  });

  final List<double> angleHistory = [];

  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    manipulationArray.addAngleInArray2(
      angleHistory,
      angle,
      1,
      limitHigherFallSquat,
      limitLowerFallSquat,
      limitHigherSquat,
      limitLowerRiseSquat,
    );

    manipulationArray.verifyArray(angleHistory, historyLength, squatLimit);

    return angleVerifier.verifyAngle(angleHistory, angleThresholdMin,
        angleThresholdMax, historyLength, angleHistoryApproved, squatLimit);
  }
}
