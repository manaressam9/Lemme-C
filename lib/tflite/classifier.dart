import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:object_detection/strings/strings.dart';
import 'package:object_detection/tflite/recognition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../shared/constants.dart';
import 'stats.dart';

/// Classifier
class Classifier {
  /// Instance of Interpreter
  Interpreter? _interpreter;

  /// Labels file loaded as list
  List<String>? _labels;

  String MODEL_FILE_NAME = "";
  String LABEL_FILE_NAME = "";

  /// Input size of image (height = width = 300)
  int INPUT_SIZE = 0;

  /// Result score threshold
  static const double THRESHOLD = 0.5;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  /// Padding the image to transform into square
  late int padSize;

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;
  List<int> _outputShapesIndexes = [];

  /// Types of output tensors
  late List<TfLiteType> _outputTypes;

  /// Number of results to show
  static const int NUM_RESULTS = 10;

  Classifier(
    String moduleLabel, {
    Interpreter? interpreter,
    List<String>? labels,
  }) {

    // _outputShapesIndexes.clear();
    if (moduleLabel == OBJ_MOD_LABEL) {
      MODEL_FILE_NAME = 'models/objectDetect_lite4.tflite';
      LABEL_FILE_NAME = ENG_LANG?"labels/labelmap.txt":"labels/labelmap_ar.txt";
      INPUT_SIZE = 640;
      // TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
      // TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
      // TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
      // TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);
      _outputShapesIndexes.add(0);
      _outputShapesIndexes.add(1);
      _outputShapesIndexes.add(2);
      _outputShapesIndexes.add(3);
    } else {
      MODEL_FILE_NAME = "models/currencyLite3_v2.300.tflite";
      LABEL_FILE_NAME = "labels/currencyLabels.txt";
      INPUT_SIZE = 512;
      _outputShapesIndexes.add(1);
      _outputShapesIndexes.add(3);
      _outputShapesIndexes.add(0);
      _outputShapesIndexes.add(2);
    }
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    if (imageProcessor == null) {
      imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    }
    inputImage = imageProcessor!.process(inputImage);
    return inputImage;
  }

  /// Runs object detection on the input image
  Map<String, dynamic>? predict(imageLib.Image? image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image!);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // // TensorBuffers for output tensors
    // TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    // TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    // TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    // TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);
    //
    // // Inputs object for runForMultipleInputs
    // // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    // List<Object> inputs = [inputImage.buffer];
    //
    // // Outputs map
    // Map<int, Object> outputs = {
    //   0: outputLocations.buffer,
    //   1: outputClasses.buffer,
    //   2: outputScores.buffer,
    //   3: numLocations.buffer,
    // };

    /////////////////////////////////////////////////////////
    //Currency
    // TensorBuffers for output tensors
    TensorBuffer outputLocations =
        TensorBufferFloat(_outputShapes[_outputShapesIndexes[0]]);
    TensorBuffer outputClasses =
        TensorBufferFloat(_outputShapes[_outputShapesIndexes[1]]);
    TensorBuffer outputScores =
        TensorBufferFloat(_outputShapes[_outputShapesIndexes[2]]);
    TensorBuffer numLocations =
        TensorBufferFloat(_outputShapes[_outputShapesIndexes[3]]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      _outputShapesIndexes[0]: outputLocations.buffer,
      _outputShapesIndexes[1]: outputClasses.buffer,
      _outputShapesIndexes[2]: outputScores.buffer,
      _outputShapesIndexes[3]: numLocations.buffer,
    };

    ////////////////////////////////////////////////////////

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter!.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);

      // Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels!.elementAt(labelIndex);

      if (score > THRESHOLD) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor!
            .inverseTransformRect(locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)
    };
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String>? get labels => _labels;
}
