/// Tracks in-flight requests so only the latest response is applied.
class LatestRequestGate {
  int _serial = 0;

  int bump() => ++_serial;

  bool isCurrent(int requestId) => requestId == _serial;
}
