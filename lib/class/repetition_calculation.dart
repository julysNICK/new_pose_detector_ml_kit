import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

const double barbellLimit = 80;

const double limitHigherFallBarbell = 141;

const double limitLowerFallBarbell = 130;

const double limitHigherRiseBarbell = 130;

const double limitLowerRiseBarbell = 70;

class RepetitionCalculation {
  int historyLength = 3;

  double angleThresholdMin = 50.0;

  double angleThresholdMax = 140.0;

  ManipulationArray manipulationArray = ManipulationArray();

  AngleVerifier angleVerifier = AngleVerifier();

  RepetitionCalculation({
    this.historyLength = 3,
    this.angleThresholdMin = 50.0,
    this.angleThresholdMax = 140.0,
  });

  final List<double> angleHistory = [];

  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    manipulationArray.addAngleInArray2(
      angleHistory,
      angle,
      3,
      limitHigherFallBarbell,
      limitLowerFallBarbell,
      limitHigherRiseBarbell,
      limitLowerRiseBarbell,
    );

    manipulationArray.verifyArray(angleHistory, historyLength, barbellLimit);

    return angleVerifier.verifyAngle(angleHistory, angleThresholdMin,
        angleThresholdMax, historyLength, angleHistoryApproved, barbellLimit);
  }
}
