class ManipulationArray {
  bool isInBetweenInFall(
      int roundedAngle, double limitHigherFall, double limitLowerFall) {
    return (roundedAngle >= limitLowerFall && roundedAngle <= limitHigherFall);
  }

  bool isInBetweenRise(
      int roundedAngle, double limitHigherRise, double limitLowerRise) {
    return (roundedAngle >= limitLowerRise && roundedAngle < limitHigherRise);
  }

  bool shouldAddAngleToArray(
    double angle,
    double? theLastAngle,
    double diff,
    double limitHigherFallSquat,
    double limitLowerFallSquat,
    double limitHigherSquat,
    double limitLowerRiseSquat,
  ) {
    if (theLastAngle == null &&
        isInBetweenInFall(
            angle.round(), limitHigherFallSquat, limitLowerFallSquat)) {
      return true;
    } else if (theLastAngle != null &&
        isInBetweenInFall(
            angle.round(), limitHigherFallSquat, limitLowerFallSquat) &&
        angle < theLastAngle) {
      double diffAngle = theLastAngle - angle;

      if (diffAngle >= diff) {
        return true;
      }
    } else if (theLastAngle != null &&
        isInBetweenRise(angle.round(), limitHigherSquat, limitLowerRiseSquat) &&
        angle < theLastAngle) {
      double diffAngle = angle - theLastAngle;

      if (diffAngle.abs() >= diff) {
        return true;
      }
    }

    return false;
  }

  void addAngleInArray2(
      List<double> angleArray,
      double angle,
      double diff,
      double limitHigherFall,
      double limitLowerFall,
      double limitHigherRise,
      double limitLowerRise) {
    if (shouldAddAngleToArray(
        angle,
        angleArray.isNotEmpty ? angleArray.last : null,
        diff,
        limitHigherFall,
        limitLowerFall,
        limitHigherRise,
        limitLowerRise)) {
      angleArray.add(angle);
      print('angleArray: $angleArray');
    }
  }

  void verifyArray(List<double> angleArray, int length, double limitToAccept) {
    if (angleArray.isNotEmpty) {
      double? theLastAngle = angleArray.last; //60-> 80
      if (angleArray.length == length && theLastAngle > limitToAccept) {
        angleArray.removeAt(0);
      }
    }
  }
}
