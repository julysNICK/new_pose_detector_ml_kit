import 'dart:math';

class SlopeTrack {
  final List<double> angleHistorySlope = [];

  String result = "";
  double slopeLineShoulderAndHipWithAngle(
      double xShoulder, double yShoulder, double xHip, double yHip) {
    double angle = atan2(yHip - yShoulder, xHip - xShoulder);

    return angle;
  }

  verifySlopeAngle(double angle) {
    angleHistorySlope.add(angle);

    if (angleHistorySlope.length == 5) {
      double media =
          angleHistorySlope.reduce((a, b) => a + b) / angleHistorySlope.length;

      if (media >= 1.5 && media <= 1.7) {
        result = "coluna reta";
      } else if (media < 1.5) {
        result = "coluna arqueada para frente";
      } else if (media > 1.7) {
        result = "coluna arqueada para trás";
      }

      angleHistorySlope.clear();
    }

    return result;
  }
}
