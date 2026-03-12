part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthBootRequested extends AuthEvent {
  const AuthBootRequested();
}

final class AuthPhoneSubmitted extends AuthEvent {
  const AuthPhoneSubmitted(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthCodeSubmitted extends AuthEvent {
  const AuthCodeSubmitted(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class AuthRegistrationSubmitted extends AuthEvent {
  const AuthRegistrationSubmitted({
    required this.fullName,
    this.email,
    this.gender,
    this.birthDate,
    this.avatarUrl,
  });

  final String fullName;
  final String? email;
  final String? gender;
  final String? birthDate;
  final String? avatarUrl;

  @override
  List<Object?> get props => [fullName, email, gender, birthDate, avatarUrl];
}

final class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}
