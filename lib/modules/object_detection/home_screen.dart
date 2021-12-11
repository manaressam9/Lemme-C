import 'dart:io';
import 'package:camera/camera.dart';
import 'package:custom_object_detection/tflite/classifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

class ObjDet extends StatefulWidget {
  List<CameraDescription> cameras;

  ObjDet(this.cameras);

  @override
  State<ObjDet> createState() => _ObjDetState(cameras);
}

class _ObjDetState extends State<ObjDet> {
  List<CameraDescription> cameras;

  _ObjDetState(this.cameras);

  File? _image;
  late Classifier _model;
  Map<String, dynamic>? _output;
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => null);
      setState(() {});
    });
    _model = Classifier(
        MODEL_FILE_NAME: 'lite4.tflite',
        LABEL_FILE_NAME: 'labelmap.txt',
        INPUT_SIZE: 640);
  }

  _imageSelection() async {
    var img;
    try {
      img = await ImagePicker().pickImage(source: ImageSource.gallery);
    } catch (e) {
      print("Error while loading Img: $e");
    }
    var image1 = File(img.path);
    //convert from XFile to Image
    final bytes = await image1.readAsBytes();
    final imageLib.Image image = imageLib.decodeImage(bytes)!;
    var output1 = _model.predict(
        image: image,
        outputTensorIndexes: [0, 1, 2, 3],
        ouputValueIndex: [1, 0, 3, 2],
        ouputBoundAxis: 2);
    setState(() {
      _image = image1;
      _output = output1;
      /*
    recognitions.add(Recognition(i, label, score, transformedRect))

    return
    "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)*/
    });
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Scaffold(
            body: Container(height: double.infinity, child: CameraPreview(controller)),
          )
        : Container();
  }
}

// class Model{
//   /// Instance of Interpreter
//   late Interpreter _interpreter;
//
//   /// Labels file loaded as List
//   late List<String> _labels;
//
//   static const String MODEL_FILE_NAME = "model.tflite";
//   static const String LABEL_FILE_NAME = "labels.txt";
//
//   /// Shapes of output tensors
//   late List<List<int>> _outputShapes;
//
//   /// Types of output tensors
//   late List<TfLiteType> _outputTypes;
//
//   /// Input size of image (height = width = 448)
//   static const int INPUT_SIZE = 448;
//
//   /// [ImageProcessor] used to pre-process the image
//   ImageProcessor imageProcessor;
//
//   /// Padding the image to transform into square
//   int padSize;
//
//   static const double THRESHOLD = 0.5;
//
//
//   /// Constructor
//   Model({
//     required Interpreter interpreter,
//     required List<String> labels,
//   }) {
//     loadModel(interpreter: interpreter);
//     loadLabels(labels: labels);
//   }
//
//   /// Loads interpreter from asset
//   void loadModel({required Interpreter interpreter}) async {
//     try {
//       _interpreter = interpreter ??
//           await Interpreter.fromAsset(
//             MODEL_FILE_NAME,
//             options: InterpreterOptions()..threads = 4,
//           );
//
//       var outputTensors = _interpreter.getOutputTensors();
//       _outputShapes = [];
//       _outputTypes = [];
//       outputTensors.forEach((tensor) {
//         _outputShapes.add(tensor.shape);
//         _outputTypes.add(tensor.type);
//       });
//     } catch (e) {
//       print("Error while creating interpreter: $e");
//     }
//   }
//
//   /// Loads labels from assets
//   void loadLabels({required List<String> labels}) async {
//     try {
//       _labels =
//           labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
//     } catch (e) {
//       print("Error while loading labels: $e");
//     }
//   }
//
//   /// Gets the interpreter instance
//   Interpreter get interpreter => _interpreter;
//
//   /// Gets the loaded labels
//   List<String> get labels => _labels;
//
// ////////////////////////////////////////////////////////////////////////////////////////
//
//   /// Pre-process the image
//   TensorImage getProcessedImage(TensorImage inputImage) {
//     padSize = max(inputImage.height, inputImage.width);
//
//     // create ImageProcessor
//     imageProcessor = ImageProcessorBuilder()
//     // Padding the image (squaring to max dim.)
//         .add(ResizeWithCropOrPadOp(padSize, padSize))
//     // Resizing to input size (resize square img to input size of the model got from neutron tool)
//         .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
//         .build();
//
//     inputImage = imageProcessor.process(inputImage);
//     return inputImage;
//   }
//
//   /// Runs object detection on the input image
//   Map<String, dynamic>? predict(imageLib.Image image) {
//     var predictStartTime = DateTime.now().millisecondsSinceEpoch;
//
//     if (_interpreter == null) {
//       print("Interpreter not initialized");
//       return null;
//     }
//
//     var preProcessStart = DateTime.now().millisecondsSinceEpoch;
//
//     // Create TensorImage from image
//     TensorImage inputImage = TensorImage.fromImage(image);
//
//     // Pre-process TensorImage
//     inputImage = getProcessedImage(inputImage);
//
//     var preProcessElapsedTime =
//         DateTime.now().millisecondsSinceEpoch - preProcessStart;
//
//     // TensorBuffers for output tensors
//     TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
//     TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
//     TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
//     TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);
//
//     // Inputs object for runForMultipleInputs
//     // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
//     List<Object> inputs = [inputImage.buffer];
//
//     // Outputs map
//     Map<int, Object> outputs = {
//       0: outputLocations.buffer,
//       1: outputClasses.buffer,
//       2: outputScores.buffer,
//       3: numLocations.buffer,
//     };
//
//     var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
//
//     // run inference
//     _interpreter.runForMultipleInputs(inputs, outputs);
//
//     var inferenceTimeElapsed =
//         DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
//
//     // Maximum number of results to show
//     int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));
//
//     // Using labelOffset = 1 as ??? at index 0
//     int labelOffset = 1;
//
//     // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
//     List<Rect> locations = BoundingBoxUtils.convert(
//       tensor: outputLocations,
//       valueIndex: [1, 0, 3, 2],
//       boundingBoxAxis: 2,
//       boundingBoxType: BoundingBoxType.BOUNDARIES,
//       coordinateType: CoordinateType.RATIO,
//       height: INPUT_SIZE,
//       width: INPUT_SIZE,
//     );
//
//     List<Recognition> recognitions = [];
//
//     for (int i = 0; i < resultsCount; i++) {
//       // Prediction score
//       var score = outputScores.getDoubleValue(i);
//
//       // Label string
//       var labelIndex = outputClasses.getIntValue(i) + labelOffset;
//       var label = _labels.elementAt(labelIndex);
//
//       if (score > THRESHOLD) {
//         // inverse of rect
//         // [locations] corresponds to the image size 300 X 300
//         // inverseTransformRect transforms it our [inputImage]
//         Rect transformedRect = imageProcessor.inverseTransformRect(
//             locations[i], image.height, image.width);
//
//         recognitions.add(
//           Recognition(i, label, score, transformedRect),
//         );
//       }
//     }
//
//     var predictElapsedTime =
//         DateTime.now().millisecondsSinceEpoch - predictStartTime;
//
//     return {
//       "recognitions": recognitions,
//       "stats": Stats(
//           totalPredictTime: predictElapsedTime,
//           inferenceTime: inferenceTimeElapsed,
//           preProcessingTime: preProcessElapsedTime)
//     };
//
//
// }}
