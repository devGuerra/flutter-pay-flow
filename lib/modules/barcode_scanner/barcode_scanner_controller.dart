import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'package:payflow/modules/barcode_scanner/barcode_scanner_status.dart';

class BarcodeScannerController {
  final statusNotifier =
      ValueNotifier<BarcodeScannerStatus>(BarcodeScannerStatus());

  BarcodeScannerStatus get status => statusNotifier.value;

  set status(BarcodeScannerStatus status) => statusNotifier.value = status;

  final barcodeScanner = GoogleMlKit.vision.barcodeScanner();

  InputImage? imagePicker;

  CameraController? cameraController;

  void getAvailableCameras() async {
    try {
      final response = await availableCameras();

      final camera = response.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.back);

      cameraController =
          CameraController(camera, ResolutionPreset.max, enableAudio: false);

      await cameraController!.initialize();
      scanWithCamera();
      listenCamera();
    } catch (e) {
      status = BarcodeScannerStatus.error(e.toString());
    }
  }

  Future<void> scannerBarcode(InputImage inputImage) async {
    try {
      final barcodes = await barcodeScanner.processImage(inputImage);
      var barcode;

      for (Barcode item in barcodes) {
        barcode = item.displayValue;
      }

      if (barcode != null && status.barcode.isEmpty) {
        status = BarcodeScannerStatus.barcode(barcode);
        cameraController!.dispose();
        await barcodeScanner.close();
      }

      return;
    } catch (e) {
      if (kDebugMode) {
        print("ERRO NA LEITURA $e");
      }
    }
  }

  void scanWithImagePicker() async {
    final response = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (response != null) {
      final inputImage = InputImage.fromFilePath(response.path);
      scannerBarcode(inputImage);
    }
  }

  void scanWithCamera() {
    status = BarcodeScannerStatus.available();
    Future.delayed(const Duration(seconds: 20)).then((value) {
      if (status.hasBarcode == false) {
        status = BarcodeScannerStatus.error("Timeout de leitura do boleto");
      }
    });
  }

  void listenCamera() {
    if (cameraController!.value.isStreamingImages == false) {
      cameraController!.startImageStream(
        (cameraImage) async {
          if (status.stopScanner == false) {
            try {
              final WriteBuffer allBytes = WriteBuffer();

              for (Plane plane in cameraImage.planes) {
                allBytes.putUint8List(plane.bytes);
              }

              final bytes = allBytes.done().buffer.asUint8List();

              final Size imageSize = Size(
                  cameraImage.width.toDouble(), cameraImage.height.toDouble());

              // ignore: prefer_const_declarations
              final InputImageRotation imageRotation =
                  InputImageRotation.rotation90deg;

              // ignore: prefer_const_declarations
              final InputImageFormat inputImageFormat = InputImageFormat.nv21;

              final planeData = cameraImage.planes.map((Plane plane) {
                return InputImagePlaneMetadata(
                    bytesPerRow: plane.bytesPerRow,
                    height: plane.height,
                    width: plane.width);
              }).toList();

              final inputImageData = InputImageData(
                  size: imageSize,
                  imageRotation: imageRotation,
                  inputImageFormat: inputImageFormat,
                  planeData: planeData);

              final inputImageCamera = InputImage.fromBytes(
                  bytes: bytes, inputImageData: inputImageData);

              await scannerBarcode(inputImageCamera);
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
            }
          }
        },
      );
    }
  }

  void dispose() {
    statusNotifier.dispose();
    barcodeScanner.close();
    if (status.showCamera) {
      cameraController!.dispose();
    }
  }
}
