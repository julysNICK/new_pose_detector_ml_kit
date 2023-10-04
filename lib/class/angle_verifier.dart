import 'package:new_pose_test/main.dart';

class AngleArrayLengthVerifier {
  bool verifyLengthArray(
      List<double> angleArray, int minLength, int maxLength) {
    if (angleArray.length >= minLength && angleArray.length <= maxLength) {
      return true;
    }

    return false;
  }
}

class AngleArrayValueVerifier {
  bool verifyAngleArray(
      List<double> angleArray, double minAngle, double maxAngle) {
    if (angleArray.every((a) => a >= minAngle && a <= maxAngle)) {
      return true;
    }

    return false;
  }
}

class AngleVerifier {
  final AngleArrayLengthVerifier angleArrayLengthVerifier =
      AngleArrayLengthVerifier();
  final AngleArrayValueVerifier angleArrayValueVerifier =
      AngleArrayValueVerifier();

  bool verifyLengthArray(angleArray) {
    return angleArrayLengthVerifier.verifyLengthArray(angleArray, 4, 5);
  }

  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved, limitAccept) {
    print(
        "verifyLengthArray(5, angleHistory) $verifyLengthArray(5, angleHistory)");

    bool isAngleInRange = angleArrayValueVerifier.verifyAngleArray(
        angleHistory, angleThresholdMin, angleThresholdMax);
    print("isAngleInRange $isAngleInRange");

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      //70 -> 75
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    } else if (verifyLengthArray(angleHistory) &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
