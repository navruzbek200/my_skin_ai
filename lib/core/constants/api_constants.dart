/// Single source of truth for the hosted privacy policy — every in-app link
/// must point here so the URL can't drift out of sync between screens.
const String privacyPolicyUrl =
    'https://real-beauty-2b6b0.web.app/privacy_policy.html';

/// The user-facing version string, shown at the foot of the account screen.
///
/// A plain constant rather than `package_info_plus`: the plugin costs a
/// platform channel round trip at every read, and this only ever appears in one
/// line of small print. Keep it in step with `version:` in pubspec.yaml.
const String appVersion = '1.2.0';
