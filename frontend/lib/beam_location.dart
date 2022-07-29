import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screen/ScreenCredentialDetail.dart';
import 'package:mobile/screen/ScreenCredentialNew.dart';
import 'package:mobile/screen/ScreenHome.dart';
import 'package:mobile/screen/ScreenIdentityCredentials.dart';
import 'package:mobile/screen/ScreenLogin.dart';
import 'package:mobile/screen/ScreenRequest.dart';
import 'package:mobile/screen/ScreenScanQR.dart';
import 'package:mobile/screen/ScreenSplash.dart';
import 'package:mobile/screen/sign_up/Page1_UserNamePassword.dart';
import 'package:mobile/screen/sign_up/Page2_SignUpProfile.dart';
import 'package:mobile/screen/sign_up/Page3_SignUpVerify.dart';
import 'package:mobile/screen/sign_up/Page4_InputPinKeyScreen.dart';
import 'package:mobile/screen/sign_up/Page5_Finalise.dart';

import 'ScreenGenerateDIDFlow.dart';

final beamLocation = [SignUpFlowLocation(), InitFlow(), HomeLocation()];

class SignUpFlowLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    List<BeamPage> pages = [];
    if (state.uri.pathSegments.contains("signup")) {
      if (state.uri.pathSegments.contains("1")) {
        pages.add(Page1_UserNamePassword.page());
      }
      if (state.uri.pathSegments.contains("2")) {
        pages.add(Page2_SignUpProfile.page());
      }
      if (state.uri.pathSegments.contains("3")) {
        pages.add(Page3_SignUpVerify.page());
      }
      if (state.uri.pathSegments.contains("4")) {
        pages.add(Page4_InputPinKeyScreen.page());
      }
      if (state.uri.pathSegments.contains("5")) {
        pages.add(Page5_Finalise.page());
      }
    }
    return pages;
  }

  @override
  List<Pattern> get pathPatterns => [
        Page1_UserNamePassword.path,
        Page2_SignUpProfile.path,
        Page3_SignUpVerify.path,
        Page4_InputPinKeyScreen.path,
        Page5_Finalise.path,
      ];
}

class HomeLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final List<BeamPage> pages = [ScreenHome.page()];
    if (state.uri.pathSegments.contains("genDID")) {
      pages.add(ScreenGenerateDIDFlow.page());
    }
    if (state.uri.pathSegments.contains("credentials")) {
      pages.add(ScreenIdentityCredentials.page());
      final String? indexCredentialDetail =
          state.pathParameters[ScreenCredentialDetail.pathArgs];
      if (indexCredentialDetail != null) {
        pages.add(ScreenCredentialDetail.page(indexCredentialDetail));
      }
    }
    if (state.uri.pathSegments.contains("scanQR")) {
      pages.add(ScreenScanQR.page());
    }
    if (state.uri.pathSegments.contains("credentialRequest")) {
      final String? preExID =
          state.pathParameters[ScreenRequest.pathPreEXIDArgs];
      if (preExID != null) {
        pages.add(ScreenRequest.page(preExID));
      }
    }
    if (state.uri.pathSegments.contains("credentialNew")) {
      final String? creExID =
          state.pathParameters[ScreenCredentialNew.pathArgs];
      if (creExID != null) {
        pages.add(ScreenCredentialNew.page(creExID));
      }
    }

    return pages;
  }

  @override
  List<Pattern> get pathPatterns => [
        ScreenHome.path,
        ScreenGenerateDIDFlow.path,
        ScreenIdentityCredentials.path,
        ScreenCredentialDetail.path,
        ScreenScanQR.path,
        ScreenRequest.path,
        ScreenCredentialNew.path
      ];
}

class InitFlow extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final List<BeamPage> pages = [ScreenSplash.page()];
    if (state.uri.pathSegments.contains("login")) {
      pages.add(ScreenLogin.page());
    }
    return pages;
  }

  @override
  List<Pattern> get pathPatterns => [ScreenSplash.path, ScreenLogin.path];
}
