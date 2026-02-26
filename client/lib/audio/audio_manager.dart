import 'package:dart_pcm/audio/song_model.dart';
import 'package:flutter/material.dart';

class AudioManager extends ChangeNotifier {
  // 전역 객체 사용
  static final AudioManager _instance = AudioManager._internal();
  // 전역 객체 반환, factory로 항상 동일한 객체 반환
  factory AudioManager() => _instance;
  // 임의의 생성자로 클래스 내부에서 전역 객체 생성
  AudioManager._internal();

  final List<DownloadedSong> _queueSongs = [];
  List<DownloadedSong> get queueSongs => _queueSongs;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // 현재 재생되고 있는 노래
  DownloadedSong? _currentSong = null;

  void addSong(DownloadedSong song) {
    _queueSongs.add(song);
    // ui에 알리기
    notifyListeners();
  }

  void removeSong(int id) {
    _queueSongs.removeWhere((song) => song.id == id);
    notifyListeners();
  }

  void startSong() {
    // 현재 재생되고 있는 노래가 있으면 무시
    if (_currentSong != null) return;
    if (_queueSongs.isEmpty) return;
    _currentSong = _queueSongs.first;
    _isPlaying = true;
    // queue에서는 첫번째 노래 없애기
    _queueSongs.removeAt(0);
    notifyListeners();
    // TODO: ffmpeg기반 노래 재생 로직 추가하기
  }

  void cancelSong() {
    _isPlaying = false;
    _currentSong = null;
    notifyListeners();
    // TODO: ffmpeg기반 노래 취소 로직 추가하기
  }

  // TODO: 한 노래가 끝나면 자동으로 queue의 다음 노래가 재생되는 로직 추가하기
}
