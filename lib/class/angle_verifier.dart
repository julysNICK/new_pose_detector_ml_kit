class AngleVerifier {
  int verifyAngle(angleHistory, angleThresholdMin, angleThresholdMax,
      historyLength, angleHistoryApproved) {
    print("chamei verifyAngle");
    bool isAngleInRange = angleHistory.every((a) =>
        a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);

    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= 70) {
      angleHistoryApproved.addAll(angleHistory);
      angleHistory.clear();
      return 1;
    }

    return 0;
  }
}
