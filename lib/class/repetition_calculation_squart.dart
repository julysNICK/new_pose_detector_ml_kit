import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

const double squatLimit = 183;

const double limitHigherFallSquat = 220;

const double limitLowerFallSquat = 190;

const double limitHigherSquat = 190;

const double limitLowerRiseSquat = 180;

class RepetitionCalculationSquatFront {
  int historyLength = 5;

  double angleThresholdMin = 180.0;

  double angleThresholdMax = 200.0;

  ManipulationArray manipulationArray = ManipulationArray();

  AngleVerifier angleVerifier = AngleVerifier();

  RepetitionCalculationSquatFront({
    this.historyLength = 5,
    this.angleThresholdMin = 180.0,
    this.angleThresholdMax = 200.0,
  });

  final List<double> angleHistory = [];

  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    manipulationArray.addAngleInArray2(
      angleHistory,
      angle,
      2,
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
