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

  bool verifyLengthArray(
    angleArray, {
    int minLength = 4,
    int maxLength = 5,
  }) {
    return angleArrayLengthVerifier.verifyLengthArray(
        angleArray, minLength, maxLength);
  }

  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved, limitAccept) {
    // print("angleHistory $angleHistory");
    // print(
    //     "verifyLengthArray(5, angleHistory) ${verifyLengthArray(angleHistory)}");

    bool isAngleInRange = angleArrayValueVerifier.verifyAngleArray(
        angleHistory, angleThresholdMin, angleThresholdMax);
    // print("isAngleInRange $isAngleInRange");

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      // print("Contei");
      //70 -> 75
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    } else if (verifyLengthArray(angleHistory,
            minLength: 3, maxLength: historyLength) &&
        isAngleInRange &&
        angleHistory.last <= limitAccept) {
      // print("Contei");
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
