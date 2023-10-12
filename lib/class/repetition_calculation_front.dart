import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

const double barbellLimit = 30;

const double limitHigherFallBarbell = 200;

const double limitLowerFallBarbell = 170;

const double limitHigherRiseBarbell = 170;

const double limitLowerRiseBarbell = 20;

class RepetitionCalculationBarbelFront {
  int historyLength = 5;

  double angleThresholdMin = 10.0;

  double angleThresholdMax = 230.0;

  ManipulationArray manipulationArray = ManipulationArray();

  AngleVerifier angleVerifier = AngleVerifier();

  RepetitionCalculationBarbelFront({
    this.historyLength = 5,
    this.angleThresholdMin = 10.0,
    this.angleThresholdMax = 190.0,
  });

  final List<double> angleHistory = [];

  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    manipulationArray.addAngleInArray2(
      angleHistory,
      manipulationArray.convertAngleHighestLimit(angle, angleHistory),
      2,
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
