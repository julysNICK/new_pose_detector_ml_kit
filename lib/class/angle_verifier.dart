class AngleVerifier {
  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved) {
    bool isAngleInRange = angleHistory.every((a) =>
        a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= 80) {
      //70 -> 75
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
