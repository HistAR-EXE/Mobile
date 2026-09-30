import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/shared/providers.dart';

/// Starts one visit session per [locationId] for the owning widget lifetime.
class ScreenVisitSession {
  ScreenVisitSession(this.ref);

  final WidgetRef ref;
  bool _started = false;
  String? _sessionId;

  String? get sessionId => _sessionId;

  Future<void> startIfAuthenticated({
    required String locationId,
    required String mode,
  }) async {
    if (_started) return;
    final auth = ref.read(authControllerProvider);
    if (!auth.isAuthenticated) return;
    _started = true;
    try {
      final session = await ref.read(visitSessionRepositoryProvider).start(
            locationId: locationId,
            mode: mode,
          );
      _sessionId = session.id;
    } catch (_) {
      _started = false;
    }
  }

  Future<void> end() async {
    final id = _sessionId;
    _sessionId = null;
    if (id == null) return;
    await ref.read(visitSessionRepositoryProvider).end(id);
  }
}
