import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../data/models/models.dart';

class OnboardingController extends ValueNotifier<UserRole> {
  final AppRouter router;

  OnboardingController({required this.router}) : super(router.role);

  Future<void> selectRoleAndContinue(UserRole role) async {
    value = role;
    await router.setRole(role);
    if (role == UserRole.owner) {
      router.setOwnerNavIndex(0);
    } else {
      router.setSitterNavIndex(0);
    }
  }
}
