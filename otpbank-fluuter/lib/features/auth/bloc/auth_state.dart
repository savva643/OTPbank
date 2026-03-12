part of 'auth_bloc.dart';

enum AuthStatus {
  initial,
  loading,
  unauthorized,
  codeRequested,
  needsRegistration,
  authorized,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.phone,
    this.registrationToken,
  });

  final AuthStatus status;
  final String? phone;
  final String? registrationToken;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    String? registrationToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      registrationToken: registrationToken ?? this.registrationToken,
    );
  }

  @override
  List<Object?> get props => [status, phone, registrationToken];
}
