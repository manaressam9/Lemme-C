import 'dart:typed_data';
import 'dart:math';
import 'package:custom_object_detection/tflite/recognition.dart';
import 'package:custom_object_detection/tflite/stats.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imageLib;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';

class Classifier {
  /// Instance of Interpreter
  late Interpreter _interpreter;

  /// Labels file loaded as list
  late List<String> _labels;

   late  String MODEL_FILE_NAME  ;
    late  String LABEL_FILE_NAME  ;

  /// Input size of image (height = width = 448)
    late int INPUT_SIZE ;

  /// Result score threshold
  static const double THRESHOLD = 0.5;

  /// [ImageProcessor] used to pre-process the image
  late ImageProcessor imageProcessor;

  /// Padding the image to transform into square
  late int padSize;

  // var _inputShapes;
  // var _inputTypes ;

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Types of output tensors
  late List<TfLiteType> _outputTypes;

  /// Number of results to show
  static const int NUM_RESULTS = 10;


  Classifier({required this.MODEL_FILE_NAME,required this.LABEL_FILE_NAME,required this.INPUT_SIZE }) {
    loadModel();
    loadLabels();
  }
  /// Loads interpreter from asset
  Future loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );
      // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
      // print(_interpreter.getInputTensor(0).shape);
      // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

      // var inputTensors = _interpreter.getInputTensors();
      // _inputShapes = inputTensors.shape;
      // _inputTypes = inputTensors.type;

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        // var x = tensor.shape;
        // x.removeAt(0);
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  Future loadLabels() async {
    try {
      _labels =
            await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    //    imageProcessor ??= ImageProcessorBuilder()
    imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .build();

    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  String getStringFromBytes(ByteData data) {
    final buffer = data.buffer;
    var list = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return utf8.decode(list);
  }

  MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
    var pq = PriorityQueue<MapEntry<String, double>>(compare);
    pq.addAll(labeledProb.entries);

    return pq.first;
  }

  int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
    if (e1.value > e2.value) {
      return -1;
    } else if (e1.value == e2.value) {
      return 0;
    } else {
      return 1;
    }
  }

  /// Runs object detection on the input image
  Map<String, dynamic> predict({required imageLib.Image image,required List <int> outputTensorIndexes
    ,required List <int> ouputValueIndex,required int ouputBoundAxis}) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    // if (_interpreter == null) {
    //   print("Interpreter not initialized");
    //   return null;
    // }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);
    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    // print(inputImage.height);
    // print(inputImage.width);
    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    //NEW
    // TensorBuffer inputImg = TensorBufferUint8(_inputShapes);
    // TensorBuffers for output tensors
    print("Shape");
    _outputShapes.forEach((element) {
      print(element);
    });

    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[outputTensorIndexes[0]]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[outputTensorIndexes[1]]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[outputTensorIndexes[2]]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[outputTensorIndexes[3]]);

    /*/flutter ( 9042): Shape
I/flutter ( 9042): [1, 25]
I/flutter ( 9042): [1, 25, 4]
I/flutter ( 9042): [1]
I/flutter ( 9042): [1, 25]*/

    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    // print(_outputShapes[0]);
    // print(_outputShapes[1]);
    // print(_outputShapes[2]);
    // print(_outputShapes[3]);
    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference

    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    // changed Object to ByteBuffer
    Map<int, Object> outputs = {
      outputTensorIndexes[0]: outputLocations.buffer,
      outputTensorIndexes[1]: outputClasses.buffer,
      outputTensorIndexes[2]: outputScores.buffer,
      outputTensorIndexes[3]: numLocations.buffer,
    };

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter.runForMultipleInputs(inputs, outputs);
    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    // print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    // _interpreter.close();

    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>

    ///////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////// problem is here
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,

      valueIndex: ouputValueIndex,
      boundingBoxAxis: ouputBoundAxis,
      //2
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
      var label = _labels.elementAt(labelIndex);

      if (score > THRESHOLD) {
        /*The bounding boxes in output correspond to the pre-processed input image of size 300 X 300.
        We can obtain the boxes corresponding to the raw input image by applying inverse transform.*/

        // inverse of rect
        // [locations] corresponds to the pre-processed input image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);

        recognitions.add(Recognition(i, label, score, transformedRect));
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
    recognitions.forEach((element) {
      print(element);
    });

    print('\n' + predictElapsedTime.toString());
    print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');

    return {
      "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)
    };
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}
