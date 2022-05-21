
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class PathDrawer {

  static Future<void> draw (Map geometry,MapboxMapController controller)async
  {
    // Add a polyLine between source and destination
    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometry,
        },
      ]
    };

    // Add new source and lineLayer
    await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addLineLayer(
        "fills",
        "lines",
         LineLayerProperties(
            lineColor: Colors.blue.toHexStringRGB(),
            lineCap: "round",
            lineJoin: "round",
            lineWidth: 4));
  }


}