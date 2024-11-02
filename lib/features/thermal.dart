import 'dart:async';
import 'dart:ui';

/// スクラッチのイベントを受け取るコールバック型
/// [localPosition] 現在のタップ位置
/// [currentTime] 現在時刻
/// [deltaHeat] スクラッチの熱量差分
typedef ScratchCallback = void Function(
  Offset localPosition,
  DateTime currentTime,
  double deltaHeat,
);

/// スクラッチを間引いてイベントを発火するクラス
class ThermalThrottler {
  ThermalThrottler({
    this.onScratchBegan,
    this.onScratchMoved,
    this.onScratchEnded,
    this.interval = const Duration(milliseconds: 100),
    this.minHeatDelta = 0.0,
    this.maxHeatDelta = 1.0,
    this.heatDeltaScale = 1.0 / 100.0 / 60,
    this.heatDeltaOffset = -0.1,
  });

  /// スクラッチが始まった際のイベント
  final ScratchCallback? onScratchBegan;

  /// 間引かれたスクラッチイベント
  final ScratchCallback? onScratchMoved;

  /// スクラッチが終了した際のイベント
  final ScratchCallback? onScratchEnded;

  /// イベントを発火する間隔
  final Duration interval;

  final double minHeatDelta;
  final double maxHeatDelta;
  final double heatDeltaScale;
  final double heatDeltaOffset;

  double _heat = 0.0;
  Offset _lastPosition = Offset.zero;
  DateTime _lastTime = DateTime.now();

  Timer? _timer;
  DateTime _prevUpdateTime = DateTime.now();

  /// スクラッチしているタッチの開始
  void start(Offset position, DateTime time) {
    _timer?.cancel();

    _setLastState(position, time);
    onScratchBegan?.call(position, time, 0.0);

    _prevUpdateTime = time;
    _timer = Timer.periodic(interval, _onTick);
  }

  /// スクラッチしているタッチの移動
  void move(Offset position, DateTime time) {
    final deltaHeat = _calcHeat(
      position - _lastPosition,
      time.millisecondsSinceEpoch - _lastTime.millisecondsSinceEpoch,
    );

    _heat += deltaHeat;
    _setLastState(position, time);

    if (time.difference(_prevUpdateTime) >= interval) {
      onScratchMoved?.call(position, time, _heat);
      _heat = 0.0;
      _prevUpdateTime = time;
    }
  }

  /// スクラッチしているタッチの終了
  void end(Offset position, DateTime time) {
    _timer?.cancel();
    _timer = null;

    final deltaHeat = _calcHeat(
      position - _lastPosition,
      time.millisecondsSinceEpoch - _lastTime.millisecondsSinceEpoch,
    );

    onScratchEnded?.call(position, time, deltaHeat);
    _setLastState(Offset.zero, time);
    _heat = 0.0;
    _prevUpdateTime = time;
  }

  void _onTick(Timer timer) {
    final currentTime = DateTime.now();
    if (currentTime.isAfter(_prevUpdateTime.add(interval))) {
      onScratchMoved?.call(_lastPosition, currentTime, _heat);
      _heat = 0.0;
      _prevUpdateTime = currentTime;
    }
  }

  void _setLastState(Offset position, DateTime time) {
    _lastPosition = position;
    _lastTime = time;
  }

  double _calcHeat(Offset deltaPosition, int deltaMills) {
    final delta = deltaPosition.distance / (deltaMills * 0.001);
    return clampDouble(
      delta * heatDeltaScale + heatDeltaOffset,
      minHeatDelta,
      maxHeatDelta,
    );
  }
}

class ThermalTime {
  static DateTime now() => DateTime.now();
}
