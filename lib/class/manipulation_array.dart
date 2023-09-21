class ManipulationArray {
  void addAngleInArray2(List<double> angleArray, double angle, double diff) {
    print("chamei addAngleInArray2");
    double? theLastAngle = angleArray.isNotEmpty ? angleArray.last : null;
    int roundedAngle = angle.round();

    var inBetweenInFall = (roundedAngle >= 130 && roundedAngle <= 140);

    var inBetweenRise = (roundedAngle >= 50 && roundedAngle < 130);
    if (theLastAngle == null && inBetweenInFall) {
      angleArray.add(angle.roundToDouble());
    } else if (theLastAngle != null &&
        inBetweenInFall &&
        angle < theLastAngle) {
      double diffAngle = theLastAngle - angle;
      if (diffAngle > diff) {
        angleArray.add(angle);
      }
    } else if (theLastAngle != null && inBetweenRise && angle < theLastAngle) {
      double diffAngle = angle - theLastAngle;

      if (diffAngle.abs() > diff) {
        angleArray.add(angle);
      }
    }
  }

  void verifyArray(List<double> angleArray, int length) {
    print("chamei verifyArray");
    if (angleArray.isNotEmpty) {
      double? theLastAngle = angleArray.last;
      if (angleArray.length == length && theLastAngle > 60) {
        angleArray.removeAt(0);
      }
    }
  }
}
