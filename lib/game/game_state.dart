import 'dart:math';

enum GameStatus { playing, paused, gameOver }

enum Direction { up, down, left, right }

class GameState {
  final int rows;
  final int cols;
  final List<Point<int>> snake;
  final Point<int> food;
  final Direction direction;
  final Direction nextDirection;
  final GameStatus status;
  final int score;
  final int highScore;
  final int tickMs;
  final bool soundEnabled;

  const GameState({
    required this.rows,
    required this.cols,
    required this.snake,
    required this.food,
    required this.direction,
    required this.nextDirection,
    required this.status,
    required this.score,
    required this.highScore,
    required this.tickMs,
    required this.soundEnabled,
  });

  GameState copyWith({
    int? rows,
    int? cols,
    List<Point<int>>? snake,
    Point<int>? food,
    Direction? direction,
    Direction? nextDirection,
    GameStatus? status,
    int? score,
    int? highScore,
    int? tickMs,
    bool? soundEnabled,
  }) {
    return GameState(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      nextDirection: nextDirection ?? this.nextDirection,
      status: status ?? this.status,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      tickMs: tickMs ?? this.tickMs,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  static GameState initial({
    int rows = 20,
    int cols = 20,
    int highScore = 0,
    bool soundEnabled = true,
  }) {
    final center = Point<int>(cols ~/ 2, rows ~/ 2);
    final snake = <Point<int>>[
      center,
      Point<int>(center.x - 1, center.y),
      Point<int>(center.x - 2, center.y),
    ];
    final rng = Random();
    final food = _spawnFood(rows, cols, snake, rng);
    return GameState(
      rows: rows,
      cols: cols,
      snake: snake,
      food: food,
      direction: Direction.right,
      nextDirection: Direction.right,
      status: GameStatus.playing,
      score: 0,
      highScore: highScore,
      tickMs: 160,
      soundEnabled: soundEnabled,
    );
  }

  static Point<int> _spawnFood(
    int rows,
    int cols,
    List<Point<int>> snake,
    Random rng,
  ) {
    final occupied = snake.toSet();
    Point<int> p;
    do {
      p = Point<int>(rng.nextInt(cols), rng.nextInt(rows));
    } while (occupied.contains(p));
    return p;
  }
}
