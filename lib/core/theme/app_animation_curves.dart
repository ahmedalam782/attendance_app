import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppAnimationCurves {
  static Curve get defaultCurve =>
      defaultTargetPlatform == TargetPlatform.iOS ? iosCurve : androidCurve;

  static const Curve androidCurve = Curves.easeInOut;
  static const Curve iosCurve = Curves.easeInOutBack;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeInOutBack = Curves.easeInOutBack;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeInOutQuad = Curves.easeInOutQuad;
  static const Curve easeInOutSine = Curves.easeInOutSine;
  static const Curve easeOutBack = Curves.easeOutBack;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceInOut = Curves.bounceInOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
}
