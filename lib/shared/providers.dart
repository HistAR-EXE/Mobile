import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/api/api_client.dart';
import 'package:histar_mobile/core/storage/session_storage.dart';
import 'package:histar_mobile/features/auth/auth_controller.dart';
import 'package:histar_mobile/features/auth/auth_repository.dart';
import 'package:histar_mobile/features/auth/google_sign_in_service.dart';
import 'package:histar_mobile/features/auth/auth_state.dart';
import 'package:histar_mobile/features/billing/billing_repository.dart';
import 'package:histar_mobile/features/chat/chat_repository.dart';
import 'package:histar_mobile/features/discovery/discovery_repository.dart';
import 'package:histar_mobile/features/gamification/gamification_repository.dart';
import 'package:histar_mobile/features/locations/locations_repository.dart';
import 'package:histar_mobile/features/panorama/panorama_repository.dart';
import 'package:histar_mobile/features/profile/profile_repository.dart';
import 'package:histar_mobile/features/squad/squad_repository.dart';
import 'package:histar_mobile/features/visit/visit_session_repository.dart';

final sessionStorageProvider = Provider<SessionStorage>((ref) => SessionStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(sessionStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider), ref.watch(sessionStorageProvider));
});

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final locationsRepositoryProvider = Provider<LocationsRepository>((ref) {
  return LocationsRepository(ref.watch(apiClientProvider));
});

final panoramaRepositoryProvider = Provider<PanoramaRepository>((ref) {
  return PanoramaRepository(ref.watch(apiClientProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(apiClientProvider));
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(ref.watch(apiClientProvider));
});

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(apiClientProvider));
});

final visitSessionRepositoryProvider = Provider<VisitSessionRepository>((ref) {
  return VisitSessionRepository(ref.watch(apiClientProvider));
});

final squadRepositoryProvider = Provider<SquadRepository>((ref) {
  return SquadRepository(ref.watch(apiClientProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
