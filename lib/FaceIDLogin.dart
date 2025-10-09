// ignore_for_file: file_names
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/class/Globals.dart';
import 'package:flutter_project/services/camera.service.dart';
import 'package:flutter_project/services/ml_service.dart';
import 'package:flutter_project/services/face_detector_service.dart';
import 'package:flutter_project/locator.dart';
import 'package:flutter_project/widgets/auth_button.dart';
import 'package:flutter_project/widgets/signin_form.dart';
import 'package:flutter_project/widgets/single_picture.dart';
import 'package:flutter_project/widgets/camera_header.dart';
import 'package:flutter_project/widgets/camera_detection_preview.dart';

class FaceIDLogin extends StatefulWidget {
  const FaceIDLogin({Key? key}) : super(key: key);

  @override
  State<FaceIDLogin> createState() => _FaceIDLogin();
}

class _FaceIDLogin extends State<FaceIDLogin> {
  CameraService _cameraService = locator<CameraService>();
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    await _mlService.initialize();

    setState(() => _isInitializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    bool processing = false;
    _cameraService.cameraController!.startImageStream((CameraImage image) async {
      if (processing) return; // prevents unnecessary overprocessing.
      processing = true;
      await _predictFacesFromImage(image: image);
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({@required CameraImage? image}) async {
    assert(image != null, 'Image is null');
    await _faceDetectorService.detectFacesFromImage(image!);
    if (_faceDetectorService.faceDetected) {
      _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
    }
    if (mounted) setState(() {});
  }

  Future<void> takePicture() async {
    if (_faceDetectorService.faceDetected) {
      debugPrint('找到');
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      debugPrint('謀');
      showDialog(context: context, builder: (context) => AlertDialog(content: Text('No face detected!')));
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  Future<void> onTap() async {
    debugPrint('拍照');
    await takePicture();
    if (_faceDetectorService.faceDetected) {
      User? user = await _mlService.predict();
      var bottomSheetController = scaffoldKey.currentState!.showBottomSheet((context) => signInSheet(user: user!));
      bottomSheetController.closed.whenComplete(_reload);
    }
  }

  Widget getBodyWidget() {
    if (_isInitializing) return Center(child: CircularProgressIndicator());
    if (_isPictureTaken) return SinglePicture(imagePath: _cameraService.imagePath!);
    return CameraDetectionPreview();
  }

  @override
  Widget build(BuildContext context) {
    Widget header = CameraHeader("登入", onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) fab = AuthButton(onTap: onTap);

    return Scaffold(
      key: scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   toolbarHeight: 100,
      //   leading: IconButton(
      //     iconSize: 33.0,
      //     icon: const Icon(
      //       Icons.arrow_back,
      //       color: Color.fromARGB(255, 55, 81, 136),
      //     ),
      //     // ignore: avoid_print
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [body, header],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: fab,
    );
  }

  signInSheet({@required User? user}) => user == null
      ? Container(
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.all(20),
    child: Text(
      'User not found 😞',
      style: TextStyle(fontSize: 20),
    ),
  )
      : SignInSheet(user: user);
}
