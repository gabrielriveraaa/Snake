import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/game_notifier.dart';
import '../game/game_state.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Offset? _dragStart;
  int? _lastRows;
  int? _lastCols;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    ref.read(gameProvider.notifier).disposeGame();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.localPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    _dragStart = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final start = _dragStart;
    if (start == null) return;

    final delta = details.localPosition - start;
    final dx = delta.dx;
    final dy = delta.dy;

    if (dx.abs() < 18 && dy.abs() < 18) return;

    final notifier = ref.read(gameProvider.notifier);

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        notifier.setDirection(Direction.right);
      } else {
        notifier.setDirection(Direction.left);
      }
    } else {
      if (dy > 0) {
        notifier.setDirection(Direction.down);
      } else {
        notifier.setDirection(Direction.up);
      }
    }

    _dragStart = details.localPosition;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            const targetCell = 22.0;
            final cols = max(10, (w / targetCell).floor());
            final rows = max(10, (h / targetCell).floor());

            if (_lastRows != rows || _lastCols != cols) {
              _lastRows = rows;
              _lastCols = cols;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.configureBoard(rows: rows, cols: cols);
              });
            }

            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BoardPainter(game),
                    ),
                  ),
                  if (game.status == GameStatus.gameOver)
                    _GameOverOverlay(
                      score: game.score,
                      highScore: game.highScore,
                      soundEnabled: game.soundEnabled,
                      onRestart: notifier.reset,
                      onToggleSound: notifier.toggleSound,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool soundEnabled;
  final VoidCallback onRestart;
  final VoidCallback onToggleSound;

  const _GameOverOverlay({
    required this.score,
    required this.highScore,
    required this.soundEnabled,
    required this.onRestart,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Game Over',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text('Puntaje: $score', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('Mejor: $highScore',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onRestart,
                      child: const Text('Reiniciar'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: onToggleSound,
                      child: Text(soundEnabled
                          ? 'Sonido: Activado'
                          : 'Sonido: Desactivado'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final GameState game;

  _BoardPainter(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0F1115);
    canvas.drawRect(Offset.zero & size, bg);

    final cellW = size.width / game.cols;
    final cellH = size.height / game.rows;

    final gridPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int c = 0; c <= game.cols; c++) {
      final x = c * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int r = 0; r <= game.rows; r++) {
      final y = r * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final foodPaint = Paint()..color = const Color(0xFFE74C3C);
    final foodRect =
        Rect.fromLTWH(game.food.x * cellW, game.food.y * cellH, cellW, cellH)
            .deflate(2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(foodRect, const Radius.circular(6)), foodPaint);

    final headPaint = Paint()..color = const Color(0xFFE8F1FF);
    final bodyPaint = Paint()..color = const Color(0xFFB8D3FF);

    for (int i = 0; i < game.snake.length; i++) {
      final p = game.snake[i];
      final rect =
          Rect.fromLTWH(p.x * cellW, p.y * cellH, cellW, cellH).deflate(2);
      final paint = i == 0 ? headPaint : bodyPaint;
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.game != game;
  }
}
