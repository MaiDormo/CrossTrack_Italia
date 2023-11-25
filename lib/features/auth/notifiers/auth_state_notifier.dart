import 'dart:async';

import 'package:crosstrack_italia/features/auth/backend/auth_repository.dart';
import 'package:crosstrack_italia/features/auth/models/auth_result.dart';
import 'package:crosstrack_italia/features/auth/models/auth_state.dart';
import 'package:crosstrack_italia/features/constants/firebase_collection_name.dart';
import 'package:crosstrack_italia/features/constants/firebase_field_name.dart';
import 'package:crosstrack_italia/features/user_info/backend/user_info_storage.dart';
import 'package:crosstrack_italia/features/user_info/models/typedefs/user_id.dart';
import 'package:crosstrack_italia/features/user_info/models/user_info_model.dart';
import 'package:crosstrack_italia/providers/firebase_providers.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_notifier.g.dart';

//------------------PROVIDERS------------------//

@riverpod
bool isLoggedIn(IsLoggedInRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.result != null;
}

@riverpod
UserId? userId(UserIdRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.userId;
}

//for the loading screeen
@riverpod
bool isLoading(IsLoadingRef ref) {
  final authState = ref.watch(authStateNotifierProvider);
  return authState.isLoading;
}

@riverpod
Future<Widget> userImage(UserImageRef ref) async {
  final authState = ref.watch(authStateNotifierProvider.notifier);
  final userId = ref.watch(userIdProvider);
  final userProfileInfo = await ref.watch(fetchUserInfoProvider(userId!));
  final isLogged = ref.watch(isLoggedInProvider);
  return authState.userImage(
    isLogged,
    userId,
    userProfileInfo,
  );
}

@riverpod
Stream<UserInfo> fetchUserInfo(FetchUserInfoRef ref, UserId userId) async* {
  // Create a StreamController to manage the stream of UserInfoModel
  final controller = StreamController<UserInfo>();

  // Set up a Firestore query to listen for changes in user data
  final sub = ref
      .watch(firestoreProvider)
      .collection(
        FirebaseCollectionName.users,
      )
      .where(
        FirebaseFieldName.id,
        isEqualTo: userId,
      )
      .limit(1)
      .snapshots()
      .listen((snapshot) {
    // When the Firestore query snapshot updates
    if (snapshot.docs.isNotEmpty) {
      // Get the first document in the snapshot
      final doc = snapshot.docs.first;

      // Extract JSON data from the document
      final json = doc.data();

      // Create a UserInfoModel instance from the JSON data
      final userInfo = UserInfo.fromJson(json);

      // Add the UserInfoModel to the stream
      controller.add(userInfo);
    }
  });

  // Define a cleanup action when the provider is disposed
  ref.onDispose(() {
    // Cancel the Firestore query subscription
    sub.cancel();
    // Close the StreamController
    controller.close();
  });

  // Return the stream of UserInfoModel
  yield* controller.stream;
}

//------------------NOTIFIERS------------------//
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  late final _authRepository;
  late final _userInfoStorage;

  @override
  AuthState build() {
    _userInfoStorage = ref.watch(userInfoStorageProvider.notifier);
    _authRepository = ref.watch(authRepositoryProvider);
    return _authRepository.isAlreadyLoggedIn
        ? AuthState(
            result: AuthResult.success,
            isLoading: false,
            userId: _authRepository.userId,
          )
        : const AuthState(
            result: null,
            isLoading: false,
            userId: null,
          );
  }

  Future<void> logOut() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.logOut();
    state = const AuthState(
      result: null,
      isLoading: false,
      userId: null,
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.loginWithGoogle();
    final id = _authRepository.userId;
    if (result == AuthResult.success && id != null) {
      await saveUserInfo(id: id);
      state = AuthState(
        result: result,
        isLoading: false,
        userId: id,
      );
    } else {
      state = const AuthState(
        result: null,
        isLoading: false,
        userId: null,
      );
    }
  }

  Future<void> loginWithFacebook() async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.loginWithFacebook();
    final id = _authRepository.userId;
    if (result == AuthResult.success && id != null) {
      await saveUserInfo(id: id);
    }
    state = AuthState(
      result: result,
      isLoading: false,
      userId: id,
    );
  }

  Future<void> saveUserInfo({
    required UserId id,
  }) =>
      _userInfoStorage.saveUserInfo(
        id: id,
        displayName: _authRepository.displayName,
        email: _authRepository.email,
        profileImageUrl: _authRepository.profileImageUrl,
      );

  Future<Widget> userImage(
      bool isLogged, UserId id, AsyncValue<UserInfo> userProfileInfo) async {
    print('DEBUG: ' + isLogged.toString());
    if (isLogged) {
      print('DEBUG: ' + userProfileInfo.toString());
      return ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: userProfileInfo.when(
            data: (data) => Image.network(
              data.profileImageUrl!,
              fit: BoxFit.cover,
              width: 35,
              height: 35,
            ),
            loading: () => CircularProgressIndicator(),
            error: (e, s) => Icon(Icons.account_circle),
          ));
    } else {
      return Icon(Icons.account_circle);
    }
  }
}
