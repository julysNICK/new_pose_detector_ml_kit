import 'package:new_pose_test/class/angle_verifier.dart';
import 'package:new_pose_test/class/manipulation_array.dart';

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
    print("chamei calculationRepetition");
    manipulationArray.addAngleInArray2(angleHistory, angle, 3);

    manipulationArray.verifyArray(angleHistory, historyLength);

    return angleVerifier.verifyAngle(angleHistory, angleThresholdMin,
        angleThresholdMax, historyLength, angleHistoryApproved);
  }
}
