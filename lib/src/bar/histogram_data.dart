import 'dart:math' as math;

import 'package:fcharts/src/bar/bar_graph.dart';
import 'package:fcharts/src/bar/drawable.dart';
import 'package:fcharts/src/chart.dart';
import 'package:fcharts/src/util/color_palette.dart';
import 'package:fcharts/src/painting.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A type of bar graph (arguable names) which is represents continuous data.
/// There are no spaces in between the bars, and each bar group has just a
/// single bar stack and one bar.
class HistogramData implements BarGraphData {
  HistogramData({
    this.bins,
    this.range,
  });

  final List<BinData> bins;
  final Range range;

  factory HistogramData.random(int binCount) {
    final random = new math.Random();
    final range = new Range(0.0, random.nextDouble() * 100);

    final baseColor = ColorPalette.primary.random(random);
    final palette = new ColorPalette.monochrome(baseColor, 3);
    final color = palette.random(random);

    // used for sin(theta)
    var theta = random.nextDouble() * 5;

    final bins = new List.generate(binCount, (i) {
      final value = (math.sin(theta) * range.max * 0.9).abs();

      theta += random.nextDouble() * 0.5;

      return new BinData(
        value: value,
        paint: [
          new PaintOptions(color: color),
          new PaintOptions(color: Colors.grey[800], style: PaintingStyle.stroke),
        ]
      );
    });

    return new HistogramData(
      bins: bins,
      range: range
    );
  }

  BarGraphDrawable createDrawable() {
    final binWidth = 1 / bins.length;

    var i = 0;
    final groupDrawables = bins.map((bin) {
      final scaledValue = bin.value == null ? null : bin.value / range.max;
      final x = binWidth * i;

      final bar = new BarDrawable(
        value: scaledValue,
        paint: bin.paint,
        paintGenerator: bin.paintGenerator,
        base: 0.0,
        stackBase: 0.0,
      );

      final stack = new BarStackDrawable(
        bars: [bar],
        width: binWidth,
        x: x,
      );

      i++;
      return new BarGroupDrawable(
        stacks: [stack]
      );
    });

    return new BarGraphDrawable(
      groups: groupDrawables.toList()
    );
  }

  @override
  List<double> scaledXValues() {
    final binWidth = 1 / bins.length;
    return new List.generate(bins.length, (i) {
      return i * binWidth + binWidth / 2;
    });
  }
}

@immutable
class BinData {
  BinData({
    @required this.value,
    this.paint: const [const PaintOptions(color: Colors.black)],
    this.paintGenerator
  });

  final double value;
  final List<PaintOptions> paint;
  final PaintGenerator paintGenerator;
}