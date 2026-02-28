import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  final _apiService = ApiService();

  AuthNotifier() : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        final user = await _apiService.getCurrentUser();
        state = state.copyWith(isAuthenticated: true, isLoading: false, user: user);
      } catch (e) {
        await _storage.delete(key: 'access_token');
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiService.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '发送验证码失败，请稍后重试',
      );
    }
  }

  Future<void> login(String phoneNumber, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _apiService.login(phoneNumber, code);
      await _storage.write(key: 'access_token', value: token);
      final user = await _apiService.getCurrentUser();
      state = state.copyWith(isAuthenticated: true, isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: '登录失败，验证码错误或已过期',
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    state = AuthState();
  }
}
