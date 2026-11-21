import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Entrada en cascada: fundido y desplazamiento corto con desfase por índice.
///
/// Solo anima la primera aparición del elemento; los primeros elementos se
/// mantienen vivos para no repetirla al volver con el scroll. Pasado el tope
/// de elementos animados el hijo aparece sin retraso.
class StaggeredEntryWidget extends StatefulWidget {
  const StaggeredEntryWidget({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<StaggeredEntryWidget> createState() => _StaggeredEntryWidgetState();
}

class _StaggeredEntryWidgetState extends State<StaggeredEntryWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Recurso del framework: dura el movimiento y el retardo del índice.
  late final AnimationController _controller;
  late final Animation<double> _progress;
  bool _started = false;

  bool get _animates => widget.index < AnimationConfig.staggerMaxAnimatedItems;

  // Mientras el elemento esté dentro del tope no se destruye al salir de vista.
  @override
  bool get wantKeepAlive => _animates;

  Duration get _delay => Duration(
    milliseconds: widget.index * AnimationConfig.staggerStepMilliseconds,
  );

  @override
  void initState() {
    super.initState();
    final total = AppMotion.medium + _delay;
    _controller = AnimationController(vsync: this, duration: total);
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        _delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: AppMotion.enter,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!_animates || MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        // Las envolturas son fijas: quitarlas remontaría el hijo y su estado.
        return Opacity(
          opacity: _progress.value,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - _progress.value) * AnimationConfig.staggerOffsetPixels,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
