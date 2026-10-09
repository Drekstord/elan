import 'package:flutter/material.dart';

/// Chiffre qui défile comme un compteur jusqu'à sa valeur (effet de lancement).
///
/// - Joué une seule fois par lancement de l'app et par [id] : en revenant sur l'écran,
///   la valeur s'affiche directement.
/// - Si la valeur change ensuite (nouvelle course), elle glisse de l'ancienne à la nouvelle.
/// - Aucune animation si le système demande de réduire les animations (accessibilité).
/// - Les lecteurs d'écran annoncent toujours la valeur finale, jamais les étapes.
class CountUp extends StatefulWidget {
  /// Identifiant stable (« accueil.km ») : l'effet de lancement n'est joué qu'une fois.
  final String id;
  final num value;
  final String Function(num value) format;
  final TextStyle? style;

  const CountUp({super.key, required this.id, required this.value, required this.format, this.style});

  /// Compteurs déjà joués depuis le lancement.
  static final Set<String> _played = {};

  /// Pour les tests : rejoue les effets de lancement.
  @visibleForTesting
  static void resetForTest() => _played.clear();

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late Animation<double> _animation = AlwaysStoppedAnimation(widget.value.toDouble());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!CountUp._played.contains(widget.id) && widget.value != 0) {
      _run(from: 0, duration: const Duration(milliseconds: 1200));
      CountUp._played.add(widget.id);
    }
  }

  @override
  void didUpdateWidget(CountUp old) {
    super.didUpdateWidget(old);
    if (old.value == widget.value) return;
    if (!CountUp._played.contains(widget.id)) {
      // Données arrivées après le premier affichage (chargement, synchro) : effet de lancement.
      CountUp._played.add(widget.id);
      _run(from: 0, duration: const Duration(milliseconds: 1200));
    } else {
      _run(from: _animation.value, duration: const Duration(milliseconds: 600));
    }
  }

  void _run({required double from, required Duration duration}) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _animation = AlwaysStoppedAnimation(widget.value.toDouble());
      return;
    }
    _animation = Tween<double>(
      begin: from,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.format(widget.value),
    excludeSemantics: true,
    child: AnimatedBuilder(
      animation: _animation,
      // Valeur entière pendant le défilement (le format décide des décimales à la fin).
      builder: (context, _) {
        final v = _animation.value;
        final whole = widget.value == widget.value.roundToDouble();
        final shown = _controller.isAnimating ? (whole ? v.round() : v) : widget.value;
        return Text(widget.format(shown), style: widget.style);
      },
    ),
  );
}
