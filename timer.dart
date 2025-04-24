import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimerService extends ChangeNotifier {
  final Stopwatch _watch = Stopwatch();
  Timer? _timer;
  Duration? _currentDuration;
  Duration get currentDuration => _currentDuration ?? Duration.zero;

  bool get isRunning => _watch.isRunning;
  void start() {
    _watch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = _watch.elapsed;
      notifyListeners();
    });
  }

// This function Reset Our StopWatch
  void reset() {
    // Here we are checking our Stopwatch is in running mode
    // if false then stop
    if (!isRunning) _watch.stop();
    // here we are resetting our Stopwatch
    _watch.reset();
    // here we are canceling  our Timer to Prevent Memory Leaks
    _timer?.cancel();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  void stop() {
    _watch.stop();
    _currentDuration = _watch.elapsed;
    notifyListeners();
  }

  @override
  notifyListeners();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimerService>(
      create: (_) => TimerService(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // This Sized box is for Top Notch
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top,
              ),
              const SizedBox(
                height: 20,
              ),
              const Row(
                children: [
                  Text(
                    "Timer",
                    style: TextStyle(
                        fontSize: 43,
                        color: Color.fromRGBO(49, 68, 105, 1),
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  // Menu
                  NeumorphicHumburgerBtn(),
                ],
              ),
              const Spacer(),
              const NeoDigitalScreen(),
              const Spacer(),
              const CenterProgressPie(),
              const Spacer(),
              const Spacer(),
              NeumorphicResetBtn(
                color: Theme.of(context).primaryColor,
                child: const Center(
                  child: Text(
                    "RESET",
                    style: TextStyle(
                        fontSize: 22,
                        color: Color.fromRGBO(49, 68, 105, 1),
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CenterProgressPie extends StatelessWidget {
  const CenterProgressPie({super.key});

  @override
  Widget build(BuildContext context) {
    // getting the value from TimerService Provider and Converting into percentage for pie
    final percentage =
        Provider.of<TimerService>(context).currentDuration.inSeconds %
            60 *
            100 /
            60;

    return Container(
      height: 300,
      width: 400,
      decoration: BoxDecoration(
        border: Border.all(
            width: 10, color: Theme.of(context).scaffoldBackgroundColor),
        shape: BoxShape.circle,
        color: Colors.white70,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 25,
            offset: Offset(-10, -10),
            color: Colors.white,
          ),
          BoxShadow(
              blurRadius: 15,
              offset: Offset(20, 20),
              color: Color.fromRGBO(214, 223, 230, 1))
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: 240,
              child: CustomPaint(
                painter: NeuProgressPainter(
                  circleWidth: 55,
                  completedPercentage: percentage,
                  defaultCircleColor: Colors.transparent,
                ),
                child: const Center(),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 190,
              width: 190,
              foregroundDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //color: Colors.white
                  backgroundBlendMode: BlendMode.overlay,
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    Colors.black,
                    Colors.white.withOpacity(0.9),
                  ])),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 10, color: Colors.white70)),
            ),
          ),
          const Center(child: NeumorphicPlayBtn()),
        ],
      ),
    );
  }
}

class NeumorphicPlayBtn extends StatefulWidget {
  const NeumorphicPlayBtn({super.key});

  @override
  _NeumorphicPlayBtnState createState() => _NeumorphicPlayBtnState();
}

class _NeumorphicPlayBtnState extends State<NeumorphicPlayBtn> {
  bool _isPressed = false;
  bool isRunning = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        isRunning
            ? Provider.of<TimerService>(context, listen: false).stop()
            : Provider.of<TimerService>(context, listen: false).start();
        setState(() {
          isRunning = !isRunning;
        });
        _onPointerDown(e);
      },
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [
                    Colors.white,
                    const Color.fromRGBO(214, 223, 230, 1),
                  ]
                : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                  ],
          ),

          /// For NeoMorphic Effect
          boxShadow: _isPressed
              ? null
              : const [
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(-10, -10),
                    color: Colors.white,
                  ),
                  BoxShadow(
                      blurRadius: 15,
                      offset: Offset(10, 10),
                      color: Color.fromRGBO(214, 223, 230, 1))
                ],
        ),
        child: Icon(
          isRunning ? Icons.pause : Icons.play_arrow,
          size: 60,
          color: isRunning ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}

class DigitalColon extends StatelessWidget {
  final double height;
  final Color color;

  const DigitalColon({Key? key, required this.height, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(height / 2.0, height),
      painter: _DigitalColonPainter(height, color),
    );
  }
}

class _DigitalColonPainter extends CustomPainter {
  final double height;
  final Color color;

  _DigitalColonPainter(this.height, this.color);

  @override
  bool shouldRepaint(_DigitalColonPainter oldDelegate) {
    return height != oldDelegate.height || color != oldDelegate.color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = height / 2;
    final double thickness = width / 5;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Top dot
    canvas.drawRect(
        Rect.fromLTWH(
          width / 2 - thickness / 2,
          height / 3 - thickness / 2,
          thickness,
          thickness,
        ),
        paint);
    // Bottom dot
    canvas.drawRect(
        Rect.fromLTWH(
          width / 2 - thickness / 2,
          height * 2 / 3 - thickness / 2,
          thickness,
          thickness,
        ),
        paint);
  }
}

class DigitalNumber extends StatelessWidget {
  final int value;
  final int padLeft;
  final double height;
  final Color color;

  const DigitalNumber({
    Key? key,
    required this.value,
    required this.height,
    required this.color,
    this.padLeft = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget digitPainter(int digit) {
      return CustomPaint(
        size: Size(height / 2.0, height),
        painter: _DigitalDigitPainter(digit, height, color),
      );
    }

    final Widget digitPadding = SizedBox(width: height / 10.0);

    List<Widget> children = [];

    int digits = 0;
    int remaining = value;
    // do-while required for when [value] is 0
    do {
      int digit = remaining.remainder(10);
      // If this is not our first entry, add padding
      if (remaining != value) {
        children.add(digitPadding);
      }
      children.add(digitPainter(digit));
      remaining ~/= 10;
      digits++;
    } while (remaining > 0);

    // If need to pad this number with zeros
    while (digits < padLeft) {
      children.add(digitPadding);
      children.add(digitPainter(0));
      digits++;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.from(children.reversed),
    );
  }
}

class _DigitalDigitPainter extends CustomPainter {
  final int value;
  final double height;
  final Color color;

  _DigitalDigitPainter(this.value, this.height, this.color)
      : assert(value >= 0),
        assert(value < 10);

  @override
  bool shouldRepaint(_DigitalDigitPainter oldDelegate) {
    return value != oldDelegate.value ||
        height != oldDelegate.height ||
        color != oldDelegate.color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = height / 2; // Digits are half as wide as they are tall
    final double thickness = width / 5; // Arbitrary thickness that looks good

    final double bigGap = thickness * 2 / 3; // Inside angle for outer pixels
    final double midGap = thickness / 2; // Angle for middle bar
    final double smallGap = thickness / 3; // Outside angle for outer pixels

    final double smallPad = thickness / 10; // Spacing for middle bar
    final double bigPad = smallGap + smallPad; // Spacing for outer pixels

    // Alias/pre-calculate convenient locations
    final double top = size.height - height;
    final double left = size.width - width;
    final double right = size.width;
    final double bottom = size.height;
    final double middle = size.height - width;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    /// Build a polygon for the left side of the digit
    List<Offset> leftPolygon(top, bottom) {
      return [
        Offset(left + smallGap, top),
        Offset(left, top + smallGap),
        Offset(left, bottom - smallGap),
        Offset(left + smallGap, bottom),
        Offset(left + thickness, bottom - bigGap),
        Offset(left + thickness, top + bigGap),
      ];
    }

    /// Build a polygon for the right side of the digit
    List<Offset> rightPolygon(top, bottom) {
      return [
        Offset(right - smallGap, top),
        Offset(right - thickness, top + bigGap),
        Offset(right - thickness, bottom - bigGap),
        Offset(right - smallGap, bottom),
        Offset(right, bottom - smallGap),
        Offset(right, top + smallGap),
        Offset(right - smallGap, top),
      ];
    }

    Path p = Path();
    // Top
    if (value != 1 && value != 4) {
      final tleft = left + bigPad;
      final tright = right - bigPad;
      p.addPolygon([
        Offset(tleft, top + smallGap),
        Offset(tleft + smallGap, top),
        Offset(tright - smallGap, top),
        Offset(tright, top + smallGap),
        Offset(tright - bigGap, top + thickness),
        Offset(tleft + bigGap, top + thickness),
      ], true);
    }
    // Left Top
    if (value == 0 || (value > 3 && value != 7)) {
      p.addPolygon(leftPolygon(top + bigPad, middle - smallPad), true);
    }
    // Right Top
    if (value != 5 && value != 6) {
      p.addPolygon(rightPolygon(top + bigPad, middle - smallPad), true);
    }
    // Middle
    if (value > 1 && value != 7) {
      final mleft = left + bigPad;
      final mright = right - bigPad;
      final halfThick = thickness / 2;
      p.addPolygon([
        Offset(mleft, middle),
        Offset(mleft + midGap, middle - halfThick),
        Offset(mright - midGap, middle - halfThick),
        Offset(mright, middle),
        Offset(mright - midGap, middle + halfThick),
        Offset(mleft + midGap, middle + halfThick),
        Offset(mleft, middle),
      ], false);
    }
    // Left Bottom
    if (value == 0 || value == 2 || value == 6 || value == 8) {
      p.addPolygon(leftPolygon(middle + smallPad, bottom - bigPad), true);
    }
    // Right bottom
    if (value != 2) {
      p.addPolygon(rightPolygon(middle + smallPad, bottom - bigPad), true);
    }
    // Bottom
    if (value != 1 && value != 4 && value != 7) {
      final bleft = left + bigPad;
      final bright = right - bigPad;
      p.addPolygon([
        Offset(bleft, bottom - smallGap),
        Offset(bleft + bigGap, bottom - thickness),
        Offset(bright - bigGap, bottom - thickness),
        Offset(bright, bottom - smallGap),
        Offset(bright - smallGap, bottom),
        Offset(bleft + smallGap, bottom),
        Offset(bleft, bottom - smallGap),
      ], false);
    }

    canvas.drawPath(p, paint);
  }
}

class NeoDigitalScreen extends StatelessWidget {
  const NeoDigitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(217, 230, 243, 1),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Colors.white, offset: Offset(-15, -15), blurRadius: 15),
            BoxShadow(
                color: Color.fromRGBO(214, 223, 230, 1),
                offset: Offset(20, 20),
                blurRadius: 15)
          ]),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
                height: constraints.maxHeight * 0.9,
                width: constraints.maxWidth * 0.95,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color.fromRGBO(160, 168, 168, 1),
                        width: 2),
                    gradient: const LinearGradient(colors: [
                      Color.fromRGBO(203, 211, 196, 1),
                      Color.fromRGBO(176, 188, 165, 1)
                    ])),
                child: Center(
                  child: DigitalClock(
                    maxHeight: constraints.maxHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                ));
          },
        ),
      ),
    );
  }
}

class DigitalClock extends StatelessWidget {
  final double maxHeight;
  final double maxWidth;

  const DigitalClock({
    super.key,
    required this.maxHeight,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Provider.of<TimerService>(context).currentDuration;

    final hours = createNumberTime(duration.inHours);
    final minutes = createNumberTime(duration.inMinutes);
    final seconds = createNumberTime(duration.inSeconds);

    return Container(
        height: maxHeight * 0.5,
        width: maxWidth * 0.7,
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...hours,
            DigitalColon(
              height: maxHeight * 0.3,
              color: Colors.black87,
            ),
            ...minutes,
            DigitalColon(
              height: maxHeight * 0.3,
              color: Colors.black87,
            ),
            ...seconds
          ],
        ));
  }

  List<ClockNumberWithBG> createNumberTime(int numberTime) {
    final int parsedNumber = numberTime % 60;
    final bool isTwoDigit = parsedNumber.toString().length == 2;
    final int firstDigit =
        isTwoDigit ? int.parse(parsedNumber.toString()[0]) : 0;
    final int secondDigit =
        isTwoDigit ? int.parse(parsedNumber.toString()[1]) : numberTime % 60;

    return [
      ClockNumberWithBG(
        height: maxHeight,
        value: firstDigit,
      ),
      ClockNumberWithBG(
        height: maxHeight,
        value: secondDigit,
      )
    ];
  }
}

class ClockNumberWithBG extends StatelessWidget {
  final double height;

  final int value;

  const ClockNumberWithBG(
      {super.key, required this.height, required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DigitalNumber(
          value: value,
          height: height * 0.4,
          color: Colors.black,
        ),
        DigitalNumber(
          value: 8,
          height: height * 0.4,
          color: Colors.black12,
        ),
      ],
    );
  }
}

class NeumorphicHumburgerBtn extends StatefulWidget {
  const NeumorphicHumburgerBtn({super.key});

  @override
  _NeumorphicHumburgerBtnState createState() => _NeumorphicHumburgerBtnState();
}

class _NeumorphicHumburgerBtnState extends State<NeumorphicHumburgerBtn> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).primaryColor,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [
                    Colors.white,
                    const Color.fromRGBO(214, 223, 230, 1),
                  ]
                : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                  ],
          ),
          boxShadow: _isPressed
              ? null
              : const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(-5, -5),
                    color: Colors.white,
                  ),
                  BoxShadow(
                      blurRadius: 10,
                      offset: Offset(5, 5),
                      color: Color.fromRGBO(214, 223, 230, 1))
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++) ...[
              Container(
                height: 3,
                width: 25,
                margin: EdgeInsets.only(top: i == 0 ? 0 : 4),
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(214, 223, 230, 1)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class NeumorphicResetBtn extends StatefulWidget {
  final Widget child;
  final double bevel;
  final Color color;

  const NeumorphicResetBtn({
    super.key,
    required this.child,
    this.bevel = 10.0,
    required this.color,
  });

  @override
  _NeumorphicResetBtnState createState() => _NeumorphicResetBtnState();
}

class _NeumorphicResetBtnState extends State<NeumorphicResetBtn> {
  bool _isPressed = false;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Here we are using the Listener to listen our taps
    return Listener(
      // down
      onPointerDown: (e) {
        // calling the reset function
        Provider.of<TimerService>(context, listen: false).reset();
        // if the stopwatch is in running State we simply starting the Stopwatch Again
        if (Provider.of<TimerService>(context, listen: false).isRunning)
          Provider.of<TimerService>(context, listen: false).start();
        _onPointerDown(e);
      },
      // UP
      onPointerUp: _onPointerUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColor,

          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isPressed
                ? [
                    Colors.white,
                    const Color.fromRGBO(214, 223, 230, 1),
                  ]
                : [
                    widget.color,
                    widget.color,
                  ],
          ),

          /// For NeoMorphic Effect
          boxShadow: _isPressed
              ? null
              : const [
                  BoxShadow(
                    blurRadius: 15,
                    offset: Offset(-10, -10),
                    color: Colors.white,
                  ),
                  BoxShadow(
                      blurRadius: 10,
                      offset: Offset(15, 15),
                      color: Color.fromRGBO(214, 223, 230, 1))
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

class NeuProgressPainter extends CustomPainter {
  //
  Color defaultCircleColor;
  Color? percentageCompletedCircleColor;
  double completedPercentage;
  double circleWidth;

  NeuProgressPainter(
      {required this.defaultCircleColor,
      this.percentageCompletedCircleColor,
      required this.completedPercentage,
      required this.circleWidth});
// Brush
  getPaint(Color color) {
    return Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = circleWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint defaultCirclePaint = getPaint(defaultCircleColor);

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    Rect boundingSquare = Rect.fromCircle(center: center, radius: radius);

    paint(
      List<Color> colors,
    ) {
      final Gradient gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: colors,
      );

      return Paint()
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = circleWidth
        ..shader = gradient.createShader(boundingSquare);
    }

    canvas.drawCircle(center, radius, defaultCirclePaint);

    double arcAngle = 2 * pi * (completedPercentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      paint(
        [
          const Color.fromRGBO(255, 219, 129, 1),
          const Color.fromRGBO(255, 126, 29, 1),
        ],
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }
}
