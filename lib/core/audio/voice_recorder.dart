import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records a short voice note and plays it back.
///
/// Works on mobile and web: on web the recorder returns a blob URL which the
/// player streams directly; on mobile it writes an m4a into the temp dir.
class VoiceRecorder {
  VoiceRecorder();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<String?> start() async {
    if (_isRecording) return null;
    if (!await _recorder.hasPermission()) return null;

    final String path = await _outputPath();
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _isRecording = true;
    return path;
  }

  Future<String?> stop() async {
    if (!_isRecording) return null;
    final String? path = await _recorder.stop();
    _isRecording = false;
    return path;
  }

  Future<void> play(String path) async {
    await _player.stop();
    _isPlaying = true;
    _player.onPlayerComplete.first.then((_) => _isPlaying = false);
    await _player.play(UrlSource(path));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }

  Future<String> _outputPath() async {
    if (kIsWeb) {
      // The web recorder ignores the path and returns a blob URL from stop().
      return 'voice_note';
    }
    final dir = await getTemporaryDirectory();
    return '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }
}