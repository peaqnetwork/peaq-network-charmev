import 'dart:collection';
import 'package:charmev/common/models/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CEVLoadingView extends StatefulWidget {
  static const loadingContentKey = ValueKey('loading');
  static const errorContentKey = ValueKey('error');
  static const successContentKey = ValueKey('success');

  static const successContentAnimationDuration = Duration(milliseconds: 400);

  const CEVLoadingView(
      {required this.status,
      this.loadingContent,
      required this.errorContent,
      required this.successContent,
      Key? key})
      : super(key: key);

  final LoadingStatus status;
  final Widget? loadingContent;
  final Widget errorContent;
  final Widget successContent;

  @override
  CEVLoadingViewState createState() => CEVLoadingViewState();
}

class CEVLoadingViewState extends State<CEVLoadingView>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _errorController;
  late AnimationController _successController;

  bool get loadingContentVisible => _loadingController.value == 1.0;
  bool get errorContentVisible => _errorController.value == 1.0;
  bool get successContentVisible => _successController.value == 1.0;

  late Widget firstChild;
  late Widget secondChild;

  Queue<ValueGetter<TickerFuture>> _animationStack = Queue();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _errorController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _successController = AnimationController(
      duration: CEVLoadingView.successContentAnimationDuration,
      vsync: this,
    );

    switch (widget.status) {
      case LoadingStatus.idle:
      case LoadingStatus.loading:
        _animationStack.add(_loadingController.forward);
        break;
      case LoadingStatus.error:
        _animationStack.add(_errorController.forward);
        break;
      case LoadingStatus.success:
        _animationStack.add(_successController.forward);
        break;
    }

    _playAnimations();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _errorController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CEVLoadingView prevWidget) {
    super.didUpdateWidget(prevWidget);

    if (prevWidget.status != widget.status) {
      ValueGetter<TickerFuture> reverseAnimation = _loadingController.reverse;

      switch (prevWidget.status) {
        case LoadingStatus.idle:
        case LoadingStatus.loading:
          reverseAnimation = _loadingController.reverse;
          break;
        case LoadingStatus.error:
          reverseAnimation = _errorController.reverse;
          break;
        case LoadingStatus.success:
          reverseAnimation = _successController.reverse;
          break;
      }

      _animationStack.add(reverseAnimation);

      switch (widget.status) {
        case LoadingStatus.idle:
        case LoadingStatus.loading:
          _animationStack.add(_loadingController.forward);
          break;
        case LoadingStatus.error:
          _animationStack.add(_errorController.forward);
          break;
        case LoadingStatus.success:
          _animationStack.add(_successController.forward);
          break;
      }

      _playAnimations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _TransitionAnimation(
          key: CEVLoadingView.loadingContentKey,
          controller: _loadingController,
          child: widget.loadingContent!,
          isVisible: widget.status == LoadingStatus.loading,
        ),
        _TransitionAnimation(
          key: CEVLoadingView.errorContentKey,
          controller: _errorController,
          child: widget.errorContent,
          isVisible: widget.status == LoadingStatus.error,
        ),
        _TransitionAnimation(
            key: CEVLoadingView.successContentKey,
            controller: _successController,
            child: widget.successContent,
            isVisible: widget.status == LoadingStatus.success),
      ],
    );
  }

  void _playAnimations() async {
    await _animationStack.first();
    _animationStack.removeFirst();

    if (_animationStack.isNotEmpty) {
      _playAnimations();
    }
  }
}

class _TransitionAnimation extends StatelessWidget {
  _TransitionAnimation({
    required this.key,
    required this.controller,
    required this.child,
    required this.isVisible,
  })  : _opacity = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.000,
              0.650,
              curve: Curves.ease,
            ),
          ),
        ),
        _yTranslation = Tween(begin: 40.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(
              0.000,
              0.650,
              curve: Curves.ease,
            ),
          ),
        );

  final Key key;
  final AnimationController controller;
  final Widget child;
  final bool isVisible;

  final Animation<double> _opacity;
  final Animation<double> _yTranslation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return _opacity.value == 0.0
            ? const SizedBox.shrink()
            : IgnorePointer(
                key: key,
                ignoring: !isVisible,
                child: Transform(
                  transform: Matrix4.translationValues(
                    0.0,
                    _yTranslation.value,
                    0.0,
                  ),
                  child: Opacity(
                    opacity: _opacity.value,
                    child: child,
                  ),
                ),
              );
      },
    );
  }
}
