import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../../core/storage/greeting_cache_storage.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeAccountItem extends Equatable {
  const HomeAccountItem({
    required this.id,
    required this.title,
    required this.balance,
    required this.currency,
    required this.productType,
    this.mainCard,
  });

  final String id;
  final String title;
  final String balance;
  final String currency;
  final String productType;
  final HomeCardItem? mainCard;

  @override
  List<Object?> get props => [id, title, balance, currency, productType, mainCard];
}

class HomeCardItem extends Equatable {
  const HomeCardItem({
    required this.id,
    required this.accountId,
    required this.accountTitle,
    required this.balance,
    required this.currency,
    required this.maskedCardNumber,
    required this.productType,
    required this.label,
    required this.validThru,
    required this.bgColor1,
    required this.bgColor2,
    required this.status,
    this.isMain = false,
  });

  final String id;
  final String accountId;
  final String accountTitle;
  final String balance;
  final String currency;
  final String maskedCardNumber;
  final String productType;
  final String? label;
  final String? validThru;
  final String? bgColor1;
  final String? bgColor2;
  final String status;
  final bool isMain;

  @override
  List<Object?> get props => [
        id,
        accountId,
        accountTitle,
        balance,
        currency,
        maskedCardNumber,
        productType,
        label,
        validThru,
        bgColor1,
        bgColor2,
        status,
        isMain,
      ];
}

String? _repairMojibake(String? input) {
  final s = (input ?? '').trim();
  if (s.isEmpty) return null;

  // If backend already replaced unknown chars with '?', we can't restore them.
  // In that case return null so UI can fallback to a safer title.
  if (RegExp(r'\?{3,}').hasMatch(s)) return null;
  if (s.replaceAll('?', '').trim().isEmpty) return null;

  // Typical mojibake for Cyrillic looks like: "ÐÐ»ÑÑÐ°".
  // Try interpreting string bytes as latin1 and decoding as utf8.
  try {
    final bytes = latin1.encode(s);
    final decoded = utf8.decode(bytes, allowMalformed: true).trim();
    if (decoded.isNotEmpty && decoded != s) {
      // Heuristic: accept only if it contains Cyrillic or looks more "readable".
      final hasCyr = RegExp(r'[\u0400-\u04FF]').hasMatch(decoded);
      if (hasCyr) return decoded;
    }
  } catch (_) {
    // ignore
  }

  // If it contains replacement char, prefer fallback.
  if (s.contains('�')) return null;
  return s;
}

String? _normalizeValidThru(dynamic raw) {
  final s = (raw ?? '').toString().trim();
  if (s.isEmpty) return null;

  // Already MM/YY
  final mmYy = RegExp(r'^(0[1-9]|1[0-2])\s*/\s*(\d{2})$');
  final m1 = mmYy.firstMatch(s);
  if (m1 != null) {
    final mm = m1.group(1)!;
    final yy = m1.group(2)!;
    return '$mm/$yy';
  }

  // Digits like 1227
  final digits = s.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 4) {
    final mm = digits.substring(0, 2);
    final yy = digits.substring(2, 4);
    final mmInt = int.tryParse(mm);
    if (mmInt != null && mmInt >= 1 && mmInt <= 12) return '$mm/$yy';
  }

  // ISO date-like: 2027-12-01
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (iso != null) {
    final year = iso.group(1)!;
    final month = iso.group(2)!;
    return '$month/${year.substring(2)}';
  }

  return null;
}

class HomeStoryItem extends Equatable {
  const HomeStoryItem({
    required this.id,
    required this.code,
    required this.title,
    required this.miniImageUrl,
  });

  final String id;
  final String? code;
  final String title;
  final String? miniImageUrl;

  @override
  List<Object?> get props => [id, code, title, miniImageUrl];
}

class HomePropertyItem extends Equatable {
  const HomePropertyItem({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
    this.monthlyPayment,
    this.cashbackPercent = 0,
  });

  final String id;
  final String type;
  final String name;
  final String address;
  final String? monthlyPayment;
  final double cashbackPercent;

  @override
  List<Object?> get props => [id, type, name, address, monthlyPayment, cashbackPercent];
}

class HomeVehicleItem extends Equatable {
  const HomeVehicleItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String licensePlate;

  @override
  List<Object?> get props => [id, brand, model, year, licensePlate];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const HomeState()) {
    on<HomeRequested>(_onHomeRequested);
    on<HomeRefreshRequested>(_onHomeRefreshRequested);
    on<HomeBalanceUpdated>(_onHomeBalanceUpdated);
  }

  final ApiClient _apiClient;

  Future<void> _onHomeRefreshRequested(HomeRefreshRequested event, Emitter<HomeState> emit) async {
    try {
      final cardsRes = await _apiClient.dio.get('/cards');
      final accountsRes = await _apiClient.dio.get('/accounts');

      // Parse cards
      final cards = <HomeCardItem>[];
      final cardsData = cardsRes.data;
      if (cardsData is Map && cardsData['items'] is List) {
        for (final c in (cardsData['items'] as List)) {
          if (c is! Map) continue;
          final id = c['id']?.toString();
          final accountId = c['accountId']?.toString();
          final rawAccountTitle = c['accountTitle']?.toString();
          final balance = c['balance']?.toString();
          final currency = c['currency']?.toString();
          final masked = c['maskedCardNumber']?.toString();
          final productType = c['productType']?.toString();
          final status = c['status']?.toString();
          if (id == null || accountId == null || rawAccountTitle == null || balance == null || currency == null || masked == null || productType == null || status == null) {
            continue;
          }

          final repairedAccountTitle = _repairMojibake(rawAccountTitle);
          final accountTitle = repairedAccountTitle ?? (rawAccountTitle.contains('?') ? 'Карта' : rawAccountTitle);

          final rawLabel = c['label']?.toString();
          final label = _repairMojibake(rawLabel);

          final validThru = _normalizeValidThru(
            c['validThru'] ??
                c['valid_thru'] ??
                c['expiry'] ??
                c['expiryDate'] ??
                c['expiry_date'] ??
                c['expirationDate'] ??
                c['expiration_date'] ??
                c['expDate'] ??
                c['exp_date'] ??
                c['validUntil'] ??
                c['valid_until'],
          );

          cards.add(
            HomeCardItem(
              id: id,
              accountId: accountId,
              accountTitle: accountTitle,
              balance: balance,
              currency: currency,
              maskedCardNumber: masked,
              productType: productType,
              label: label,
              validThru: validThru,
              bgColor1: c['bgColor1']?.toString(),
              bgColor2: c['bgColor2']?.toString(),
              status: status,
              isMain: c['isMain'] == true || c['is_main'] == true,
            ),
          );
        }
      }

      // Parse accounts
      final accounts = <HomeAccountItem>[];
      final accountsData = accountsRes.data;
      if (accountsData is Map && accountsData['items'] is List) {
        for (final a in (accountsData['items'] as List)) {
          if (a is! Map) continue;
          final id = a['id']?.toString();
          final title = a['title']?.toString() ?? 'Счёт';
          final balance = a['balance']?.toString() ?? '0';
          final currency = a['currency']?.toString() ?? 'RUB';
          final productType = a['productType']?.toString() ?? a['type']?.toString() ?? 'debit';
          if (id == null) continue;

          final mainCard = cards.where((c) => c.accountId == id && c.isMain).firstOrNull;

          accounts.add(
            HomeAccountItem(
              id: id,
              title: title,
              balance: balance,
              currency: currency,
              productType: productType,
              mainCard: mainCard,
            ),
          );
        }
      }

      // Load properties
      final properties = <HomePropertyItem>[];
      try {
        final propertiesRes = await _apiClient.dio.get('/properties');
        final propertiesData = propertiesRes.data;
        if (propertiesData is Map && propertiesData['items'] is List) {
          for (final p in (propertiesData['items'] as List)) {
            if (p is! Map) continue;
            final id = p['id']?.toString();
            if (id == null) continue;
            properties.add(
              HomePropertyItem(
                id: id,
                type: p['type']?.toString() ?? 'apartment',
                name: p['name']?.toString() ?? '',
                address: p['address']?.toString() ?? '',
                monthlyPayment: p['monthlyPayment']?.toString(),
                cashbackPercent: double.tryParse(p['cashbackPercent']?.toString() ?? '0') ?? 0,
              ),
            );
          }
        }
      } catch (e) {
        print('Error loading properties: $e');
      }

      // Load vehicles
      final vehicles = <HomeVehicleItem>[];
      try {
        final vehiclesRes = await _apiClient.dio.get('/vehicles');
        final vehiclesData = vehiclesRes.data;
        if (vehiclesData is Map && vehiclesData['items'] is List) {
          for (final v in (vehiclesData['items'] as List)) {
            if (v is! Map) continue;
            final id = v['id']?.toString();
            if (id == null) continue;
            vehicles.add(
              HomeVehicleItem(
                id: id,
                brand: v['brand']?.toString() ?? '',
                model: v['model']?.toString() ?? '',
                year: int.tryParse(v['year']?.toString() ?? '0') ?? 0,
                licensePlate: v['licensePlate']?.toString() ?? '',
              ),
            );
          }
        }
      } catch (e) {
        print('Error loading vehicles: $e');
      }

      emit(state.copyWith(
        accounts: accounts,
        cards: cards,
        properties: properties,
        vehicles: vehicles,
      ));
    } catch (_) {
      // Silently fail - don't disrupt UI on refresh failure
    }
  }

  Future<void> _onHomeBalanceUpdated(HomeBalanceUpdated event, Emitter<HomeState> emit) async {
    // Quick refresh only for accounts/cards data without full reload
    try {
      final cardsRes = await _apiClient.dio.get('/cards');
      final accountsRes = await _apiClient.dio.get('/accounts');

      // Parse cards
      final cards = <HomeCardItem>[];
      final cardsData = cardsRes.data;
      if (cardsData is Map && cardsData['items'] is List) {
        for (final c in (cardsData['items'] as List)) {
          if (c is! Map) continue;
          final id = c['id']?.toString();
          final accountId = c['accountId']?.toString();
          final rawAccountTitle = c['accountTitle']?.toString();
          final balance = c['balance']?.toString();
          final currency = c['currency']?.toString();
          final masked = c['maskedCardNumber']?.toString();
          final productType = c['productType']?.toString();
          final status = c['status']?.toString();
          if (id == null || accountId == null || rawAccountTitle == null || balance == null || currency == null || masked == null || productType == null || status == null) {
            continue;
          }

          final repairedAccountTitle = _repairMojibake(rawAccountTitle);
          final accountTitle = repairedAccountTitle ?? (rawAccountTitle.contains('?') ? 'Карта' : rawAccountTitle);

          final rawLabel = c['label']?.toString();
          final label = _repairMojibake(rawLabel);

          final validThru = _normalizeValidThru(
            c['validThru'] ??
                c['valid_thru'] ??
                c['expiry'] ??
                c['expiryDate'] ??
                c['expiry_date'] ??
                c['expirationDate'] ??
                c['expiration_date'] ??
                c['expDate'] ??
                c['exp_date'] ??
                c['validUntil'] ??
                c['valid_until'],
          );

          cards.add(
            HomeCardItem(
              id: id,
              accountId: accountId,
              accountTitle: accountTitle,
              balance: balance,
              currency: currency,
              maskedCardNumber: masked,
              productType: productType,
              label: label,
              validThru: validThru,
              bgColor1: c['bgColor1']?.toString(),
              bgColor2: c['bgColor2']?.toString(),
              status: status,
              isMain: c['isMain'] == true || c['is_main'] == true,
            ),
          );
        }
      }

      // Parse accounts
      final accounts = <HomeAccountItem>[];
      final accountsData = accountsRes.data;
      if (accountsData is Map && accountsData['items'] is List) {
        for (final a in (accountsData['items'] as List)) {
          if (a is! Map) continue;
          final id = a['id']?.toString();
          final title = a['title']?.toString() ?? 'Счёт';
          final balance = a['balance']?.toString() ?? '0';
          final currency = a['currency']?.toString() ?? 'RUB';
          final productType = a['productType']?.toString() ?? a['type']?.toString() ?? 'debit';
          if (id == null) continue;

          final mainCard = cards.where((c) => c.accountId == id && c.isMain).firstOrNull;

          accounts.add(
            HomeAccountItem(
              id: id,
              title: title,
              balance: balance,
              currency: currency,
              productType: productType,
              mainCard: mainCard,
            ),
          );
        }
      }

      emit(state.copyWith(
        accounts: accounts,
        cards: cards,
      ));
    } catch (_) {
      // Silently fail - don't disrupt UI on balance update failure
    }
  }

  Future<void> _onHomeRequested(HomeRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      final cached = await GreetingCacheStorage().getCached();
      if (cached.userName != null || cached.avatarUrl != null) {
        emit(
          state.copyWith(
            userName: cached.userName ?? state.userName,
            avatarUrl: cached.avatarUrl ?? state.avatarUrl,
          ),
        );
      }
    } catch (_) {
      // ignore cache errors
    }

    try {
      final profileRes = await _apiClient.dio.get('/user/profile');
      final cardsRes = await _apiClient.dio.get('/cards');
      final accountsRes = await _apiClient.dio.get('/accounts');
      final storiesRes = await _apiClient.dio.get('/stories');

      final data = profileRes.data;

      String? name;
      String? fullName;
      String? firstName;
      String? avatarUrl;
      if (data is Map) {
        final rawName = data['name'];
        final rawFullName = data['fullName'] ?? data['full_name'];
        final rawFirstName = data['firstName'] ?? data['first_name'];
        final rawAvatarUrl = data['avatarUrl'] ?? data['avatar_url'];
        name = rawName?.toString();
        fullName = rawFullName?.toString();
        firstName = rawFirstName?.toString();
        avatarUrl = rawAvatarUrl?.toString();
      }

      final normalizedFirstName = (firstName ?? '').trim();
      final normalizedFullName = (fullName ?? '').trim();
      final normalizedName = (name ?? '').trim();
      final normalizedAvatar = (avatarUrl ?? '').trim();

      final resolvedUserName = normalizedFirstName.isNotEmpty
          ? normalizedFirstName
          : (normalizedFullName.isNotEmpty
              ? normalizedFullName
              : (normalizedName.isNotEmpty ? normalizedName : 'Пользователь'));

      try {
        await GreetingCacheStorage().setCached(
          userName: resolvedUserName,
          avatarUrl: normalizedAvatar.isNotEmpty ? normalizedAvatar : null,
        );
      } catch (_) {
        // ignore cache errors
      }

      // Парсим карты
      final cards = <HomeCardItem>[];
      final cardsData = cardsRes.data;
      if (cardsData is Map && cardsData['items'] is List) {
        for (final c in (cardsData['items'] as List)) {
          if (c is! Map) continue;
          final id = c['id']?.toString();
          final accountId = c['accountId']?.toString();
          final rawAccountTitle = c['accountTitle']?.toString();
          final balance = c['balance']?.toString();
          final currency = c['currency']?.toString();
          final masked = c['maskedCardNumber']?.toString();
          final productType = c['productType']?.toString();
          final status = c['status']?.toString();
          if (id == null || accountId == null || rawAccountTitle == null || balance == null || currency == null || masked == null || productType == null || status == null) {
            continue;
          }

          final repairedAccountTitle = _repairMojibake(rawAccountTitle);
          final accountTitle = repairedAccountTitle ?? (rawAccountTitle.contains('?') ? 'Карта' : rawAccountTitle);

          final rawLabel = c['label']?.toString();
          final label = _repairMojibake(rawLabel);

          final validThru = _normalizeValidThru(
            c['validThru'] ??
                c['valid_thru'] ??
                c['expiry'] ??
                c['expiryDate'] ??
                c['expiry_date'] ??
                c['expirationDate'] ??
                c['expiration_date'] ??
                c['expDate'] ??
                c['exp_date'] ??
                c['validUntil'] ??
                c['valid_until'],
          );

          cards.add(
            HomeCardItem(
              id: id,
              accountId: accountId,
              accountTitle: accountTitle,
              balance: balance,
              currency: currency,
              maskedCardNumber: masked,
              productType: productType,
              label: label,
              validThru: validThru,
              bgColor1: c['bgColor1']?.toString(),
              bgColor2: c['bgColor2']?.toString(),
              status: status,
              isMain: c['isMain'] == true || c['is_main'] == true,
            ),
          );
        }
      }

      // Парсим счета и привязываем основные карты
      final accounts = <HomeAccountItem>[];
      final accountsData = accountsRes.data;
      if (accountsData is Map && accountsData['items'] is List) {
        for (final a in (accountsData['items'] as List)) {
          if (a is! Map) continue;
          final id = a['id']?.toString();
          final title = a['title']?.toString() ?? 'Счёт';
          final balance = a['balance']?.toString() ?? '0';
          final currency = a['currency']?.toString() ?? 'RUB';
          final productType = a['productType']?.toString() ?? a['type']?.toString() ?? 'debit';
          if (id == null) continue;

          // Находим основную карту для этого счёта
          final mainCard = cards.where((c) => c.accountId == id && c.isMain).firstOrNull;

          accounts.add(
            HomeAccountItem(
              id: id,
              title: title,
              balance: balance,
              currency: currency,
              productType: productType,
              mainCard: mainCard,
            ),
          );
        }
      }

      final stories = <HomeStoryItem>[];
      final storiesData = storiesRes.data;
      if (storiesData is Map && storiesData['items'] is List) {
        for (final s in (storiesData['items'] as List)) {
          if (s is! Map) continue;
          final id = s['id']?.toString();
          final title = s['title']?.toString();
          if (id == null || title == null) continue;
          stories.add(
            HomeStoryItem(
              id: id,
              code: s['code']?.toString(),
              title: title,
              miniImageUrl: s['miniImageUrl']?.toString(),
            ),
          );
        }
      }

      // Load properties
      final properties = <HomePropertyItem>[];
      try {
        final propertiesRes = await _apiClient.dio.get('/properties');
        final propertiesData = propertiesRes.data;
        if (propertiesData is Map && propertiesData['items'] is List) {
          for (final p in (propertiesData['items'] as List)) {
            if (p is! Map) continue;
            final id = p['id']?.toString();
            if (id == null) continue;
            properties.add(
              HomePropertyItem(
                id: id,
                type: p['type']?.toString() ?? 'apartment',
                name: p['name']?.toString() ?? '',
                address: p['address']?.toString() ?? '',
                monthlyPayment: p['monthlyPayment']?.toString(),
                cashbackPercent: double.tryParse(p['cashbackPercent']?.toString() ?? '0') ?? 0,
              ),
            );
          }
        }
      } catch (e) {
        print('Error loading properties: $e');
        // Silently fail - properties are optional
      }

      // Load vehicles
      final vehicles = <HomeVehicleItem>[];
      try {
        final vehiclesRes = await _apiClient.dio.get('/vehicles');
        final vehiclesData = vehiclesRes.data;
        if (vehiclesData is Map && vehiclesData['items'] is List) {
          for (final v in (vehiclesData['items'] as List)) {
            if (v is! Map) continue;
            final id = v['id']?.toString();
            if (id == null) continue;
            vehicles.add(
              HomeVehicleItem(
                id: id,
                brand: v['brand']?.toString() ?? '',
                model: v['model']?.toString() ?? '',
                year: int.tryParse(v['year']?.toString() ?? '0') ?? 0,
                licensePlate: v['licensePlate']?.toString() ?? '',
              ),
            );
          }
        }
      } catch (e) {
        print('Error loading vehicles: $e');
        // Silently fail - vehicles are optional
      }

      emit(
        state.copyWith(
          status: HomeStatus.ready,
          userName: resolvedUserName,
          avatarUrl: normalizedAvatar.isNotEmpty ? normalizedAvatar : null,
          accounts: accounts,
          cards: cards,
          stories: stories,
          properties: properties,
          vehicles: vehicles,
          cashbackBalance: '0',
          bonusPoints: 0,
          recommendedTitle: 'Дебетовая карта для путешествий',
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          userName: state.userName ?? 'Пользователь',
          avatarUrl: state.avatarUrl,
          cashbackBalance: state.cashbackBalance ?? '0',
          bonusPoints: state.bonusPoints ?? 0,
          recommendedTitle: state.recommendedTitle ?? 'Дебетовая карта для путешествий',
        ),
      );
    }
  }
}
