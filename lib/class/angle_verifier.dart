import 'package:new_pose_test/main.dart';

class AngleVerifier {
  bool verifyLengthArray(length, angleArray) {
    if ((length - angleArray.length) == 1 ||
        (length - angleArray.length) == 2) {
      return true;
    }

    return false;
  }

  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved, limitAccept) {
    print(
        "verifyLengthArray(5, angleHistory) $verifyLengthArray(5, angleHistory)");

    bool isAngleInRange = angleHistory.every((a) =>
        a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);

    print("isAngleInRange $isAngleInRange");

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      //70 -> 75
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    } else if (verifyLengthArray(5, angleHistory) &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
