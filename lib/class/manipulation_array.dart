class ManipulationArray {
  void addAngleInArray2(List<double> angleArray, double angle, double diff) {
    double? theLastAngle = angleArray.isNotEmpty ? angleArray.last : null;
    int roundedAngle = angle.round();

    var inBetweenInFall = (roundedAngle >= 130 && roundedAngle <= 141);
//50-> 70
    var inBetweenRise = (roundedAngle >= 70 && roundedAngle < 130);
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
    if (angleArray.isNotEmpty) {
      double? theLastAngle = angleArray.last; //60-> 80
      if (angleArray.length == length && theLastAngle > 80) {
        angleArray.removeAt(0);
      }
    }
  }
}
