import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/otp_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/bonuses/bloc/bonuses_bloc.dart';
import '../features/chat/bloc/chat_bloc.dart';
import '../features/home/bloc/home_bloc.dart';
import '../features/notifications/bloc/notifications_bloc.dart';
import '../features/products/bloc/products_bloc.dart';
import '../features/search/bloc/search_bloc.dart';
import '../features/splash/presentation/splash_screen.dart';

class OtpBankApp extends StatelessWidget {
  const OtpBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()),
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<ProductsBloc>(create: (_) => ProductsBloc()),
        BlocProvider<ChatBloc>(create: (_) => ChatBloc()),
        BlocProvider<BonusesBloc>(create: (_) => BonusesBloc()),
        BlocProvider<NotificationsBloc>(create: (_) => NotificationsBloc()),
        BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
      ],
      child: MaterialApp(
        title: 'OTPbank',
        debugShowCheckedModeBanner: false,
        theme: OtpTheme.light(),
        scrollBehavior: const _NoScrollbarScrollBehavior(),
        home: const SplashScreen(),
      ),
    );
  }
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  const _NoScrollbarScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
