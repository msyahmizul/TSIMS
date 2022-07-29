import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/screen/ScreenChoicePath.dart';
import 'package:frontend_admin/screen/ScreenNotFound.dart';
import 'package:frontend_admin/screen/admin/ScreenAdminLogin.dart';
import 'package:frontend_admin/screen/admin/ScreenImageBigScreen.dart';
import 'package:frontend_admin/screen/admin/ScreenUserDetailScreen.dart';
import 'package:frontend_admin/screen/admin/ScreenUserListBriefScreen.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingHome.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingLogin.dart';
import 'package:frontend_admin/screen/service/banking/ScreenBankingSignUp.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierHome.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierLogin.dart';
import 'package:frontend_admin/screen/service/carrier/ScreenCarrierSignUp.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityHome.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversityLogin.dart';
import 'package:frontend_admin/screen/service/university/ScreenUniversitySignUp.dart';

import 'Util.dart';
import 'const.dart';

List<BeamLocation<RouteInformationSerializable<BeamState>>> beamLocation = [
  ChoicePathLocation(),
  ServiceAdminLocation(),
  ServiceBankLocation(),
  ServiceCarrierLocation(),
  ServiceUniversityLocation(),
  NotFoundLocation()
];

class ServiceBankLocation extends BeamLocation<BeamState> {
  @override
  List<BeamGuard> get guards =>
      [
        BeamGuard(
            guardNonMatching: false,
            pathPatterns: [ScreenBankingSignUp.path, ScreenBankingHome.path],
            check: (context, location) {
              var box = Util.getBox();
              String t = box.get(HiveBox.connectionBank, defaultValue: "");
              return t.isNotEmpty;
            },
            beamToNamed: (origin, target) => ScreenBankingLogin.path),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    List<BeamPage> pages = [ScreenBankingHome.page()];
    if (state.uri.pathSegments.contains("login")) {
      pages.add(ScreenBankingLogin.page());
    }
    if (state.uri.pathSegments.contains("create")) {
      pages.add(ScreenBankingSignUp.page());
    }
    return pages;
  }

  @override
  List<Pattern> get pathPatterns =>
      [
        ScreenBankingLogin.path,
        ScreenBankingHome.path,
        ScreenBankingSignUp.path
      ];
}

class ChoicePathLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [ScreenPathChoice.page()];
  }

  @override
  List<Pattern> get pathPatterns => [ScreenPathChoice.path];
}

class ServiceAdminLocation extends BeamLocation<BeamState> {
  @override
  List<BeamGuard> get guards =>
      [
        BeamGuard(
            guardNonMatching: false,
            pathPatterns: [
              ScreenUserListBrief.path,
              ScreenUserDetail.path,
              ImageBigScreen.path
            ],
            check: (context, location) {
              var box = Util.getBox();
              String t = box.get(HiveBox.jwtAdmin, defaultValue: "");
              return t.isNotEmpty;
            },
            beamToNamed: (origin, target) => ScreenAdminLogin.path)
      ];

  @override
  List<Pattern> get pathPatterns =>
      [
        ScreenAdminLogin.path,
        ScreenUserListBrief.path,
        ScreenUserDetail.path,
        ImageBigScreen.path
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    List<BeamPage> pages = [];
    if (state.uri.pathSegments.contains("user")) {
      if (state.uri.pathSegments.contains("login")) {
        pages.add(ScreenAdminLogin.page);
        return pages;
      }
      pages.add(ScreenUserListBrief.page);
      final String? userID = state.pathParameters['id'];
      final String? imageID = state.pathParameters[ImageBigScreen.argsName];
      if (userID != null) {
        pages.add(ScreenUserDetail.page(userID));
      }
      if (imageID != null) {
        pages.add(ImageBigScreen.page(imageID));
      }
    }

    //
    // final String? userID = state.pathParameters['id'];
    // final String? imageID = state.pathParameters[ImageBigScreen.argsName];
    // if (userID != null) {
    //   pages.add(ScreenUserDetail.page(userID));
    // }
    // if (imageID != null) {
    //   pages.add(ImageBigScreen.page(imageID));
    // }
    return pages;
  }
}

class ServiceCarrierLocation extends BeamLocation<BeamState> {
  @override
  List<BeamGuard> get guards =>
      [
        BeamGuard(
            guardNonMatching: false,
            pathPatterns: [ScreenCarrierSignUp.path, ScreenCarrierHome.path],
            check: (context, location) {
              var box = Util.getBox();
              String t = box.get(HiveBox.connectionCarrier, defaultValue: "");
              return t.isNotEmpty;
            },
            beamToNamed: (origin, target) => ScreenCarrierLogin.path),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final List<BeamPage> pages = [ScreenCarrierHome.page()];
    if (state.uri.pathSegments.contains("login")) {
      pages.add(ScreenCarrierLogin.page());
    }
    if (state.uri.pathSegments.contains("create")) {
      pages.add(ScreenCarrierSignUp.page());
    }
    return pages;
  }

  @override
  List<Pattern> get pathPatterns =>
      [
        ScreenCarrierLogin.path,
        ScreenCarrierSignUp.path,
        ScreenCarrierHome.path
      ];
}

class ServiceUniversityLocation extends BeamLocation<BeamState> {
  @override
  List<BeamGuard> get guards =>
      [
        BeamGuard(
            guardNonMatching: false,
            pathPatterns: [
              ScreenUniversityHome.path,
              ScreenUniversitySignUp.path
            ],
            check: (context, location) {
              var box = Util.getBox();
              String t =
              box.get(HiveBox.connectionUniversity, defaultValue: "");
              return t.isNotEmpty;
            },
            beamToNamed: (origin, target) => ScreenUniversityLogin.path),
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final List<BeamPage> pages = [ScreenUniversityHome.page()];
    if (state.uri.pathSegments.contains("login")) {
      pages.add(ScreenUniversityLogin.page());
    }
    if (state.uri.pathSegments.contains("create")) {
      pages.add(ScreenUniversitySignUp.page());
    }
    return pages;
  }

  @override
  List<Pattern> get pathPatterns =>
      [
        ScreenUniversityLogin.path,
        ScreenUniversitySignUp.path,
        ScreenUniversityHome.path
      ];
}

class NotFoundLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return NotFoundScreen.pathBuilder;
  }

  @override
  List<Pattern> get pathPatterns => [NotFoundScreen.path];
}
