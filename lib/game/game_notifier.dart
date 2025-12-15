import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_state.dart';
import 'preferences.dart';
import 'sound_service.dart';

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);

class GameNotifier extends Notifier<GameState> {
  final _rng = Random();
  Timer? _timer;
  SoundService? _sound;

  @override
  GameState build() {
    _init();
    return GameState.initial(
        rows: 20, cols: 20, highScore: 0, soundEnabled: true);
  }

  Future<void> _init() async {
    final hs = await GamePrefs.getHighScore();
    final se = await GamePrefs.getSoundEnabled();
    _sound ??= SoundService();
    state = GameState.initial(
        rows: state.rows, cols: state.cols, highScore: hs, soundEnabled: se);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer =
        Timer.periodic(Duration(milliseconds: state.tickMs), (_) => tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _restartTimerIfNeeded(int oldTickMs, int newTickMs) {
    if (oldTickMs != newTickMs) {
      _startTimer();
    }
  }

  Future<void> disposeGame() async {
    _stopTimer();
    final s = _sound;
    _sound = null;
    if (s != null) {
      await s.dispose();
    }
  }

  void configureBoard({required int rows, required int cols}) {
    if (rows == state.rows && cols == state.cols) return;
    if (rows < 10 || cols < 10) return;

    final hs = state.highScore;
    final se = state.soundEnabled;
    state = GameState.initial(
        rows: rows, cols: cols, highScore: hs, soundEnabled: se);
    _startTimer();
  }

  void togglePause() {
    if (state.status == GameStatus.gameOver) return;
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    } else {
      state = state.copyWith(status: GameStatus.paused);
      _stopTimer();
    }
  }

  void reset() {
    final hs = state.highScore;
    final se = state.soundEnabled;
    state = GameState.initial(
        rows: state.rows, cols: state.cols, highScore: hs, soundEnabled: se);
    _startTimer();
  }

  void setDirection(Direction d) {
    if (state.status != GameStatus.playing) return;
    final current = state.direction;
    if (_isOpposite(current, d)) return;
    state = state.copyWith(nextDirection: d);
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.left && b == Direction.right) ||
        (a == Direction.right && b == Direction.left) ||
        (a == Direction.up && b == Direction.down) ||
        (a == Direction.down && b == Direction.up);
  }

  void toggleSound() {
    final v = !state.soundEnabled;
    state = state.copyWith(soundEnabled: v);
    GamePrefs.setSoundEnabled(v);
  }

  Future<void> _playEatIfEnabled() async {
    if (!state.soundEnabled) return;
    final s = _sound;
    if (s == null) return;
    await s.playEat();
  }

  Future<void> _playGameOverIfEnabled() async {
    if (!state.soundEnabled) return;
    final s = _sound;
    if (s == null) return;
    await s.playGameOver();
  }

  void tick() {
    if (state.status != GameStatus.playing) return;

    final dir = state.nextDirection;
    final head = state.snake.first;
    final nextHead = _move(head, dir);

    final hitsWall = nextHead.x < 0 ||
        nextHead.x >= state.cols ||
        nextHead.y < 0 ||
        nextHead.y >= state.rows;
    if (hitsWall) {
      _gameOver();
      return;
    }

    final willEat = nextHead == state.food;
    final newSnake = <Point<int>>[nextHead, ...state.snake];

    if (!willEat) {
      newSnake.removeLast();
    }

    final hitsSelf = newSnake.skip(1).contains(nextHead);
    if (hitsSelf) {
      _gameOver();
      return;
    }

    if (willEat) {
      final newScore = state.score + 1;
      final oldTick = state.tickMs;
      final newTick = _computeTickMs(newScore);

      final newFood = _spawnFood(newSnake);
      final newHigh = newScore > state.highScore ? newScore : state.highScore;

      state = state.copyWith(
        snake: newSnake,
        food: newFood,
        direction: dir,
        score: newScore,
        highScore: newHigh,
        tickMs: newTick,
        status: GameStatus.playing,
      );

      GamePrefs.setHighScore(newHigh);
      _playEatIfEnabled();
      _restartTimerIfNeeded(oldTick, newTick);
      return;
    }

    state = state.copyWith(
      snake: newSnake,
      direction: dir,
      status: GameStatus.playing,
    );
  }

  int _computeTickMs(int score) {
    const base = 160;
    const stepEvery = 5;
    const step = 10;
    final dec = (score ~/ stepEvery) * step;
    final v = base - dec;
    return v < 70 ? 70 : v;
  }

  Point<int> _move(Point<int> p, Direction d) {
    switch (d) {
      case Direction.up:
        return Point<int>(p.x, p.y - 1);
      case Direction.down:
        return Point<int>(p.x, p.y + 1);
      case Direction.left:
        return Point<int>(p.x - 1, p.y);
      case Direction.right:
        return Point<int>(p.x + 1, p.y);
    }
  }

  Point<int> _spawnFood(List<Point<int>> snake) {
    final occupied = snake.toSet();
    Point<int> p;
    do {
      p = Point<int>(_rng.nextInt(state.cols), _rng.nextInt(state.rows));
    } while (occupied.contains(p));
    return p;
  }

  void _gameOver() {
    _stopTimer();
    state = state.copyWith(status: GameStatus.gameOver);
    _playGameOverIfEnabled();
  }
}
