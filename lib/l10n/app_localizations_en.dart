// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My Skin AI';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAllow => 'Allow';

  @override
  String get commonPrivacyPolicy => 'Privacy policy';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get introTitle => 'Healthy skin —\na beautiful life';

  @override
  String get introSubtitle =>
      'Personal skin analysis and Korean skincare guidance';

  @override
  String get introStart => 'Get started';

  @override
  String get introChooseLanguage => 'Choose your language';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSubtitle =>
      'Enter an email and password — if you have no account yet, we\'ll create one.';

  @override
  String get authSubtitleReturning =>
      'Sign back in and pick your routine up where you left it.';

  @override
  String get authContinue => 'Continue';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authOr => 'or';

  @override
  String get authGoogleButton => 'Continue with Google';

  @override
  String get authPasswordHelper => 'At least 6 characters';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Enter a real email address';

  @override
  String get authPasswordRequired => 'Enter a password';

  @override
  String get authPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get authTermsNote => 'By continuing you agree to our terms';

  @override
  String authResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Resend in ${seconds}s',
    );
    return '$_temp0';
  }

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again';

  @override
  String get authErrorTimeout =>
      'No response. Check your connection and try again';

  @override
  String get authErrorUserNotFound => 'No account found for that email';

  @override
  String get authErrorWrongPassword => 'Wrong password';

  @override
  String get authErrorWrongPasswordOrGoogle =>
      'Wrong password. If you signed up with Google, use the Google button below';

  @override
  String get authErrorEmailInUse => 'That email is already registered';

  @override
  String get authErrorInvalidEmail => 'Invalid email format';

  @override
  String get authErrorNetwork => 'No internet connection';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait a moment';

  @override
  String get authErrorRequiresRecentLogin =>
      'For security, please sign in again';

  @override
  String get authErrorSessionExpired =>
      'Your session expired. Please sign in again';

  @override
  String get authErrorGoogle => 'Google sign-in failed';

  @override
  String get authErrorPasswordRequired => 'Enter your password';

  @override
  String get authErrorNotVerifiedYet =>
      'Not confirmed yet. Open the link in your email';

  @override
  String get authErrorDisposableEmail =>
      'Disposable inboxes aren\'t accepted. Use a permanent address';

  @override
  String get authErrorEmailTypo =>
      'That address looks like a typo. Please check it';

  @override
  String get authErrorEmailUnreachable =>
      'That mail domain doesn\'t exist. Check the address';

  @override
  String get authConfirmTitle => 'Is this address right?';

  @override
  String get authConfirmBody =>
      'The confirmation link goes to this address. One wrong letter and the message never arrives — the account cannot be opened, and a forgotten password cannot be reset.';

  @override
  String get authConfirmEdit => 'Edit it';

  @override
  String get authConfirmSend => 'Yes, that\'s mine';

  @override
  String get authInfoResetSent =>
      'Reset link sent (check your spam folder too)';

  @override
  String get authInfoVerificationSent =>
      'Confirmation link sent (check your spam folder too)';

  @override
  String get authInfoProfileUpdated => 'Saved';

  @override
  String get authInfoEmailVerified => 'Email confirmed';

  @override
  String get verifyTitle => 'Confirm your email';

  @override
  String verifyBody(String email) {
    return 'We sent a confirmation link to $email. Open the message and tap the link.';
  }

  @override
  String get verifyHint =>
      'No message yet? Check your spam folder — delivery can take a few minutes.';

  @override
  String get verifyCheck => 'I\'ve confirmed, check now';

  @override
  String get verifyResend => 'Send the link again';

  @override
  String get verifyWhy =>
      'If you ever forget your password, the reset link can only go to a confirmed address. That\'s why this step happens once.';

  @override
  String get verifyUseAnother => 'Start over with another email';

  @override
  String get verifyStartOverTitle => 'Start over with another email?';

  @override
  String get verifyStartOverBody =>
      'This account will be deleted and you\'ll sign up with a new email. Your skin profile and scan history stay on this device.';

  @override
  String get verifyStartOverConfirm => 'Yes, use another one';

  @override
  String get forgotTitle => 'Reset password';

  @override
  String get forgotSubtitle =>
      'Enter your email address\nand we\'ll send you a reset link';

  @override
  String get forgotSend => 'Send the link';

  @override
  String get forgotSentTitle => 'Link sent!';

  @override
  String get forgotSentBody =>
      'Check your inbox (and the spam folder) and set a new password through the link';

  @override
  String get forgotBackToSignIn => 'Back to sign in';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountDefaultName => 'My Skin AI user';

  @override
  String get accountSkinProfile => 'Skin profile';

  @override
  String get accountRetakeAnalysis => 'Retake the analysis';

  @override
  String get accountNotAnalysed => 'Not analysed yet';

  @override
  String get accountStartAnalysis => 'Start the analysis';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountEmailUnverified => 'Email not confirmed';

  @override
  String get accountEmailUnverifiedBody =>
      'If you forget your password, the reset link can only go to a confirmed address.';

  @override
  String get accountSendLink => 'Send the link';

  @override
  String get accountResendLink => 'Send the link again';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountSignOutTitle => 'Sign out?';

  @override
  String get accountSignOutBody => 'Are you sure you want to sign out?';

  @override
  String get accountDeleteAccount => 'Delete account';

  @override
  String get accountDeleteBody =>
      'Your account will be permanently deleted. Continue?';

  @override
  String get accountDeletedNotice => 'Account deleted — local data cleared';

  @override
  String get accountNoEmail => 'This account has no email';

  @override
  String get accountConfirmIdentity => 'Confirm it\'s you';

  @override
  String get accountConfirmPasswordBody =>
      'Enter your password to delete the account.';

  @override
  String get accountConfirmGoogleBody =>
      'Confirm with your Google account to delete the account.';

  @override
  String accountResetSentBody(String email) {
    return 'A reset link was sent to $email (check your spam folder too). Set a new password in the browser, then come back here and enter it.';
  }

  @override
  String get accountNewPassword => 'New password';

  @override
  String get accountConfirmDelete => 'Confirm and delete';

  @override
  String get accountConfirmDeleteGoogle => 'Confirm with Google and delete';

  @override
  String accountVersion(String version) {
    return 'Version $version';
  }

  @override
  String get navToday => 'Today';

  @override
  String get navProducts => 'Products';

  @override
  String get navScan => 'Analysis';

  @override
  String get navLessons => 'Lessons';

  @override
  String get navCosmetologist => 'Experts';

  @override
  String homeTasksProgress(int done, int total) {
    return '$done / $total tasks';
  }

  @override
  String get homeStartAnalysisTitle => 'Start your skin analysis';

  @override
  String get homeStartAnalysisBody =>
      'Take the short analysis to get your personal skincare plan.';

  @override
  String homeStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String get homeStreakLabel => 'Day streak';

  @override
  String get homeAllDone => 'All done!';

  @override
  String get homeGoal => 'Skincare goal';

  @override
  String get homeMorning => 'Morning';

  @override
  String get homeEvening => 'Evening';

  @override
  String get promoTitle => 'Analyse your skin';

  @override
  String get promoBody =>
      'Answer a short questionnaire to find your skin type and get a personalised skincare plan.';

  @override
  String get promoStart => 'Start the analysis';

  @override
  String get quizTitle => 'Skin analysis';

  @override
  String quizQuestionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get quizSelectOne => 'Please choose one answer';

  @override
  String get quizWriteAnswer => 'Write your answer';

  @override
  String get quizWriteHere => 'Type here...';

  @override
  String get quizExitTitle => 'Leave?';

  @override
  String get quizExitBody => 'Your answers won\'t be saved.';

  @override
  String get quizPrivacyTitle => 'Data and privacy';

  @override
  String get quizPrivacyBody =>
      'Your questionnaire answers are stored only on this device and are never sent over the internet.\n\nDuring the camera step, images are processed on the device only — nothing is stored or uploaded.\n\nThe result is calculated from your questionnaire answers.';

  @override
  String get quizAccept => 'I agree';

  @override
  String get analysisTitle => 'Analysing...';

  @override
  String get analysisSubtitle => 'Working through your answers';

  @override
  String get analysisStep1 => 'Reading your answers';

  @override
  String get analysisStep2 => 'Identifying your skin type';

  @override
  String get analysisStep3 => 'Assessing concerns';

  @override
  String get analysisStep4 => 'Preparing your results';

  @override
  String get resultsTitle => 'Your skin analysis is ready!';

  @override
  String get resultsSkinType => 'Your skin type';

  @override
  String resultsSkinTypeValue(String type) {
    return '$type skin';
  }

  @override
  String resultsMoreAdvice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more',
    );
    return '$_temp0';
  }

  @override
  String get resultsMainAdvice => 'Main recommendation';

  @override
  String get resultsExtraAdvice => 'Further recommendations';

  @override
  String get resultsDisclaimer =>
      'This is a cosmetic analysis, not a medical diagnosis. See a specialist if you have skin problems.';

  @override
  String get resultsStart => 'Start the plan';

  @override
  String get scanInstructionsTitle => 'Scanning guide';

  @override
  String get scanTipGlasses => 'Take off your glasses';

  @override
  String get scanTipGlassesSub => 'And find a well-lit spot';

  @override
  String get scanTipHead => 'Hold your head upright';

  @override
  String get scanTipHeadSub => 'Then press Start';

  @override
  String get scanTipLook => 'Look straight at the camera';

  @override
  String get scanTipLookSub => 'The photo is taken automatically';

  @override
  String get scanStartTitle => 'Start your skin analysis';

  @override
  String get scanStartBody => 'Find your skin type through the questionnaire';

  @override
  String get scanStartCta => 'Start the skin analysis';

  @override
  String get scanStartHint => 'Set aside a couple of minutes';

  @override
  String get scanFirstSaved => 'Your first scan is saved';

  @override
  String get scanFirstSavedBody => 'Scan again to see what has changed';

  @override
  String get scanComparison => 'Latest and previous scan';

  @override
  String get scanLatest => 'Latest';

  @override
  String scanSkinTypeValue(String type) {
    return '$type skin';
  }

  @override
  String get scanAiNote => 'AI analysis — not a medical diagnosis';

  @override
  String get scanProblems => 'Skin concerns';

  @override
  String get scanCauses => 'Causes and remedies';

  @override
  String get faceScanAlign => 'Bring your face into the frame';

  @override
  String get faceScanHold => 'Hold still';

  @override
  String get faceScanStep1 => 'Processing questionnaire answers';

  @override
  String get faceScanStep2 => 'Identifying your skin type';

  @override
  String get faceScanStep3 => 'Building recommendations';

  @override
  String get faceScanStep4 => 'Preparing your result';

  @override
  String get faceScanPreparingResult => 'Preparing your result...';

  @override
  String get faceScanPreparingCamera => 'Getting the camera ready';

  @override
  String get faceScanPermissionTitle => 'Camera access needed';

  @override
  String get faceScanPermissionBody =>
      'The front camera is used to line your face up. The result itself is built from your questionnaire answers.';

  @override
  String get faceScanPermissionDeniedTitle => 'Camera access is off';

  @override
  String get faceScanPermissionDeniedBody =>
      'Turn on the \"Camera\" permission in Settings to line your face up (optional).';

  @override
  String get faceScanContinueWithQuiz => 'Continue with the questionnaire';

  @override
  String get faceScanNoCameraTitle => 'No camera found';

  @override
  String get faceScanNoCameraBody =>
      'The camera on this device isn\'t available. You can continue with the questionnaire.';

  @override
  String get faceScanTooDark => 'Move somewhere brighter';

  @override
  String get faceScanOneFace => 'Show one face only';

  @override
  String get faceScanCloser => 'Come a little closer';

  @override
  String get faceScanFurther => 'Move back slightly';

  @override
  String get faceScanCenter => 'Centre your face';

  @override
  String get faceScanLookStraight => 'Look straight ahead';

  @override
  String get faceScanOpenEyes => 'Open your eyes';

  @override
  String get faceScanTimeoutTitle => 'Time\'s up';

  @override
  String get faceScanTimeoutBody => 'Try again, or continue?';

  @override
  String get faceScanHowTitle => 'How does it work?';

  @override
  String get faceScanHowBody =>
      '• Place your face inside the oval\n• Look straight at the camera\n• Keep your eyes open\n• Make sure the light is good\n• Scanning starts automatically';

  @override
  String get faceScanDisclaimer =>
      'This is a cosmetic analysis, not a medical diagnosis.';

  @override
  String get productsTitle => 'Korean brand\nproducts';

  @override
  String get productsEmpty => 'No products found';

  @override
  String get productsBenefits => 'Benefits';

  @override
  String get productsError => 'Couldn\'t load the products';

  @override
  String get lessonBadge => 'Article';

  @override
  String get lessonsSubtitle => 'Face yoga, ingredients and articles';

  @override
  String get lessonsYoga => 'Face yoga';

  @override
  String get lessonsYogaExercises => 'Yoga exercises';

  @override
  String lessonsExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String lessonStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String lessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '$count step',
    );
    return '$_temp0';
  }

  @override
  String get lessonFinish => 'Finish the lesson ✓';

  @override
  String get lessonNext => 'Next →';

  @override
  String lessonReadTime(String duration) {
    return '$duration read';
  }

  @override
  String get lessonPlayPause => 'Play or pause the video';

  @override
  String get cosmoSearchHint => 'Search for a specialist...';

  @override
  String cosmoNoSearchResults(String query) {
    return 'Nothing found for \"$query\"';
  }

  @override
  String cosmoNoFilterResults(String filter) {
    return 'No specialists found for $filter';
  }

  @override
  String get cosmoTryOther => 'Try another keyword or filter';

  @override
  String cosmoYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yrs',
      one: '$years yr',
    );
    return '$_temp0';
  }

  @override
  String cosmoYearsExperience(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years of experience',
      one: '$years year of experience',
    );
    return '$_temp0';
  }

  @override
  String get cosmoCallFailed => 'Couldn\'t open that app';

  @override
  String get cosmoError => 'Couldn\'t load the specialists';

  @override
  String get routineError => 'Couldn\'t build your plan';

  @override
  String get productsHeading => 'Products';

  @override
  String productsPrice(String amount) {
    return '$amount UZS';
  }

  @override
  String get productsPriceOnRequest => 'Price on request';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '$count product',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterAll => 'All';

  @override
  String get productsEmptyBody =>
      'Nothing in this category yet. Try another one.';

  @override
  String get productsErrorBody => 'Check your connection and try again.';

  @override
  String get forgotWhyTitle => 'What happens next';

  @override
  String get forgotStep1 => 'We email you a link';

  @override
  String get forgotStep2 => 'You set a new password through it';

  @override
  String get forgotStep3 => 'You sign in with the new password';

  @override
  String get forgotNoEmailHint =>
      'No message? Check your spam folder, or give it a couple of minutes.';

  @override
  String get forgotGoogleHint =>
      'If you signed in with Google you have no password — use the Google button on the sign-in page.';

  @override
  String get forgotResend => 'Send again';

  @override
  String forgotSentTo(String email) {
    return 'Link sent to $email';
  }

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDone => 'Done';

  @override
  String get commonRetryShort => 'Retry';

  @override
  String get commonSettingsApp => 'Settings';

  @override
  String get lessonsHeading => 'Lessons';

  @override
  String get lessonsIngredients => 'Ingredients';

  @override
  String get lessonsArticles => 'Articles';

  @override
  String get scanResultsHeading => 'Results';

  @override
  String get scanPrevious => 'Previous';

  @override
  String get scanProblemCause => 'Cause';

  @override
  String get scanProblemSolution => 'What helps';

  @override
  String get cosmoHeading => 'Specialists';

  @override
  String get cosmoExperience => 'Experience';

  @override
  String get cosmoAddress => 'Address';

  @override
  String get cosmoAbout => 'About this specialist';

  @override
  String get cosmoSpecialties => 'Focus areas';

  @override
  String get cosmoFilterAll => 'All';

  @override
  String get cosmoFilterFacialist => 'Facialist';

  @override
  String get cosmoFilterDermatologist => 'Dermatologist';

  @override
  String get cosmoFilterAesthetician => 'Aesthetician';

  @override
  String get cosmoFilterInjection => 'Injectables';

  @override
  String get cosmoPhone => 'Phone';
}
