import 'package:flutter/material.dart';
import 'dart:math' as math show sin, pi;
import 'package:flutter/animation.dart';
import 'package:music_player/constants.dart';

class Delayer extends Tween<double> {
  Delayer({double begin, double end, this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class TestFile extends StatefulWidget {
  const TestFile({
    Key key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1400),
    this.controller,
  })  : assert(
            !(itemBuilder is IndexedWidgetBuilder && color is Color) &&
                !(itemBuilder == null && color == null),
            'You should specify either a itemBuilder or a color'),
        assert(size != null),
        super(key: key);

  final Color color;
  final double size;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final AnimationController controller;

  @override
  _TestFileState createState() => _TestFileState();
}

class _TestFileState extends State<TestFile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ??
        AnimationController(vsync: this, duration: widget.duration))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.size,
        height: widget.size,
        // color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) {
            return ScaleTransition(
              scale: Delayer(begin: 0.0, end: 1.0, delay: i * .2)
                  .animate(_controller),
              child: Container(
                  // color: Colors.black,
                  height: widget.size,
                  width: widget.size * 0.2,
                  child: _itemBuilder(i)),
            );
          }),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index) {
    return widget.itemBuilder != null
        ? widget.itemBuilder(context, index)
        : DecoratedBox(
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: orange,
          ));
  }
}

class Loader1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TestFile(
      color: Colors.lightGreen,
      size: 15.0,
    );
  }
}

class Loader2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TestFile(
      color: Colors.lightGreen,
      size: 30.0,
    );
  }
}

class Loader3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TestFile(
      color: Colors.lightGreen,
      size: 100.0,
    );
  }
}

class Temp extends StatelessWidget {
  final int size;
  Temp({this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: TestFile(
          color: Colors.lightGreen,
          size: 30.0,
        ));
  }
}
