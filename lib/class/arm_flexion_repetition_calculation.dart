import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

const double FlexionLimit = 187;

const double limitHigherFallFlexion = 220;

const double limitLowerFallFlexion = 200;

const double limitHigherFlexion = 200;

const double limitLowerRiseFlexion = 180;

class RepetitionCalculationArmFlexion {
  int historyLength = 5;

  double angleThresholdMin = 180.0;

  double angleThresholdMax = 220.0;

  ManipulationArray manipulationArray = ManipulationArray();

  AngleVerifier angleVerifier = AngleVerifier();

  RepetitionCalculationArmFlexion({
    this.historyLength = 5,
    this.angleThresholdMin = 180.0,
    this.angleThresholdMax = 220.0,
  });

  final List<double> angleHistory = [];

  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    manipulationArray.addAngleInArray2(
      angleHistory,
      angle,
      1,
      limitHigherFallFlexion,
      limitLowerFallFlexion,
      limitHigherFlexion,
      limitLowerRiseFlexion,
    );

    manipulationArray.verifyArray(angleHistory, historyLength, FlexionLimit);

    return angleVerifier.verifyAngle(angleHistory, angleThresholdMin,
        angleThresholdMax, historyLength, angleHistoryApproved, FlexionLimit);
  }
}
