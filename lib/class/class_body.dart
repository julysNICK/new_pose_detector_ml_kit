import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class BodyDistances {
  double distanceShoulderAndHip(Pose pose) {
    final PoseLandmark hipX = pose.landmarks[PoseLandmarkType.leftHip]!;

    final PoseLandmark shoulderX =
        pose.landmarks[PoseLandmarkType.leftShoulder]!;

    double distance = hipX.x - shoulderX.x;

    return distance;
  }

  bool checkingIfItHumanBeing(Pose pose) {
    double distance = distanceShoulderAndHip(pose);
    if (distance > 0.2) {
      return true;
    } else {
      return false;
    }
  }
}
