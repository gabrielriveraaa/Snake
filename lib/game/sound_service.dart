import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();

  SoundService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playEat() async {
    await _player.stop();
    await _player.play(AssetSource('sfx/eat.wav'));
  }

  Future<void> playGameOver() async {
    await _player.stop();
    await _player.play(AssetSource('sfx/game_over.wav'));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
