/// Deja pasar cada restauración una sola vez, aunque el aviso se repita.
class RestoreOnceGate {
  int _handledEpoch = 0;

  /// Verdadero la primera vez que se ve [epoch]; falso si ya se atendió.
  bool take(int epoch) {
    if (epoch <= _handledEpoch) return false;
    _handledEpoch = epoch;
    return true;
  }
}
