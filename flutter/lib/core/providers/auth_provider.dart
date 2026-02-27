import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';

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
        // 这里可以调用 /me 接口验证 token
        // final user = await _apiService.getCurrentUser();
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } catch (e) {
        await _storage.delete(key: 'access_token');
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await Dio().post(
        '${_apiService.baseUrl}/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );
      final token = response.data['access_token'];
      await _storage.write(key: 'access_token', value: token);
      state = state.copyWith(isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: '登录失败，请检查邮箱和密码',
      );
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    state = AuthState();
  }
}
