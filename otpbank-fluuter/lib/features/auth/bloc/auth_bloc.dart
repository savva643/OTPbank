import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../core/storage/pin_code_storage.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({ApiClient? apiClient, AuthTokenStorage? tokenStorage})
      : _apiClient = apiClient ?? ApiClient(tokenStorage: tokenStorage),
        _tokenStorage = tokenStorage ?? AuthTokenStorage(),
        super(const AuthState()) {
    on<AuthBootRequested>(_onBoot);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthCodeSubmitted>(_onCodeSubmitted);
    on<AuthRegistrationSubmitted>(_onRegistrationSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  Future<void> _onBoot(AuthBootRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      emit(state.copyWith(status: AuthStatus.authorized));
      return;
    }

    emit(state.copyWith(status: AuthStatus.unauthorized));
  }

  Future<void> _onPhoneSubmitted(AuthPhoneSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, phone: event.phone));

    try {
      final res = await _apiClient.dio.post('/auth/otp/request', data: {"phone": event.phone});
      final data = res.data;
      final code = data is Map ? data['code']?.toString() : null;
      emit(state.copyWith(status: AuthStatus.codeRequested, otpCode: code));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  Future<void> _onCodeSubmitted(AuthCodeSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final res = await _apiClient.dio.post(
        '/auth/otp/verify',
        data: {"phone": state.phone, "code": event.code},
      );

      final data = res.data;
      if (data is Map && data['isNew'] == true) {
        emit(state.copyWith(
          status: AuthStatus.needsRegistration,
          registrationToken: data['registrationToken']?.toString() ?? '',
        ));
        return;
      }

      final token = data is Map ? data['accessToken']?.toString() ?? '' : '';
      if (token.isEmpty) {
        emit(state.copyWith(status: AuthStatus.failure));
        return;
      }

      await _tokenStorage.setAccessToken(token);
      emit(state.copyWith(status: AuthStatus.authorized));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  Future<void> _onRegistrationSubmitted(AuthRegistrationSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final res = await _apiClient.dio.post(
        '/auth/complete-registration',
        data: {
          "registrationToken": state.registrationToken,
          "fullName": event.fullName,
          "email": event.email,
          "gender": event.gender,
          "birthDate": event.birthDate,
          "avatarUrl": event.avatarUrl,
        },
      );

      final data = res.data;
      final token = data is Map ? data['accessToken']?.toString() ?? '' : '';
      if (token.isEmpty) {
        emit(state.copyWith(status: AuthStatus.failure));
        return;
      }

      await _tokenStorage.setAccessToken(token);
      emit(state.copyWith(status: AuthStatus.authorized));
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  Future<void> _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _tokenStorage.clear();
    await PinCodeStorage().clear();
    emit(const AuthState(status: AuthStatus.unauthorized));
  }
}
