import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'My Skin AI'**
  String get appName;

  /// No description provided for @commonEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get commonPassword;

  /// No description provided for @commonContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get commonContinue;

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @commonSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get commonSkip;

  /// No description provided for @commonSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get commonSettings;

  /// No description provided for @commonDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get commonDelete;

  /// No description provided for @commonAllow.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get commonAllow;

  /// No description provided for @commonPrivacyPolicy.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik siyosati'**
  String get commonPrivacyPolicy;

  /// No description provided for @languageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get languageTitle;

  /// No description provided for @languageUz.
  ///
  /// In uz, this message translates to:
  /// **'O\'zbekcha'**
  String get languageUz;

  /// No description provided for @languageRu.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageEn.
  ///
  /// In uz, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @introTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sog\'lom teri —\nchiroyli hayot'**
  String get introTitle;

  /// No description provided for @introSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy teri tahlili va koreyacha parvarish tavsiyalari'**
  String get introSubtitle;

  /// No description provided for @introStart.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get introStart;

  /// No description provided for @introChooseLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get introChooseLanguage;

  /// No description provided for @authWelcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz'**
  String get authWelcome;

  /// No description provided for @authWelcomeBack.
  ///
  /// In uz, this message translates to:
  /// **'Qaytganingizdan xursandmiz'**
  String get authWelcomeBack;

  /// No description provided for @authSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Email va parol kiriting — hisob bo\'lmasa, biz uni o\'zimiz ochamiz.'**
  String get authSubtitle;

  /// No description provided for @authSubtitleReturning.
  ///
  /// In uz, this message translates to:
  /// **'Avvalgi hisobingizga kiring va parvarish rejangizni davom ettiring.'**
  String get authSubtitleReturning;

  /// No description provided for @authContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get authContinue;

  /// No description provided for @authForgotPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get authForgotPassword;

  /// No description provided for @authOr.
  ///
  /// In uz, this message translates to:
  /// **'yoki'**
  String get authOr;

  /// No description provided for @authGoogleButton.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan kirish'**
  String get authGoogleButton;

  /// No description provided for @authAppleButton.
  ///
  /// In uz, this message translates to:
  /// **'Apple bilan kirish'**
  String get authAppleButton;

  /// No description provided for @authPasswordHelper.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 6 belgi'**
  String get authPasswordHelper;

  /// No description provided for @authShowPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni ko\'rsatish'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni yashirish'**
  String get authHidePassword;

  /// No description provided for @authEmailRequired.
  ///
  /// In uz, this message translates to:
  /// **'Email kiriting'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqiy email kiriting'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parol kiriting'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 6 belgidan iborat bo\'lishi kerak'**
  String get authPasswordTooShort;

  /// No description provided for @authTermsNote.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish orqali siz shartlarimizga rozilik bildirasiz'**
  String get authTermsNote;

  /// No description provided for @authResendIn.
  ///
  /// In uz, this message translates to:
  /// **'{seconds, plural, other{Qayta yuborish — {seconds} s}}'**
  String authResendIn(int seconds);

  /// No description provided for @authErrorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xato yuz berdi. Qaytadan urinib ko\'ring'**
  String get authErrorGeneric;

  /// No description provided for @authErrorTimeout.
  ///
  /// In uz, this message translates to:
  /// **'Javob kelmadi. Internetni tekshirib, qayta urinib ko\'ring'**
  String get authErrorTimeout;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Bunday email topilmadi'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol noto\'g\'ri'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorWrongPasswordOrGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Parol noto\'g\'ri. Agar Google orqali ro\'yxatdan o\'tgan bo\'lsangiz, pastdagi Google tugmasi bilan kiring'**
  String get authErrorWrongPasswordOrGoogle;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In uz, this message translates to:
  /// **'Bu email allaqachon ro\'yxatdan o\'tgan'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In uz, this message translates to:
  /// **'Email format noto\'g\'ri'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorNetwork.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo\'q'**
  String get authErrorNetwork;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'p urinish. Biroz kutib qaytib keling'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik uchun qaytadan kiring'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorSessionExpired.
  ///
  /// In uz, this message translates to:
  /// **'Sessiya tugadi. Ilovaga qaytadan kiring'**
  String get authErrorSessionExpired;

  /// No description provided for @authErrorGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali kirishda xato yuz berdi'**
  String get authErrorGoogle;

  /// No description provided for @authErrorApple.
  ///
  /// In uz, this message translates to:
  /// **'Apple orqali kirishda xato yuz berdi'**
  String get authErrorApple;

  /// No description provided for @authErrorAccountExists.
  ///
  /// In uz, this message translates to:
  /// **'Bu email boshqa usul bilan ro\'yxatdan o\'tgan. Avvalgi usulingiz bilan kiring.'**
  String get authErrorAccountExists;

  /// No description provided for @authErrorPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parolni kiriting'**
  String get authErrorPasswordRequired;

  /// No description provided for @authErrorNotVerifiedYet.
  ///
  /// In uz, this message translates to:
  /// **'Hali tasdiqlanmagan. Xatingizdagi havolani bosing'**
  String get authErrorNotVerifiedYet;

  /// No description provided for @authErrorDisposableEmail.
  ///
  /// In uz, this message translates to:
  /// **'Vaqtinchalik email qabul qilinmaydi. Doimiy manzilingizni kiriting'**
  String get authErrorDisposableEmail;

  /// No description provided for @authErrorEmailTypo.
  ///
  /// In uz, this message translates to:
  /// **'Email manzilida xatolik bordek. Tekshirib ko\'ring'**
  String get authErrorEmailTypo;

  /// No description provided for @authErrorEmailUnreachable.
  ///
  /// In uz, this message translates to:
  /// **'Bunday email domeni mavjud emas. Manzilni tekshiring'**
  String get authErrorEmailUnreachable;

  /// No description provided for @authConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'Manzil to\'g\'rimi?'**
  String get authConfirmTitle;

  /// No description provided for @authConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash havolasi shu manzilga keladi. Bitta harf xato bo\'lsa, xat yetib bormaydi: akkauntga ham kira olmaysiz, parolni ham tiklay olmaysiz.'**
  String get authConfirmBody;

  /// No description provided for @authConfirmEdit.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'rilash'**
  String get authConfirmEdit;

  /// No description provided for @authConfirmSend.
  ///
  /// In uz, this message translates to:
  /// **'Ha, bu meniki'**
  String get authConfirmSend;

  /// No description provided for @authInfoResetSent.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tiklash havolasi yuborildi (spam papkasini ham tekshiring)'**
  String get authInfoResetSent;

  /// No description provided for @authInfoVerificationSent.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash havolasi yuborildi (spam papkasini ham tekshiring)'**
  String get authInfoVerificationSent;

  /// No description provided for @authInfoProfileUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Saqlandi'**
  String get authInfoProfileUpdated;

  /// No description provided for @authInfoEmailVerified.
  ///
  /// In uz, this message translates to:
  /// **'Email tasdiqlandi'**
  String get authInfoEmailVerified;

  /// No description provided for @verifyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Emailingizni tasdiqlang'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In uz, this message translates to:
  /// **'{email} manziliga tasdiqlash havolasi yubordik. Xatni oching va havolani bosing.'**
  String verifyBody(String email);

  /// No description provided for @verifyHint.
  ///
  /// In uz, this message translates to:
  /// **'Xat kelmadimi? Spam papkasini ham tekshiring — bir necha daqiqa ketishi mumkin.'**
  String get verifyHint;

  /// No description provided for @verifyCheck.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqladim, tekshirish'**
  String get verifyCheck;

  /// No description provided for @verifyResend.
  ///
  /// In uz, this message translates to:
  /// **'Havolani qayta yuborish'**
  String get verifyResend;

  /// No description provided for @verifyWhy.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutsangiz, tiklash havolasi faqat tasdiqlangan manzilga yuboriladi. Shuning uchun bu qadam bir marta talab qilinadi.'**
  String get verifyWhy;

  /// No description provided for @verifyUseAnother.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa email bilan boshlash'**
  String get verifyUseAnother;

  /// No description provided for @verifyStartOverTitle.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa email bilan boshlansinmi?'**
  String get verifyStartOverTitle;

  /// No description provided for @verifyStartOverBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu hisob o\'chiriladi va siz yangi email bilan ro\'yxatdan o\'tasiz. Teri profilingiz va tahlil tarixingiz qurilmada qoladi.'**
  String get verifyStartOverBody;

  /// No description provided for @verifyStartOverConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Ha, boshqasini kiritaman'**
  String get verifyStartOverConfirm;

  /// No description provided for @forgotTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tiklash'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Email manzilingizni kiriting,\nbiz sizga tiklash havolasini yuboramiz'**
  String get forgotSubtitle;

  /// No description provided for @forgotSend.
  ///
  /// In uz, this message translates to:
  /// **'Havolani yuborish'**
  String get forgotSend;

  /// No description provided for @forgotSentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Havola yuborildi!'**
  String get forgotSentTitle;

  /// No description provided for @forgotSentBody.
  ///
  /// In uz, this message translates to:
  /// **'Email manzilingizni tekshiring (spam papkasini ham ko\'ring) va havola orqali yangi parol o\'rnating'**
  String get forgotSentBody;

  /// No description provided for @forgotBackToSignIn.
  ///
  /// In uz, this message translates to:
  /// **'Kirish sahifasiga qaytish'**
  String get forgotBackToSignIn;

  /// No description provided for @accountTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob'**
  String get accountTitle;

  /// No description provided for @accountDefaultName.
  ///
  /// In uz, this message translates to:
  /// **'My Skin AI foydalanuvchisi'**
  String get accountDefaultName;

  /// No description provided for @accountSkinProfile.
  ///
  /// In uz, this message translates to:
  /// **'Teri profili'**
  String get accountSkinProfile;

  /// No description provided for @accountRetakeAnalysis.
  ///
  /// In uz, this message translates to:
  /// **'Tahlilni qayta o\'tkazish'**
  String get accountRetakeAnalysis;

  /// No description provided for @accountNotAnalysed.
  ///
  /// In uz, this message translates to:
  /// **'Hali tahlil qilinmagan'**
  String get accountNotAnalysed;

  /// No description provided for @accountStartAnalysis.
  ///
  /// In uz, this message translates to:
  /// **'Tahlilni boshlash'**
  String get accountStartAnalysis;

  /// No description provided for @accountLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get accountLanguage;

  /// No description provided for @accountEmailUnverified.
  ///
  /// In uz, this message translates to:
  /// **'Email tasdiqlanmagan'**
  String get accountEmailUnverified;

  /// No description provided for @accountEmailUnverifiedBody.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutsangiz, tiklash havolasi faqat tasdiqlangan manzilga yuboriladi.'**
  String get accountEmailUnverifiedBody;

  /// No description provided for @accountSendLink.
  ///
  /// In uz, this message translates to:
  /// **'Havolani yuborish'**
  String get accountSendLink;

  /// No description provided for @accountResendLink.
  ///
  /// In uz, this message translates to:
  /// **'Havolani qayta yuborish'**
  String get accountResendLink;

  /// No description provided for @accountSignOut.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get accountSignOut;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chiqasizmi?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisobdan chiqishni tasdiqlaysizmi?'**
  String get accountSignOutBody;

  /// No description provided for @accountDeleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o\'chirish'**
  String get accountDeleteAccount;

  /// No description provided for @accountDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt butunlay o\'chiriladi. Davom etasizmi?'**
  String get accountDeleteBody;

  /// No description provided for @accountDeletedNotice.
  ///
  /// In uz, this message translates to:
  /// **'Akkaunt o\'chirildi — qurilmadagi ma\'lumotlar tozalandi'**
  String get accountDeletedNotice;

  /// No description provided for @accountNoEmail.
  ///
  /// In uz, this message translates to:
  /// **'Bu hisobda email yo\'q'**
  String get accountNoEmail;

  /// No description provided for @accountConfirmIdentity.
  ///
  /// In uz, this message translates to:
  /// **'Kimligingizni tasdiqlang'**
  String get accountConfirmIdentity;

  /// No description provided for @accountConfirmPasswordBody.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o\'chirish uchun parolingizni kiriting.'**
  String get accountConfirmPasswordBody;

  /// No description provided for @accountConfirmGoogleBody.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o\'chirish uchun Google hisobingiz orqali tasdiqlang.'**
  String get accountConfirmGoogleBody;

  /// No description provided for @accountConfirmAppleBody.
  ///
  /// In uz, this message translates to:
  /// **'Akkauntni o\'chirish uchun Apple hisobingiz orqali tasdiqlang.'**
  String get accountConfirmAppleBody;

  /// No description provided for @accountResetSentBody.
  ///
  /// In uz, this message translates to:
  /// **'Tiklash havolasi {email} manziliga yuborildi (spam papkasini ham tekshiring). Brauzerda yangi parol o\'rnating, so\'ng shu yerga qaytib uni kiriting.'**
  String accountResetSentBody(String email);

  /// No description provided for @accountNewPassword.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get accountNewPassword;

  /// No description provided for @accountConfirmDelete.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlab o\'chirish'**
  String get accountConfirmDelete;

  /// No description provided for @accountConfirmDeleteGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google bilan tasdiqlab o\'chirish'**
  String get accountConfirmDeleteGoogle;

  /// No description provided for @accountConfirmDeleteApple.
  ///
  /// In uz, this message translates to:
  /// **'Apple bilan tasdiqlab o\'chirish'**
  String get accountConfirmDeleteApple;

  /// No description provided for @accountVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String accountVersion(String version);

  /// No description provided for @navToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get navToday;

  /// No description provided for @navProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot'**
  String get navProducts;

  /// No description provided for @navScan.
  ///
  /// In uz, this message translates to:
  /// **'Tahlil'**
  String get navScan;

  /// No description provided for @navLessons.
  ///
  /// In uz, this message translates to:
  /// **'Darslar'**
  String get navLessons;

  /// No description provided for @navCosmetologist.
  ///
  /// In uz, this message translates to:
  /// **'Kosmetolog'**
  String get navCosmetologist;

  /// No description provided for @homeTasksProgress.
  ///
  /// In uz, this message translates to:
  /// **'{done} / {total} vazifa'**
  String homeTasksProgress(int done, int total);

  /// No description provided for @homeStartAnalysisTitle.
  ///
  /// In uz, this message translates to:
  /// **'Teri tahlilini boshlang'**
  String get homeStartAnalysisTitle;

  /// No description provided for @homeStartAnalysisBody.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy parvarish dasturingizni olish uchun qisqa tahlil o\'ting.'**
  String get homeStartAnalysisBody;

  /// No description provided for @homeStreakDays.
  ///
  /// In uz, this message translates to:
  /// **'{days, plural, other{{days} kun}}'**
  String homeStreakDays(int days);

  /// No description provided for @homeStreakLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ketma-ket parvarish'**
  String get homeStreakLabel;

  /// No description provided for @homeAllDone.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi bajarildi!'**
  String get homeAllDone;

  /// No description provided for @homeGoal.
  ///
  /// In uz, this message translates to:
  /// **'Parvarish maqsadi'**
  String get homeGoal;

  /// No description provided for @homeMorning.
  ///
  /// In uz, this message translates to:
  /// **'Ertalab'**
  String get homeMorning;

  /// No description provided for @homeEvening.
  ///
  /// In uz, this message translates to:
  /// **'Kechqurun'**
  String get homeEvening;

  /// No description provided for @promoTitle.
  ///
  /// In uz, this message translates to:
  /// **'Teringizni tahlil qiling'**
  String get promoTitle;

  /// No description provided for @promoBody.
  ///
  /// In uz, this message translates to:
  /// **'Teri tipingizni aniqlash uchun qisqa savolnomaga javob bering va shaxsiylashtirilgan parvarish rejasini oling.'**
  String get promoBody;

  /// No description provided for @promoStart.
  ///
  /// In uz, this message translates to:
  /// **'Tahlilni boshlash'**
  String get promoStart;

  /// No description provided for @quizTitle.
  ///
  /// In uz, this message translates to:
  /// **'Teri Tahlili'**
  String get quizTitle;

  /// No description provided for @quizQuestionNumber.
  ///
  /// In uz, this message translates to:
  /// **'Savol {number}'**
  String quizQuestionNumber(int number);

  /// No description provided for @quizSelectOne.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, bitta javobni tanlang'**
  String get quizSelectOne;

  /// No description provided for @quizWriteAnswer.
  ///
  /// In uz, this message translates to:
  /// **'Javobingizni yozing'**
  String get quizWriteAnswer;

  /// No description provided for @quizWriteHere.
  ///
  /// In uz, this message translates to:
  /// **'Bu yerga yozing...'**
  String get quizWriteHere;

  /// No description provided for @quizExitTitle.
  ///
  /// In uz, this message translates to:
  /// **'Chiqasizmi?'**
  String get quizExitTitle;

  /// No description provided for @quizExitBody.
  ///
  /// In uz, this message translates to:
  /// **'Javoblaringiz saqlanmaydi.'**
  String get quizExitBody;

  /// No description provided for @quizPrivacyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar va maxfiylik'**
  String get quizPrivacyTitle;

  /// No description provided for @quizPrivacyBody.
  ///
  /// In uz, this message translates to:
  /// **'Savolnoma javoblaringiz faqat qurilmangizda mahalliy saqlanadi va hech qachon internetga yuborilmaydi.\n\nKamera ishlatiladigan bosqichda tasvirlar faqat qurilma ichida qayta ishlanadi — hech narsa saqlanmaydi yoki yuborilmaydi.\n\nTahlil natijasi savolnoma javoblaringiz asosida hisoblanadi.'**
  String get quizPrivacyBody;

  /// No description provided for @quizAccept.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilaman'**
  String get quizAccept;

  /// No description provided for @analysisTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tahlil qilinmoqda...'**
  String get analysisTitle;

  /// No description provided for @analysisSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Savollaringiz asosida tahlil qilinmoqda'**
  String get analysisSubtitle;

  /// No description provided for @analysisStep1.
  ///
  /// In uz, this message translates to:
  /// **'Savollar tahlil qilinmoqda'**
  String get analysisStep1;

  /// No description provided for @analysisStep2.
  ///
  /// In uz, this message translates to:
  /// **'Teri turi aniqlanmoqda'**
  String get analysisStep2;

  /// No description provided for @analysisStep3.
  ///
  /// In uz, this message translates to:
  /// **'Muammolar baholanmoqda'**
  String get analysisStep3;

  /// No description provided for @analysisStep4.
  ///
  /// In uz, this message translates to:
  /// **'Natijalar tayyorlanmoqda'**
  String get analysisStep4;

  /// No description provided for @resultsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Teri tahlili tayyor!'**
  String get resultsTitle;

  /// No description provided for @resultsSkinType.
  ///
  /// In uz, this message translates to:
  /// **'Teri tipingiz'**
  String get resultsSkinType;

  /// No description provided for @resultsSkinTypeValue.
  ///
  /// In uz, this message translates to:
  /// **'{type} teri'**
  String resultsSkinTypeValue(String type);

  /// No description provided for @resultsMoreAdvice.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, other{+{count} tavsiya}}'**
  String resultsMoreAdvice(int count);

  /// No description provided for @resultsMainAdvice.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy tavsiya'**
  String get resultsMainAdvice;

  /// No description provided for @resultsExtraAdvice.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha tavsiyalar'**
  String get resultsExtraAdvice;

  /// No description provided for @resultsDisclaimer.
  ///
  /// In uz, this message translates to:
  /// **'Bu kosmetik tahlil tibbiy tashxis hisoblanmaydi. Teri muammolari bo\'lsa mutaxassisga murojaat qiling.'**
  String get resultsDisclaimer;

  /// No description provided for @resultsStart.
  ///
  /// In uz, this message translates to:
  /// **'Dasturni boshlash'**
  String get resultsStart;

  /// No description provided for @scanInstructionsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlash yo\'riqnomasi'**
  String get scanInstructionsTitle;

  /// No description provided for @scanTipGlasses.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'zoynakni yeching'**
  String get scanTipGlasses;

  /// No description provided for @scanTipGlassesSub.
  ///
  /// In uz, this message translates to:
  /// **'Va yorug\' joy toping'**
  String get scanTipGlassesSub;

  /// No description provided for @scanTipHead.
  ///
  /// In uz, this message translates to:
  /// **'Boshingizni tik tuting'**
  String get scanTipHead;

  /// No description provided for @scanTipHeadSub.
  ///
  /// In uz, this message translates to:
  /// **'Va Boshlash tugmasini bosing'**
  String get scanTipHeadSub;

  /// No description provided for @scanTipLook.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ri va frontal qarang'**
  String get scanTipLook;

  /// No description provided for @scanTipLookSub.
  ///
  /// In uz, this message translates to:
  /// **'Avtomatik suratga olinadi'**
  String get scanTipLookSub;

  /// No description provided for @scanStartTitle.
  ///
  /// In uz, this message translates to:
  /// **'Teri tahlilini boshlang'**
  String get scanStartTitle;

  /// No description provided for @scanStartBody.
  ///
  /// In uz, this message translates to:
  /// **'Savolnoma orqali teri tipingizni aniqlang'**
  String get scanStartBody;

  /// No description provided for @scanStartCta.
  ///
  /// In uz, this message translates to:
  /// **'Teri tahlilini boshlash'**
  String get scanStartCta;

  /// No description provided for @scanStartHint.
  ///
  /// In uz, this message translates to:
  /// **'Bir necha daqiqa vaqt ajrating'**
  String get scanStartHint;

  /// No description provided for @scanFirstSaved.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi skaningiz saqlandi'**
  String get scanFirstSaved;

  /// No description provided for @scanFirstSavedBody.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgarishni ko\'rish uchun yana skan qiling'**
  String get scanFirstSavedBody;

  /// No description provided for @scanComparison.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi va oldingi skan'**
  String get scanComparison;

  /// No description provided for @scanLatest.
  ///
  /// In uz, this message translates to:
  /// **'So\'nggi'**
  String get scanLatest;

  /// No description provided for @scanSkinTypeValue.
  ///
  /// In uz, this message translates to:
  /// **'{type} teri'**
  String scanSkinTypeValue(String type);

  /// No description provided for @scanAiNote.
  ///
  /// In uz, this message translates to:
  /// **'AI tahlili — tibbiy tashxis emas'**
  String get scanAiNote;

  /// No description provided for @scanProblems.
  ///
  /// In uz, this message translates to:
  /// **'Teri muammolari'**
  String get scanProblems;

  /// No description provided for @scanCauses.
  ///
  /// In uz, this message translates to:
  /// **'Sabablari va yechimlari'**
  String get scanCauses;

  /// No description provided for @faceScanAlign.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni ramkaga olib keling'**
  String get faceScanAlign;

  /// No description provided for @faceScanHold.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni tutib turing'**
  String get faceScanHold;

  /// No description provided for @faceScanStep1.
  ///
  /// In uz, this message translates to:
  /// **'Savolnoma javoblari qayta ishlanmoqda'**
  String get faceScanStep1;

  /// No description provided for @faceScanStep2.
  ///
  /// In uz, this message translates to:
  /// **'Teri tipi aniqlanmoqda'**
  String get faceScanStep2;

  /// No description provided for @faceScanStep3.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiyalar shakllantirilmoqda'**
  String get faceScanStep3;

  /// No description provided for @faceScanStep4.
  ///
  /// In uz, this message translates to:
  /// **'Natija tayyorlanmoqda'**
  String get faceScanStep4;

  /// No description provided for @faceScanPreparingResult.
  ///
  /// In uz, this message translates to:
  /// **'Natija tayyorlanmoqda...'**
  String get faceScanPreparingResult;

  /// No description provided for @faceScanPreparingCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamera tayyorlanmoqda'**
  String get faceScanPreparingCamera;

  /// No description provided for @faceScanPermissionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kamera ruxsati kerak'**
  String get faceScanPermissionTitle;

  /// No description provided for @faceScanPermissionBody.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni to\'g\'ri joylashtirish uchun old kamera kerak. Tahlil natijasi savolnoma javoblaringiz asosida tayyorlanadi.'**
  String get faceScanPermissionBody;

  /// No description provided for @faceScanPermissionDeniedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kamera ruxsati o\'chirilgan'**
  String get faceScanPermissionDeniedTitle;

  /// No description provided for @faceScanPermissionDeniedBody.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni joylashtirish uchun Sozlamalardan \"Kamera\" ruxsatini yoqing (ixtiyoriy).'**
  String get faceScanPermissionDeniedBody;

  /// No description provided for @faceScanContinueWithQuiz.
  ///
  /// In uz, this message translates to:
  /// **'Anketa bilan davom etish'**
  String get faceScanContinueWithQuiz;

  /// No description provided for @faceScanNoCameraTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kamera topilmadi'**
  String get faceScanNoCameraTitle;

  /// No description provided for @faceScanNoCameraBody.
  ///
  /// In uz, this message translates to:
  /// **'Qurilmangizda kamera ishlamayapti. Anketa asosida davom etish mumkin.'**
  String get faceScanNoCameraBody;

  /// No description provided for @faceScanTooDark.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\'roq joyga o\'ting'**
  String get faceScanTooDark;

  /// No description provided for @faceScanOneFace.
  ///
  /// In uz, this message translates to:
  /// **'Bitta yuz ko\'rsating'**
  String get faceScanOneFace;

  /// No description provided for @faceScanCloser.
  ///
  /// In uz, this message translates to:
  /// **'Yaqinroq keling'**
  String get faceScanCloser;

  /// No description provided for @faceScanFurther.
  ///
  /// In uz, this message translates to:
  /// **'Sal uzoqlashing'**
  String get faceScanFurther;

  /// No description provided for @faceScanCenter.
  ///
  /// In uz, this message translates to:
  /// **'Yuzni markazga oling'**
  String get faceScanCenter;

  /// No description provided for @faceScanLookStraight.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ri qarang'**
  String get faceScanLookStraight;

  /// No description provided for @faceScanOpenEyes.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'zingizni oching'**
  String get faceScanOpenEyes;

  /// No description provided for @faceScanTimeoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vaqt tugadi'**
  String get faceScanTimeoutTitle;

  /// No description provided for @faceScanTimeoutBody.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinasizmi yoki davom etasizmi?'**
  String get faceScanTimeoutBody;

  /// No description provided for @faceScanHowTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qanday ishlaydi?'**
  String get faceScanHowTitle;

  /// No description provided for @faceScanHowBody.
  ///
  /// In uz, this message translates to:
  /// **'• Yuzingizni oval ichiga joylang\n• To\'g\'ri va frontal qarang\n• Ko\'zingizni oching\n• Yaxshi yorug\'lik bo\'lsin\n• Skaner avtomatik boshlanadi'**
  String get faceScanHowBody;

  /// No description provided for @faceScanDisclaimer.
  ///
  /// In uz, this message translates to:
  /// **'Bu kosmetik tahlil bo\'lib, tibbiy tashxis hisoblanmaydi.'**
  String get faceScanDisclaimer;

  /// No description provided for @productsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Koreya brend\nmahsulotlar'**
  String get productsTitle;

  /// No description provided for @productsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot topilmadi'**
  String get productsEmpty;

  /// No description provided for @productsBenefits.
  ///
  /// In uz, this message translates to:
  /// **'Foydali tomonlari'**
  String get productsBenefits;

  /// No description provided for @productsError.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni yuklashda xato'**
  String get productsError;

  /// No description provided for @lessonBadge.
  ///
  /// In uz, this message translates to:
  /// **'Maqola'**
  String get lessonBadge;

  /// No description provided for @lessonsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuz yogasi, ingrediyentlar va maqolalar'**
  String get lessonsSubtitle;

  /// No description provided for @lessonsYoga.
  ///
  /// In uz, this message translates to:
  /// **'Yuz Yoga'**
  String get lessonsYoga;

  /// No description provided for @lessonsYogaExercises.
  ///
  /// In uz, this message translates to:
  /// **'Yoga mashqlari'**
  String get lessonsYogaExercises;

  /// No description provided for @lessonsExerciseCount.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, other{{count} ta mashq}}'**
  String lessonsExerciseCount(int count);

  /// No description provided for @lessonStepOf.
  ///
  /// In uz, this message translates to:
  /// **'{current} / {total} qadam'**
  String lessonStepOf(int current, int total);

  /// No description provided for @lessonStepCount.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, other{{count} qadam}}'**
  String lessonStepCount(int count);

  /// No description provided for @lessonFinish.
  ///
  /// In uz, this message translates to:
  /// **'Darsni tugatish ✓'**
  String get lessonFinish;

  /// No description provided for @lessonNext.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi →'**
  String get lessonNext;

  /// No description provided for @lessonReadTime.
  ///
  /// In uz, this message translates to:
  /// **'O\'qish uchun {duration}'**
  String lessonReadTime(String duration);

  /// No description provided for @lessonPlayPause.
  ///
  /// In uz, this message translates to:
  /// **'Videoni ijro etish yoki to\'xtatish'**
  String get lessonPlayPause;

  /// No description provided for @cosmoSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Kosmetolog qidirish...'**
  String get cosmoSearchHint;

  /// No description provided for @cosmoNoSearchResults.
  ///
  /// In uz, this message translates to:
  /// **'\"{query}\" bo\'yicha hech narsa topilmadi'**
  String cosmoNoSearchResults(String query);

  /// No description provided for @cosmoNoFilterResults.
  ///
  /// In uz, this message translates to:
  /// **'{filter} bo\'yicha kosmetolog topilmadi'**
  String cosmoNoFilterResults(String filter);

  /// No description provided for @cosmoTryOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa kalit so\'z yoki filtr sinab ko\'ring'**
  String get cosmoTryOther;

  /// No description provided for @cosmoYears.
  ///
  /// In uz, this message translates to:
  /// **'{years, plural, other{{years} yil}}'**
  String cosmoYears(int years);

  /// No description provided for @cosmoYearsExperience.
  ///
  /// In uz, this message translates to:
  /// **'{years, plural, other{{years} yillik tajriba}}'**
  String cosmoYearsExperience(int years);

  /// No description provided for @cosmoCallFailed.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani ochib bo\'lmadi'**
  String get cosmoCallFailed;

  /// No description provided for @cosmoError.
  ///
  /// In uz, this message translates to:
  /// **'Kosmetologlarni yuklashda xato'**
  String get cosmoError;

  /// No description provided for @routineError.
  ///
  /// In uz, this message translates to:
  /// **'Rejani tuzishda xato yuz berdi'**
  String get routineError;

  /// No description provided for @productsHeading.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get productsHeading;

  /// No description provided for @productsPrice.
  ///
  /// In uz, this message translates to:
  /// **'{amount} so\'m'**
  String productsPrice(String amount);

  /// No description provided for @productsPriceOnRequest.
  ///
  /// In uz, this message translates to:
  /// **'Narxi so\'rov bo\'yicha'**
  String get productsPriceOnRequest;

  /// No description provided for @productsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count, plural, other{{count} ta mahsulot}}'**
  String productsCount(int count);

  /// No description provided for @productsFilterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get productsFilterAll;

  /// No description provided for @productsEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu bo\'limda hozircha mahsulot yo\'q. Boshqa turkumni tanlang.'**
  String get productsEmptyBody;

  /// No description provided for @productsErrorBody.
  ///
  /// In uz, this message translates to:
  /// **'Internetni tekshirib, qaytadan urinib ko\'ring.'**
  String get productsErrorBody;

  /// No description provided for @forgotWhyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Nima bo\'ladi?'**
  String get forgotWhyTitle;

  /// No description provided for @forgotStep1.
  ///
  /// In uz, this message translates to:
  /// **'Emailingizga havola yuboramiz'**
  String get forgotStep1;

  /// No description provided for @forgotStep2.
  ///
  /// In uz, this message translates to:
  /// **'Havolani bosib, yangi parol o\'rnatasiz'**
  String get forgotStep2;

  /// No description provided for @forgotStep3.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol bilan ilovaga kirasiz'**
  String get forgotStep3;

  /// No description provided for @forgotNoEmailHint.
  ///
  /// In uz, this message translates to:
  /// **'Xat kelmadimi? Spam papkasini tekshiring yoki bir necha daqiqa kuting.'**
  String get forgotNoEmailHint;

  /// No description provided for @forgotGoogleHint.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali kirgan bo\'lsangiz, parolingiz yo\'q — kirish sahifasidagi Google tugmasidan foydalaning.'**
  String get forgotGoogleHint;

  /// No description provided for @forgotResend.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish'**
  String get forgotResend;

  /// No description provided for @forgotSentTo.
  ///
  /// In uz, this message translates to:
  /// **'Havola {email} manziliga yuborildi'**
  String forgotSentTo(String email);

  /// No description provided for @commonBack.
  ///
  /// In uz, this message translates to:
  /// **'Ortga'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get commonClose;

  /// No description provided for @commonDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get commonDone;

  /// No description provided for @commonRetryShort.
  ///
  /// In uz, this message translates to:
  /// **'Qayta'**
  String get commonRetryShort;

  /// No description provided for @commonSettingsApp.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get commonSettingsApp;

  /// No description provided for @lessonsHeading.
  ///
  /// In uz, this message translates to:
  /// **'Darslar'**
  String get lessonsHeading;

  /// No description provided for @lessonsIngredients.
  ///
  /// In uz, this message translates to:
  /// **'Ingrediyentlar'**
  String get lessonsIngredients;

  /// No description provided for @lessonsArticles.
  ///
  /// In uz, this message translates to:
  /// **'Maqolalar'**
  String get lessonsArticles;

  /// No description provided for @scanResultsHeading.
  ///
  /// In uz, this message translates to:
  /// **'Natijalar'**
  String get scanResultsHeading;

  /// No description provided for @scanPrevious.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi'**
  String get scanPrevious;

  /// No description provided for @scanProblemCause.
  ///
  /// In uz, this message translates to:
  /// **'Sababi'**
  String get scanProblemCause;

  /// No description provided for @scanProblemSolution.
  ///
  /// In uz, this message translates to:
  /// **'Yechimi'**
  String get scanProblemSolution;

  /// No description provided for @cosmoHeading.
  ///
  /// In uz, this message translates to:
  /// **'Kosmetologlar'**
  String get cosmoHeading;

  /// No description provided for @cosmoExperience.
  ///
  /// In uz, this message translates to:
  /// **'Tajriba'**
  String get cosmoExperience;

  /// No description provided for @cosmoAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil'**
  String get cosmoAddress;

  /// No description provided for @cosmoAbout.
  ///
  /// In uz, this message translates to:
  /// **'Mutaxassis haqida'**
  String get cosmoAbout;

  /// No description provided for @cosmoSpecialties.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'nalishlari'**
  String get cosmoSpecialties;

  /// No description provided for @cosmoFilterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get cosmoFilterAll;

  /// No description provided for @cosmoFilterFacialist.
  ///
  /// In uz, this message translates to:
  /// **'Facialist'**
  String get cosmoFilterFacialist;

  /// No description provided for @cosmoFilterDermatologist.
  ///
  /// In uz, this message translates to:
  /// **'Dermatolog'**
  String get cosmoFilterDermatologist;

  /// No description provided for @cosmoFilterAesthetician.
  ///
  /// In uz, this message translates to:
  /// **'Estetik'**
  String get cosmoFilterAesthetician;

  /// No description provided for @cosmoFilterInjection.
  ///
  /// In uz, this message translates to:
  /// **'Injeksion'**
  String get cosmoFilterInjection;

  /// No description provided for @cosmoPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get cosmoPhone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
