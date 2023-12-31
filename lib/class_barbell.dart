import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleTracker {
  int historyLength = 3;
  double angleThresholdMin = 50.0;
  double angleThresholdMax = 140.0;

  AngleTracker({
    this.historyLength = 3,
    this.angleThresholdMin = 50.0,
    this.angleThresholdMax = 140.0,
  });

  final List<double> angleHistory = [];
  final List<double> angleHistoryApproved = [];

  int calculationRepetition(double angle) {
    print("calculationRepetition");
    angleHistory.add(angle);
    if (angleHistory.length > historyLength) {
      print("remove");
      angleHistory.removeAt(0);
    }
    if (angleHistory.length == historyLength) {
      print("angleHistory.length == historyLength");
      int count = 0;
      for (int i = 0; i < angleHistory.length; i++) {
        print("angleHistory[i]");
        if (angleHistory[i] < angleThresholdMin ||
            angleHistory[i] > angleThresholdMax) {
          print("angleHistory[i] < angleThresholdMin");
          count++;
        }
      }
      return count;
    }
    return 0;
  }

  int calculationRepetition2(double angle) {
    //mudar a angulação na hora da descida
    print(angle);
    addAngleInArray(angleHistory, angle, 2);

    // verifyArray(angleHistory, historyLength);

    // verifyIfExistRepetitions(angleHistory);

    print("angleHistory.length ${angleHistory.length}");
    if (angleHistory.length > historyLength) {
      angleHistory.removeAt(0);
    }
    bool isAngleInRange = angleHistory.every((a) =>
        a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);
    if (angleHistory.length == historyLength &&
        isAngleInRange &&
        angleHistory.last <= 90) {
      //60
      print("angleHistoryApproved");
      angleHistoryApproved.addAll(angleHistory);
      print(angleHistoryApproved);

      angleHistory.clear();
      return 1;
    }

    return 0;
  }

  double slopeLineShoulderAndHip(
      double xShoulder, double yShoulder, double xHip, double yHip) {
    double m = (yHip - yShoulder) / (xHip - xShoulder);
    return m;
  }

  int calculationRepetition3(double angle) {
    addAngleInArray2(angleHistory, angle, 3);

    verifyArray(angleHistory, historyLength);

    print("angleHistory: $angleHistory");

    // verifyIfExistRepetitions(angleHistory);

    // if (angleHistory.length > historyLength) {
    //   angleHistory.removeAt(0);
    // }
    // bool isAngleInRange = angleHistory.every((a) =>
    //     a.round() >= angleThresholdMin && a.round() <= angleThresholdMax);
    // if (angleHistory.length == historyLength &&
    //     isAngleInRange &&
    //     angleHistory.last <= 60) {
    //   angleHistoryApproved.addAll(angleHistory);
    //   angleHistory.clear();
    //   complete++;

    //   return 1;
    // }

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

  void addAngleInArray2(List<double> angleArray, double angle, double diff) {
    double? theLastAngle = angleArray.isNotEmpty ? angleArray.last : null;
    int roundedAngle = angle.round();
    print("roundedAngle: $roundedAngle");

    // if (theLastAngle == null && (roundedAngle >= 150 && roundedAngle <= 160)) {
    //   angleArray.add(angle.roundToDouble());
    // } else if (theLastAngle != null &&
    //     (roundedAngle <= 140 && roundedAngle >= 55)) {
    //   double diffAngle = theLastAngle - angle;

    //   if (diffAngle > diff) {
    //     angleArray.add(angle);
    //   }
    // }

    var inBetweenInFall = (roundedAngle >= 130 && roundedAngle <= 140);
    print("inBetweenInFall: $inBetweenInFall");
    var inBetweenRise = (roundedAngle >= 50 && roundedAngle < 130);
    print("inBetweenRise: $inBetweenRise");
    // var inBetweenMiddle = (roundedAngle >= 140 && roundedAngle < 50);

    if (theLastAngle == null && inBetweenInFall) {
      print("theLastAngle == null && inBetweenInFall");
      angleArray.add(angle.roundToDouble());
    } else if (theLastAngle != null &&
        inBetweenInFall &&
        angle < theLastAngle) {
      print("theLastAngle != null && inBetweenInFall && angle < theLastAngle");
      double diffAngle = theLastAngle - angle;
      if (diffAngle > diff) {
        angleArray.add(angle);
      }
    } else if (theLastAngle != null && inBetweenRise && angle < theLastAngle) {
      print("theLastAngle != null && inBetweenRise && angle > theLastAngle");
      double diffAngle = angle - theLastAngle;
      print("diffAngle: $diffAngle");
      if (diffAngle.abs() > diff) {
        angleArray.add(angle);
      }
    }
  }

  void verifyArray(List<double> angleArray, int length) {
    if (angleArray.isNotEmpty) {
      double? theLastAngle = angleArray.last;
      if (angleArray.length == length && theLastAngle > 60) {
        angleArray.removeAt(0);
      }
    }
  }

  void addAngleInArray(List<double> angleArray, double angle, double diff) {
    double? theLastAngle = angleArray.isNotEmpty ? angleArray.last : null;
    int roundedAngle = angle.round();

    if (theLastAngle == null && (roundedAngle >= 130 && roundedAngle <= 160)) {
      print("first angle added $angle");
      angleArray.add(angle.roundToDouble());
    } else if (theLastAngle != null &&
        (roundedAngle <= 140 && roundedAngle >= 85)) {
      //55
      print(" linha 80angle added $angle");
      double diffAngle = theLastAngle - angle;
      print("double diffAngle = $theLastAngle - $angle");
      print("linha 83 diffAngle $diffAngle");

      if (diffAngle > diff) {
        print("linha 86 angle added $angle");
        angleArray.add(angle);
      }
    }
  }

  void verifyArray2(List<double> angleArray, int length) {
    if (angleArray.isNotEmpty) {
      double? theLastAngle = angleArray.last;
      if (angleArray.length == length && theLastAngle > 60) {
        angleArray.removeAt(0);
      }
    }
  }

  void verifyIfExistRepetitions(List<double> angleArray) {
    bool existsNumbersRepeated = false;
    Set<double> withoutRepetitions;

    for (var angle in angleArray) {
      int count = 0;
      for (var angle2 in angleArray) {
        if (angle == angle2) {
          count++;
        }
      }
      if (count > 1) {
        existsNumbersRepeated = true;
      }
    }

    if (existsNumbersRepeated) {
      withoutRepetitions = angleArray.toSet();
      angleArray.clear();
      angleArray.addAll(withoutRepetitions);
    }
  }
}

class AngleTrackerUpdate {
  double angleThresholdMin = 45.0;
  double angleThresholdMax = 150.0;
  bool isCompletingMovement = false;
  int count = 0;

  void updateAngle(double angle) {
    if (!isCompletingMovement) {
      if (angle >= angleThresholdMin && angle <= angleThresholdMax) {
        isCompletingMovement = true;
      }
    } else {
      if (angle > angleThresholdMin && angle < angleThresholdMax) {
        isCompletingMovement = false;
        count++;
      }
    }
  }
}

class RepetitionTrack {
  final int windowSize = 10;
  final double angleThresholdMin = 45.0;
  final double angleThresholdMax = 150.0;
  final double distanceThreshold = 10.0;

  final List<double> elbowAngles = [];
  final List<double> wristDistances = [];
  int count = 0;
  bool isCompletingMovement = false;

  void update(Pose pose) {
    if (elbowAngles.length == windowSize) {
      elbowAngles.removeAt(0);
      wristDistances.removeAt(0);
    }

    double angleC = calculateAngleInBarbellCurls(pose);
    double distance = calculateDistanceBetweenWristAndElbow(pose);

    elbowAngles.add(angleC);
    wristDistances.add(distance);

    if (elbowAngles.length >= windowSize) {
      double avgAngle =
          elbowAngles.reduce((a, b) => a + b) / elbowAngles.length;
      double avgDistance =
          wristDistances.reduce((a, b) => a + b) / wristDistances.length;

      // if (avgAngle <= angleThresholdMin &&
      //     avgAngle >= angleThresholdMax &&
      //     avgDistance <= distanceThreshold) {
      //   count++;
      // }

      if (!isCompletingMovement) {
        if (avgAngle >= angleThresholdMin &&
            avgAngle <= angleThresholdMax &&
            avgDistance <= distanceThreshold) {
          isCompletingMovement = true;
        }
      } else {
        if (avgAngle > angleThresholdMin &&
            avgAngle < angleThresholdMax &&
            avgDistance <= distanceThreshold) {
          isCompletingMovement = false;
          count++;
        }
      }
    }
  }

  void reset() {
    elbowAngles.clear();
    wristDistances.clear();
    count = 0;
    isCompletingMovement = false;
  }

  getAngle(
      PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
    double result = atan2(lastPoint.y - midPoint.y, lastPoint.x - midPoint.x) -
        atan2(firstPoint.y - midPoint.y, firstPoint.x - midPoint.x);
    result = result * 180 / pi;
    result = result < 0 ? 360 + result : result;
    return result;
  }

  double calculateAngleInBarbellCurls(Pose pose) {
    final PoseLandmark wrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
    final PoseLandmark shoulder =
        pose.landmarks[PoseLandmarkType.leftShoulder]!;

    final PoseLandmark elbow = pose.landmarks[PoseLandmarkType.leftElbow]!;

    final double angle = getAngle(wrist, elbow, shoulder);

    return angle;
  }

  double calculateDistanceBetweenWristAndElbow(Pose pose) {
    PoseLandmark wrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
    PoseLandmark elbow = pose.landmarks[PoseLandmarkType.leftElbow]!;

    double distance = calculateDistance(wrist, elbow);
    return distance;
  }

  double calculateDistance(PoseLandmark point1, PoseLandmark point2) {
    double distance =
        sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2));
    return distance;
  }
}
