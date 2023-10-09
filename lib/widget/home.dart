import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:new_pose_test/class/calculate_angle.dart';
import 'package:new_pose_test/class/class_arm_flexion.dart';
import 'package:new_pose_test/class/class_squat.dart';
import 'package:new_pose_test/class/exercise.dart';
import 'package:new_pose_test/class/handle_camera.dart';
import 'package:new_pose_test/class/image_lib.dart';
import 'package:new_pose_test/class/pose_frame.dart';
import 'package:new_pose_test/class/slope_track.dart';
import 'package:new_pose_test/class/class_barbell.dart';
import 'package:new_pose_test/widget/pose_painter.dart';

late List<CameraDescription> cameras;

class _MyHomePageStateData {
  late dynamic controller;
  late dynamic poseDetection;
  late SlopeTrack slopeTrack;

  _MyHomePageStateData({
    required this.poseDetection,
    required this.controller,
    required this.slopeTrack,
  });

  void dispose() {
    controller.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Pose> poses = <Pose>[];
  bool readyToStart = false;
  double distanceWristAndShoulder = 0.0;
  double angleBarbell = 0.0;
  bool isBusy = false;
  CameraLensDirection cameraLensDirection = CameraLensDirection.front;
  late CameraDescription cameraDescription;
  String suggestion = "";
  String slopePosition = "";
  CameraHandle cameraHandle = CameraHandle();
  int count = 0;
  dynamic _scanResults;
  //in use

  late _MyHomePageStateData _data;
  CameraImage? img;
  bool isRepeting = false;
  GetImage getImage = GetImage();
  CalculateAngle calculateAngle = CalculateAngle();

  final Exercise _babelExercise = BarbellExercise().createExercise();
  final Exercise _squatExercise = SquatExercise().createExercise();
  final Exercise _armFlexionExercise = ArmFlexionExercise().createExercise();

  Future initCamera() async {
    try {
      cameras = await availableCameras();
      cameraDescription = cameras[1];
      cameraLensDirection = CameraLensDirection.front;
      initializeCamera();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initCamera();
    _data = _MyHomePageStateData(
      controller: cameraHandle.controller,
      poseDetection: false,
      slopeTrack: SlopeTrack(),
    );
  }

  PoseFrame poseFrame = PoseFrame();

  Future<void> initializeCamera() async {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    );

    _data.poseDetection = PoseDetector(options: options);

    _data.controller = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _data.controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _data.controller.startImageStream((CameraImage image) async {
        if (!isBusy) {
          isBusy = true;
          img = image;
          doPoseDetectionOnFrame();
        }
      });
    });
  }

  _updatePoseState() async {
    var frameImg =
        getImage.getInputImage(cameraDescription, _data.controller, img);

    poses = await _data.poseDetection.processImage(frameImg);

    for (Pose pose in poses) {
      if (readyToStart == true) {
        double angleC = calculateAngle.calculateAngleInArmFlexion(pose);

        int count = _armFlexionExercise.calculationRepetition(angleC);
        // String suggestion = postSuggestion(angleC);

        String slopePosition = _data.slopeTrack.verifySlopeAngle(
          pose.landmarks[PoseLandmarkType.leftShoulder]!.x,
          pose.landmarks[PoseLandmarkType.leftShoulder]!.y,
          pose.landmarks[PoseLandmarkType.leftHip]!.x,
          pose.landmarks[PoseLandmarkType.leftHip]!.y,
        );

        setState(() {
          // distanceWristAndShoulder = distanceWristAndShoulder;
          this.count = count + this.count;
          suggestion = suggestion;
          this.slopePosition = slopePosition;
          angleBarbell = angleC;
        });
      }
    }

    setState(() {
      _scanResults = poses;
      isBusy = false;
    });
  }

  doPoseDetectionOnFrame() async {
    await _updatePoseState();
  }

  Widget buildResult() {
    if (_scanResults == null || !_data.controller.value.isInitialized) {
      return const Text('');
    }

    final Size imageSize = Size(
      _data.controller.value.previewSize!.height,
      _data.controller.value.previewSize!.width,
    );
    CustomPainter painter =
        PosePainter(imageSize, _scanResults, cameraLensDirection);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buidExercice() {
    return Container(
      child: Column(
        children: [
          Text(
            "Repetition: $count",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          Text(
            "Angle flexion Arm: $angleBarbell",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          Text(
            "Slope Position: $slopePosition",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIfCameraInit() {
    return Container(
      child: (_data.controller.value.isInitialized)
          ? Container(
              child: CameraPreview(_data.controller),
            )
          : _data.controller.value == null
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Initializing Camera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Container(),
    );
  }

  final BoxDecoration _decorationText = BoxDecoration(
    color: Colors.blue.withOpacity(0.5),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    boxShadow: const [
      BoxShadow(
        color: Colors.black,
        spreadRadius: 1,
        blurRadius: 1,
        offset: Offset(0, 1), // changes position of shadow
      ),
    ],
  );

  final TextStyle _stylesText = const TextStyle(
    color: Colors.white,
    fontSize: 20.0,
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    final size = MediaQuery.of(context).size;
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: _buildIfCameraInit(),
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

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: _buidExercice(),
      ),
    );

    stackChildren.add(
      Positioned(
        bottom: 0.0,
        left: 0.0,
        width: size.width,
        height: 50.0,
        child: InkWell(
          onTap: () {
            //change readyToStart to true after 5 seconds
            print("chamei onTap");

            Future.delayed(const Duration(seconds: 5), () {
              print("chamei Future.delayed");
              setState(() {
                readyToStart = true;
              });
            });
          },
          child: Container(
            width: size.width,
            height: 10.0,
            decoration: _decorationText,
            child: Center(
              child: Text(
                "Começar a treinar",
                style: _stylesText,
              ),
            ),
          ),
        ),
      ),
    );

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
    );
  }
}
