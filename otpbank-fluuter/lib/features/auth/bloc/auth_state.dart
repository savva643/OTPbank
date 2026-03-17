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
    this.otpCode,
  });

  final AuthStatus status;
  final String? phone;
  final String? registrationToken;
  final String? otpCode;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    String? registrationToken,
    String? otpCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      registrationToken: registrationToken ?? this.registrationToken,
      otpCode: otpCode ?? this.otpCode,
    );
  }

  @override
  List<Object?> get props => [status, phone, registrationToken, otpCode];
}
