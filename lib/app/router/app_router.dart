import 'package:flutter/foundation.dart';

import '../../data/models/models.dart';
import '../../core/utils/lifecycle_notifier.dart';
import '../../data/repositories/settings_repository.dart';

@immutable
class AppRouteState {
  final UserRole role;
  final int ownerNavIndex;
  final int sitterNavIndex;
  final bool showingSplash;
  final bool showingWelcome;
  final SitterListing? activeDetailSitter;
  final int sessionRevision;

  const AppRouteState({
    this.role = UserRole.owner,
    this.ownerNavIndex = 0,
    this.sitterNavIndex = 0,
    this.showingSplash = false,
    this.showingWelcome = false,
    this.activeDetailSitter,
    this.sessionRevision = 0,
  });

  AppRouteState copyWith({
    UserRole? role,
    int? ownerNavIndex,
    int? sitterNavIndex,
    bool? showingSplash,
    bool? showingWelcome,
    SitterListing? activeDetailSitter,
    bool clearDetailSitter = false,
    int? sessionRevision,
  }) {
    return AppRouteState(
      role: role ?? this.role,
      ownerNavIndex: ownerNavIndex ?? this.ownerNavIndex,
      sitterNavIndex: sitterNavIndex ?? this.sitterNavIndex,
      showingSplash: showingSplash ?? this.showingSplash,
      showingWelcome: showingWelcome ?? this.showingWelcome,
      activeDetailSitter: clearDetailSitter
          ? null
          : (activeDetailSitter ?? this.activeDetailSitter),
      sessionRevision: sessionRevision ?? this.sessionRevision,
    );
  }
}

class AppRouter extends LifecycleNotifier<AppRouteState> {
  final SettingsRepository _settingsRepository;

  AppRouter({
    SettingsRepository? settingsRepository,
    bool startWithSplash = false,
    bool respectFirstLaunch = false,
  }) : _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super(
         AppRouteState(
           role: (settingsRepository ?? const SettingsRepository())
               .getUserRole(),
           showingSplash: startWithSplash,
           showingWelcome:
               respectFirstLaunch &&
               !(settingsRepository ?? const SettingsRepository())
                   .hasCompletedWelcome,
         ),
       );

  UserRole get role => value.role;
  int get ownerNavIndex => value.ownerNavIndex;
  int get sitterNavIndex => value.sitterNavIndex;

  Future<void> setRole(UserRole newRole) async {
    await _settingsRepository.setUserRole(newRole);
    if (isDisposed) return;
    value = value.copyWith(
      role: newRole,
      showingWelcome: false,
      clearDetailSitter: true,
      sessionRevision: value.sessionRevision + 1,
    );
  }

  void setOwnerNavIndex(int index) {
    value = value.copyWith(
      ownerNavIndex: index,
      showingWelcome: false,
      clearDetailSitter: true,
    );
  }

  void setSitterNavIndex(int index) {
    value = value.copyWith(
      sitterNavIndex: index,
      showingWelcome: false,
      clearDetailSitter: true,
    );
  }

  void openSitterDetail(SitterListing sitter) {
    value = value.copyWith(activeDetailSitter: sitter, showingWelcome: false);
  }

  void closeSitterDetail() {
    value = value.copyWith(clearDetailSitter: true);
  }

  void showWelcome() {
    value = value.copyWith(showingWelcome: true, clearDetailSitter: true);
  }

  void closeWelcome() {
    value = value.copyWith(showingWelcome: false);
  }

  void finishSplash() {
    value = value.copyWith(showingSplash: false);
  }

  bool get canHandleBack =>
      value.activeDetailSitter != null ||
      value.showingWelcome ||
      (role == UserRole.owner ? ownerNavIndex : sitterNavIndex) != 0;

  void handleBack() {
    if (value.activeDetailSitter != null) {
      closeSitterDetail();
    } else if (value.showingWelcome) {
      closeWelcome();
    } else if (role == UserRole.owner) {
      setOwnerNavIndex(0);
    } else {
      setSitterNavIndex(0);
    }
  }
}
