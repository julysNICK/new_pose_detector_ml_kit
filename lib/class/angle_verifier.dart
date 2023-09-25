import 'package:new_pose_test/main.dart';

class AngleVerifier {
  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved, limitAccept) {
    bool isAngleInRange = angleHistory.every((a) =>
        a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      //70 -> 75
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
