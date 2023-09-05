import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:new_pose_test/class_barbell.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic controller;
  bool isBusy = false;
  dynamic poseDetection = false;
  late CameraDescription cameraDescription = cameras[1];
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  List<Pose> poses = <Pose>[];
  double distanceWristAndShoulder = 0.0;
  double angleWristAndShoulder = 0.0;
  String suggestion = "";
  int count = 0;
  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    );

    poseDetection = PoseDetector(options: options);

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((CameraImage image) async {
        if (!isBusy) {
          isBusy = true;
          img = image;
          doPoseDetectionOnFrame();
        }
      });
    });
  }

  dynamic _scanResults;
  CameraImage? img;
  bool isRepeting = false;
  AngleTracker angleTracker = AngleTracker();
  doPoseDetectionOnFrame() async {
    var frameImg = getInputImage();

    poses = await poseDetection.processImage(frameImg);

    for (Pose pose in poses) {
      // to access all landmarks
      // pose.landmarks.forEach((_, landmark) {
      //   // final type = landmark.type;
      //   // final x = landmark.x;
      //   // final y = landmark.y;
      // });

      // to access specific landmarks
      // final landmark = pose.landmarks[PoseLandmarkType.nose];
      // final eyeLeft = pose.landmarks[PoseLandmarkType.leftEye];
      // final eyeRight = pose.landmarks[PoseLandmarkType.rightEye];

      // double distanceWristAndShoulder =
      //     calculateDistanceBetweenWristAndShoulder(pose);
      double angleC = calculateAngleInBarbellCurls(pose);

      int count = angleTracker.calculationRepetition3(angleC);
      String suggestion = postSuggestion(angleC);

      setState(() {
        distanceWristAndShoulder = distanceWristAndShoulder;
        this.count = this.count + count;
        this.suggestion = suggestion;
        angleWristAndShoulder = angleC;
      });
    }
    // print("faces present = ${faces.length}");

    // checkSpinePosture();

    setState(() {
      _scanResults = poses;
      isBusy = false;
    });
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? getInputImage() {
    final camera = cameraDescription;

    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? imageRotation;

    var rotationCompensation =
        _orientations[controller!.value.deviceOrientation];

    if (rotationCompensation == null) return null;

    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }

    imageRotation = InputImageRotationValue.fromRawValue(rotationCompensation);

    if (imageRotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(img!.format.raw);

    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (img!.planes.isEmpty) return null;

    final plane = img!.planes.first;

    return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(img!.width.toDouble(), img!.height.toDouble()),
          rotation: imageRotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ));
  }

  InputImage getInputImage2() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = cameraDescription;
    InputImageRotation? imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(img!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImageMetadata(
          rotation: imageRotation!,
          size: imageSize,
          format: inputImageFormat!,
          bytesPerRow: plane.bytesPerRow,
        );
      },
    ).toList();

    final inputImage =
        InputImage.fromBytes(bytes: bytes, metadata: planeData[0]);

    return inputImage;
  }

  double calculateDistanceBetweenWristAndShoulder(Pose pose) {
    final PoseLandmark wrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
    final PoseLandmark shoulder =
        pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final double distance =
        sqrt(pow(wrist.x - shoulder.x, 2) + pow(wrist.y - shoulder.y, 2));
    return distance;
  }

  double calculateAngle24_26_28(Pose pose) {
    final PoseLandmark wrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
    final PoseLandmark shoulder =
        pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final PoseLandmark elbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
    final double distance =
        sqrt(pow(wrist.x - shoulder.x, 2) + pow(wrist.y - shoulder.y, 2));
    return distance;
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

  bool isAboveThreshold = false;
  bool hasCompletedRepetition = false;

  int calculateRepetition(double angle) {
    int count = 0;
    double angleThresholdMin = 45.0;

    double angleThresholdMax = 150.0;

    if (angle <= angleThresholdMin && angle >= angleThresholdMax) {
      if (!isAboveThreshold) {
        isAboveThreshold = true;
      } else if (isAboveThreshold && !hasCompletedRepetition) {
        hasCompletedRepetition = true;
        count++;
      }
    } else {
      isAboveThreshold = false;
      hasCompletedRepetition = false;
    }

    return count;
  }

  int calculateRepetition2(double angle) {
    int count = 0;
    double angleThresholdMin = 45.0;

    double angleThresholdMax = 150.0;

    int repetitionInLastFrame = 0;

    if (angle <= angleThresholdMin && angle >= angleThresholdMax) {
      repetitionInLastFrame++;
    } else {
      repetitionInLastFrame = 0;
    }

    return repetitionInLastFrame;
  }

  int calculateRepetition3(double angle) {
    int count = 0;
    double angleThresholdMin = 45.0;

    double angleThresholdMax = 150.0;

    int repetitionInLastFrame = 0;

    if (angle <= angleThresholdMin && angle >= angleThresholdMax) {
      repetitionInLastFrame++;
    } else {
      if (repetitionInLastFrame > 0) {
        count++;
      }
      repetitionInLastFrame = 0;
    }

    return count;
  }

  int calculateRepetition4(double angle) {
    int count = 0;
    double angleThresholdMin = 45.0;

    double angleThresholdMax = 150.0;

    String movimentState = "desconhecido";

    if (angle <= angleThresholdMin && angle >= angleThresholdMax) {
      if (movimentState == "desconhecido") {
        movimentState = "subindo";
      } else if (movimentState == "subindo") {
        movimentState = "subindo";
      } else if (movimentState == "descendo") {
        movimentState = "subindo";
        count++;
      }
    } else {
      if (movimentState == "desconhecido") {
        movimentState = "descendo";
      } else if (movimentState == "subindo") {
        movimentState = "descendo";
      } else if (movimentState == "descendo") {
        movimentState = "descendo";
      }
    }

    return count;
  }

  String postSuggestion(double angle) {
    String suggestion = "";
    double angleThresholdMin = 50.0;

    double angleThresholdMax = 160.0;

    if (angle < angleThresholdMin) {
      suggestion = "Subindo";
    } else if (angle > angleThresholdMax) {
      suggestion = "Descendo";
    }
    return suggestion;
  }

  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Text('');
    }

    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter =
        PosePainter(imageSize, _scanResults, cameraLensDirection);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    final size = MediaQuery.of(context).size;
    if (controller != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: (controller.value.isInitialized)
                ? Container(
                    child: CameraPreview(controller),
                  )
                : Container(),
          ),
        ),
      );
      stackChildren.add(
        Positioned(
            top: 0.0,
            left: 0.0,
            width: size.width,
            height: size.height,
            child: buildResult()),
      );

      // stackChildren.add(
      //   Positioned(
      //     top: 0.0,
      //     left: 0.0,
      //     width: size.width,
      //     height: size.height,
      //     child: Container(
      //       child: Column(
      //         children: [
      //           Text(
      //             "Distance between wrist and shoulder: $distanceWristAndShoulder",
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 30.0,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
      // stackChildren.add(
      //   Positioned(
      //     top: 0.0,
      //     left: 0.0,
      //     width: size.width,
      //     height: size.height,
      //     child: Container(
      //       child: Column(
      //         children: [
      //           Text(
      //             "Calculate angle wrist and shoulder: $angleWristAndShoulder",
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 15.0,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child: Column(
              children: [
                Text(
                  "Repetitions: $count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  "Suggestion: $suggestion",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  "Calculate angle wrist and shoulder: $angleWristAndShoulder",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Face detector"),
        backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.black,
      body: Container(
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Stack(
            children: stackChildren,
          )),
      //   child: Container(
      //     child: (controller.value.isInitialized)
      //         ? Container(
      //             child: CameraPreview(controller),
      //           )
      //         : Container(),
      //   ),
      // ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter(this.absoluteImageSize, this.poses, this.camDire2);

  final Size absoluteImageSize;
  final List<Pose> poses;
  CameraLensDirection camDire2;
  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        Offset pointCamBack = Offset(landmark.x * scaleX, landmark.y * scaleY);
        Offset pointCamFront =
            Offset(size.width - landmark.x * scaleX, landmark.y * scaleY);

        if (camDire2 == CameraLensDirection.back) {
          canvas.drawCircle(pointCamBack, 1, paint);
        } else {
          canvas.drawCircle(pointCamFront, 1, paint);
        }

        // canvas.drawCircle(
        //     Offset(landmark.x * scaleX, landmark.y * scaleY), 1, paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;

        Offset point1WhenCamBack = Offset(joint1.x * scaleX, joint1.y * scaleY);
        Offset point2WhenCamBack = Offset(joint2.x * scaleX, joint2.y * scaleY);

        Offset point1WhenCamFront =
            Offset(size.width - joint1.x * scaleX, joint1.y * scaleY);
        Offset point2WhenCamFront =
            Offset(size.width - joint2.x * scaleX, joint2.y * scaleY);

        // canvas.drawLine(Offset(joint1.x * scaleX, joint1.y * scaleY),
        //     Offset(joint2.x * scaleX, joint2.y * scaleY), paintType);

        Offset point1 = camDire2 == CameraLensDirection.front
            ? point1WhenCamFront
            : point1WhenCamBack;
        Offset point2 = camDire2 == CameraLensDirection.front
            ? point2WhenCamFront
            : point2WhenCamBack;

        canvas.drawLine(point1, point2, paintType);
      }

      //Draw arms
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(
          PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow,
          rightPaint);
      paintLine(
          PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      //Draw Body
      paintLine(
          PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip,
          rightPaint);

      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      // paintLine(
      //     PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(
          PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      // paintLine(
      //     PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      paintLine(
          PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb, leftPaint);

      paintLine(
          PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky, leftPaint);

      paintLine(
          PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex, leftPaint);

      //Draw legs
      paintLine(
          PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb, rightPaint);

      paintLine(
          PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky, rightPaint);

      paintLine(
          PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex, rightPaint);
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
