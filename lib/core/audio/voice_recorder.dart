import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records a short voice note and plays it back.
///
/// Works on mobile and web: on web the recorder returns a blob URL which the
/// player streams directly; on mobile it writes an m4a into the temp dir.
///
/// Every plugin call is guarded. A browser without a mic, a refused
/// permission, or an encoder the browser lacks (Chrome has no AAC encoder)
/// returns `false`/`null` instead of throwing, so Mann Darpan never crashes.
class VoiceRecorder {
  VoiceRecorder();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      debugPrint('VoiceRecorder.hasPermission failed: $e');
      return false;
    }
  }

  /// Returns the output path, or `null` when recording could not start.
  Future<String?> start() async {
    if (_isRecording) return null;
    try {
      if (!await _recorder.hasPermission()) return null;
      final AudioEncoder? encoder = await _pickEncoder();
      if (encoder == null) return null;

      final String path = await _outputPath();
      await _recorder.start(RecordConfig(encoder: encoder), path: path);
      _isRecording = true;
      return path;
    } catch (e) {
      debugPrint('VoiceRecorder.start failed: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<String?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    try {
      return await _recorder.stop();
    } catch (e) {
      debugPrint('VoiceRecorder.stop failed: $e');
      return null;
    }
  }

  Future<void> play(String path) async {
    try {
      await _player.stop();
      _isPlaying = true;
      _player.onPlayerComplete.first.then((_) => _isPlaying = false);
      await _player.play(UrlSource(path));
    } catch (e) {
      debugPrint('VoiceRecorder.play failed: $e');
      _isPlaying = false;
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('VoiceRecorder.stopPlayback failed: $e');
    }
    _isPlaying = false;
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      await _player.dispose();
    } catch (e) {
      debugPrint('VoiceRecorder.dispose failed: $e');
    }
  }

  /// AAC on mobile; on web the first format the browser can encode.
  Future<AudioEncoder?> _pickEncoder() async {
    const List<AudioEncoder> preference = kIsWeb
        ? <AudioEncoder>[AudioEncoder.opus, AudioEncoder.wav, AudioEncoder.aacLc]
        : <AudioEncoder>[AudioEncoder.aacLc];
    for (final AudioEncoder encoder in preference) {
      if (await _recorder.isEncoderSupported(encoder)) {
        return encoder;
      }
    }
    return null;
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