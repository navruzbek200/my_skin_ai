// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'My Skin AI';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Parol';

  @override
  String get commonContinue => 'Davom etish';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get commonSkip => 'O\'tkazib yuborish';

  @override
  String get commonSettings => 'Sozlamalar';

  @override
  String get commonDelete => 'O\'chirish';

  @override
  String get commonAllow => 'Ruxsat berish';

  @override
  String get commonPrivacyPolicy => 'Maxfiylik siyosati';

  @override
  String get languageTitle => 'Til';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get introTitle => 'Sog\'lom teri —\nchiroyli hayot';

  @override
  String get introSubtitle =>
      'Shaxsiy teri tahlili va koreyacha parvarish tavsiyalari';

  @override
  String get introStart => 'Boshlash';

  @override
  String get introChooseLanguage => 'Tilni tanlang';

  @override
  String get authWelcome => 'Xush kelibsiz';

  @override
  String get authWelcomeBack => 'Qaytganingizdan xursandmiz';

  @override
  String get authSubtitle =>
      'Email va parol kiriting — hisob bo\'lmasa, biz uni o\'zimiz ochamiz.';

  @override
  String get authSubtitleReturning =>
      'Avvalgi hisobingizga kiring va parvarish rejangizni davom ettiring.';

  @override
  String get authContinue => 'Davom etish';

  @override
  String get authForgotPassword => 'Parolni unutdingizmi?';

  @override
  String get authOr => 'yoki';

  @override
  String get authGoogleButton => 'Google bilan kirish';

  @override
  String get authAppleButton => 'Apple bilan kirish';

  @override
  String get authPasswordHelper => 'Kamida 6 belgi';

  @override
  String get authShowPassword => 'Parolni ko\'rsatish';

  @override
  String get authHidePassword => 'Parolni yashirish';

  @override
  String get authEmailRequired => 'Email kiriting';

  @override
  String get authEmailInvalid => 'Haqiqiy email kiriting';

  @override
  String get authPasswordRequired => 'Parol kiriting';

  @override
  String get authPasswordTooShort =>
      'Parol kamida 6 belgidan iborat bo\'lishi kerak';

  @override
  String get authTermsNote =>
      'Davom etish orqali siz shartlarimizga rozilik bildirasiz';

  @override
  String authResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Qayta yuborish — $seconds s',
    );
    return '$_temp0';
  }

  @override
  String get authErrorGeneric => 'Xato yuz berdi. Qaytadan urinib ko\'ring';

  @override
  String get authErrorTimeout =>
      'Javob kelmadi. Internetni tekshirib, qayta urinib ko\'ring';

  @override
  String get authErrorUserNotFound => 'Bunday email topilmadi';

  @override
  String get authErrorWrongPassword => 'Parol noto\'g\'ri';

  @override
  String get authErrorWrongPasswordOrGoogle =>
      'Parol noto\'g\'ri. Agar Google orqali ro\'yxatdan o\'tgan bo\'lsangiz, pastdagi Google tugmasi bilan kiring';

  @override
  String get authErrorEmailInUse => 'Bu email allaqachon ro\'yxatdan o\'tgan';

  @override
  String get authErrorInvalidEmail => 'Email format noto\'g\'ri';

  @override
  String get authErrorNetwork => 'Internet aloqasi yo\'q';

  @override
  String get authErrorTooManyRequests =>
      'Ko\'p urinish. Biroz kutib qaytib keling';

  @override
  String get authErrorRequiresRecentLogin => 'Xavfsizlik uchun qaytadan kiring';

  @override
  String get authErrorSessionExpired =>
      'Sessiya tugadi. Ilovaga qaytadan kiring';

  @override
  String get authErrorGoogle => 'Google orqali kirishda xato yuz berdi';

  @override
  String get authErrorApple => 'Apple orqali kirishda xato yuz berdi';

  @override
  String get authErrorAccountExists =>
      'Bu email boshqa usul bilan ro\'yxatdan o\'tgan. Avvalgi usulingiz bilan kiring.';

  @override
  String get authErrorPasswordRequired => 'Parolni kiriting';

  @override
  String get authErrorNotVerifiedYet =>
      'Hali tasdiqlanmagan. Xatingizdagi havolani bosing';

  @override
  String get authErrorDisposableEmail =>
      'Vaqtinchalik email qabul qilinmaydi. Doimiy manzilingizni kiriting';

  @override
  String get authErrorEmailTypo =>
      'Email manzilida xatolik bordek. Tekshirib ko\'ring';

  @override
  String get authErrorEmailUnreachable =>
      'Bunday email domeni mavjud emas. Manzilni tekshiring';

  @override
  String get authConfirmTitle => 'Manzil to\'g\'rimi?';

  @override
  String get authConfirmBody =>
      'Tasdiqlash havolasi shu manzilga keladi. Bitta harf xato bo\'lsa, xat yetib bormaydi: akkauntga ham kira olmaysiz, parolni ham tiklay olmaysiz.';

  @override
  String get authConfirmEdit => 'To\'g\'rilash';

  @override
  String get authConfirmSend => 'Ha, bu meniki';

  @override
  String get authInfoResetSent =>
      'Parolni tiklash havolasi yuborildi (spam papkasini ham tekshiring)';

  @override
  String get authInfoVerificationSent =>
      'Tasdiqlash havolasi yuborildi (spam papkasini ham tekshiring)';

  @override
  String get authInfoProfileUpdated => 'Saqlandi';

  @override
  String get authInfoEmailVerified => 'Email tasdiqlandi';

  @override
  String get verifyTitle => 'Emailingizni tasdiqlang';

  @override
  String verifyBody(String email) {
    return '$email manziliga tasdiqlash havolasi yubordik. Xatni oching va havolani bosing.';
  }

  @override
  String get verifyHint =>
      'Xat kelmadimi? Spam papkasini ham tekshiring — bir necha daqiqa ketishi mumkin.';

  @override
  String get verifyCheck => 'Tasdiqladim, tekshirish';

  @override
  String get verifyResend => 'Havolani qayta yuborish';

  @override
  String get verifyWhy =>
      'Parolni unutsangiz, tiklash havolasi faqat tasdiqlangan manzilga yuboriladi. Shuning uchun bu qadam bir marta talab qilinadi.';

  @override
  String get verifyUseAnother => 'Boshqa email bilan boshlash';

  @override
  String get verifyStartOverTitle => 'Boshqa email bilan boshlansinmi?';

  @override
  String get verifyStartOverBody =>
      'Bu hisob o\'chiriladi va siz yangi email bilan ro\'yxatdan o\'tasiz. Teri profilingiz va tahlil tarixingiz qurilmada qoladi.';

  @override
  String get verifyStartOverConfirm => 'Ha, boshqasini kiritaman';

  @override
  String get forgotTitle => 'Parolni tiklash';

  @override
  String get forgotSubtitle =>
      'Email manzilingizni kiriting,\nbiz sizga tiklash havolasini yuboramiz';

  @override
  String get forgotSend => 'Havolani yuborish';

  @override
  String get forgotSentTitle => 'Havola yuborildi!';

  @override
  String get forgotSentBody =>
      'Email manzilingizni tekshiring (spam papkasini ham ko\'ring) va havola orqali yangi parol o\'rnating';

  @override
  String get forgotBackToSignIn => 'Kirish sahifasiga qaytish';

  @override
  String get accountTitle => 'Hisob';

  @override
  String get accountDefaultName => 'My Skin AI foydalanuvchisi';

  @override
  String get accountSkinProfile => 'Teri profili';

  @override
  String get accountRetakeAnalysis => 'Tahlilni qayta o\'tkazish';

  @override
  String get accountNotAnalysed => 'Hali tahlil qilinmagan';

  @override
  String get accountStartAnalysis => 'Tahlilni boshlash';

  @override
  String get accountLanguage => 'Til';

  @override
  String get accountEmailUnverified => 'Email tasdiqlanmagan';

  @override
  String get accountEmailUnverifiedBody =>
      'Parolni unutsangiz, tiklash havolasi faqat tasdiqlangan manzilga yuboriladi.';

  @override
  String get accountSendLink => 'Havolani yuborish';

  @override
  String get accountResendLink => 'Havolani qayta yuborish';

  @override
  String get accountSignOut => 'Chiqish';

  @override
  String get accountSignOutTitle => 'Chiqasizmi?';

  @override
  String get accountSignOutBody => 'Hisobdan chiqishni tasdiqlaysizmi?';

  @override
  String get accountDeleteAccount => 'Akkauntni o\'chirish';

  @override
  String get accountDeleteBody =>
      'Akkaunt butunlay o\'chiriladi. Davom etasizmi?';

  @override
  String get accountDeletedNotice =>
      'Akkaunt o\'chirildi — qurilmadagi ma\'lumotlar tozalandi';

  @override
  String get accountNoEmail => 'Bu hisobda email yo\'q';

  @override
  String get accountConfirmIdentity => 'Kimligingizni tasdiqlang';

  @override
  String get accountConfirmPasswordBody =>
      'Akkauntni o\'chirish uchun parolingizni kiriting.';

  @override
  String get accountConfirmGoogleBody =>
      'Akkauntni o\'chirish uchun Google hisobingiz orqali tasdiqlang.';

  @override
  String get accountConfirmAppleBody =>
      'Akkauntni o\'chirish uchun Apple hisobingiz orqali tasdiqlang.';

  @override
  String accountResetSentBody(String email) {
    return 'Tiklash havolasi $email manziliga yuborildi (spam papkasini ham tekshiring). Brauzerda yangi parol o\'rnating, so\'ng shu yerga qaytib uni kiriting.';
  }

  @override
  String get accountNewPassword => 'Yangi parol';

  @override
  String get accountConfirmDelete => 'Tasdiqlab o\'chirish';

  @override
  String get accountConfirmDeleteGoogle => 'Google bilan tasdiqlab o\'chirish';

  @override
  String get accountConfirmDeleteApple => 'Apple bilan tasdiqlab o\'chirish';

  @override
  String accountVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String get navToday => 'Bugun';

  @override
  String get navProducts => 'Mahsulot';

  @override
  String get navScan => 'Tahlil';

  @override
  String get navLessons => 'Darslar';

  @override
  String get navCosmetologist => 'Kosmetolog';

  @override
  String homeTasksProgress(int done, int total) {
    return '$done / $total vazifa';
  }

  @override
  String get homeStartAnalysisTitle => 'Teri tahlilini boshlang';

  @override
  String get homeStartAnalysisBody =>
      'Shaxsiy parvarish dasturingizni olish uchun qisqa tahlil o\'ting.';

  @override
  String homeStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days kun',
    );
    return '$_temp0';
  }

  @override
  String get homeStreakLabel => 'Ketma-ket parvarish';

  @override
  String get homeAllDone => 'Hammasi bajarildi!';

  @override
  String get homeGoal => 'Parvarish maqsadi';

  @override
  String get homeMorning => 'Ertalab';

  @override
  String get homeEvening => 'Kechqurun';

  @override
  String get promoTitle => 'Teringizni tahlil qiling';

  @override
  String get promoBody =>
      'Teri tipingizni aniqlash uchun qisqa savolnomaga javob bering va shaxsiylashtirilgan parvarish rejasini oling.';

  @override
  String get promoStart => 'Tahlilni boshlash';

  @override
  String get quizTitle => 'Teri Tahlili';

  @override
  String quizQuestionNumber(int number) {
    return 'Savol $number';
  }

  @override
  String get quizSelectOne => 'Iltimos, bitta javobni tanlang';

  @override
  String get quizWriteAnswer => 'Javobingizni yozing';

  @override
  String get quizWriteHere => 'Bu yerga yozing...';

  @override
  String get quizExitTitle => 'Chiqasizmi?';

  @override
  String get quizExitBody => 'Javoblaringiz saqlanmaydi.';

  @override
  String get quizPrivacyTitle => 'Ma\'lumotlar va maxfiylik';

  @override
  String get quizPrivacyBody =>
      'Savolnoma javoblaringiz faqat qurilmangizda mahalliy saqlanadi va hech qachon internetga yuborilmaydi.\n\nKamera ishlatiladigan bosqichda tasvirlar faqat qurilma ichida qayta ishlanadi — hech narsa saqlanmaydi yoki yuborilmaydi.\n\nTahlil natijasi savolnoma javoblaringiz asosida hisoblanadi.';

  @override
  String get quizAccept => 'Qabul qilaman';

  @override
  String get analysisTitle => 'Tahlil qilinmoqda...';

  @override
  String get analysisSubtitle => 'Savollaringiz asosida tahlil qilinmoqda';

  @override
  String get analysisStep1 => 'Savollar tahlil qilinmoqda';

  @override
  String get analysisStep2 => 'Teri turi aniqlanmoqda';

  @override
  String get analysisStep3 => 'Muammolar baholanmoqda';

  @override
  String get analysisStep4 => 'Natijalar tayyorlanmoqda';

  @override
  String get resultsTitle => 'Teri tahlili tayyor!';

  @override
  String get resultsSkinType => 'Teri tipingiz';

  @override
  String resultsSkinTypeValue(String type) {
    return '$type teri';
  }

  @override
  String resultsMoreAdvice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count tavsiya',
    );
    return '$_temp0';
  }

  @override
  String get resultsMainAdvice => 'Asosiy tavsiya';

  @override
  String get resultsExtraAdvice => 'Qo\'shimcha tavsiyalar';

  @override
  String get resultsDisclaimer =>
      'Bu kosmetik tahlil tibbiy tashxis hisoblanmaydi. Teri muammolari bo\'lsa mutaxassisga murojaat qiling.';

  @override
  String get resultsStart => 'Dasturni boshlash';

  @override
  String get scanInstructionsTitle => 'Skanerlash yo\'riqnomasi';

  @override
  String get scanTipGlasses => 'Ko\'zoynakni yeching';

  @override
  String get scanTipGlassesSub => 'Va yorug\' joy toping';

  @override
  String get scanTipHead => 'Boshingizni tik tuting';

  @override
  String get scanTipHeadSub => 'Va Boshlash tugmasini bosing';

  @override
  String get scanTipLook => 'To\'g\'ri va frontal qarang';

  @override
  String get scanTipLookSub => 'Avtomatik suratga olinadi';

  @override
  String get scanStartTitle => 'Teri tahlilini boshlang';

  @override
  String get scanStartBody => 'Savolnoma orqali teri tipingizni aniqlang';

  @override
  String get scanStartCta => 'Teri tahlilini boshlash';

  @override
  String get scanStartHint => 'Bir necha daqiqa vaqt ajrating';

  @override
  String get scanFirstSaved => 'Birinchi skaningiz saqlandi';

  @override
  String get scanFirstSavedBody =>
      'O\'zgarishni ko\'rish uchun yana skan qiling';

  @override
  String get scanComparison => 'So\'nggi va oldingi skan';

  @override
  String get scanLatest => 'So\'nggi';

  @override
  String scanSkinTypeValue(String type) {
    return '$type teri';
  }

  @override
  String get scanAiNote => 'AI tahlili — tibbiy tashxis emas';

  @override
  String get scanProblems => 'Teri muammolari';

  @override
  String get scanCauses => 'Sabablari va yechimlari';

  @override
  String get faceScanAlign => 'Yuzingizni ramkaga olib keling';

  @override
  String get faceScanHold => 'Yuzingizni tutib turing';

  @override
  String get faceScanStep1 => 'Savolnoma javoblari qayta ishlanmoqda';

  @override
  String get faceScanStep2 => 'Teri tipi aniqlanmoqda';

  @override
  String get faceScanStep3 => 'Tavsiyalar shakllantirilmoqda';

  @override
  String get faceScanStep4 => 'Natija tayyorlanmoqda';

  @override
  String get faceScanPreparingResult => 'Natija tayyorlanmoqda...';

  @override
  String get faceScanPreparingCamera => 'Kamera tayyorlanmoqda';

  @override
  String get faceScanPermissionTitle => 'Kamera ruxsati kerak';

  @override
  String get faceScanPermissionBody =>
      'Yuzingizni to\'g\'ri joylashtirish uchun old kamera kerak. Tahlil natijasi savolnoma javoblaringiz asosida tayyorlanadi.';

  @override
  String get faceScanPermissionDeniedTitle => 'Kamera ruxsati o\'chirilgan';

  @override
  String get faceScanPermissionDeniedBody =>
      'Yuzingizni joylashtirish uchun Sozlamalardan \"Kamera\" ruxsatini yoqing (ixtiyoriy).';

  @override
  String get faceScanContinueWithQuiz => 'Anketa bilan davom etish';

  @override
  String get faceScanNoCameraTitle => 'Kamera topilmadi';

  @override
  String get faceScanNoCameraBody =>
      'Qurilmangizda kamera ishlamayapti. Anketa asosida davom etish mumkin.';

  @override
  String get faceScanTooDark => 'Yorug\'roq joyga o\'ting';

  @override
  String get faceScanOneFace => 'Bitta yuz ko\'rsating';

  @override
  String get faceScanCloser => 'Yaqinroq keling';

  @override
  String get faceScanFurther => 'Sal uzoqlashing';

  @override
  String get faceScanCenter => 'Yuzni markazga oling';

  @override
  String get faceScanLookStraight => 'To\'g\'ri qarang';

  @override
  String get faceScanOpenEyes => 'Ko\'zingizni oching';

  @override
  String get faceScanTimeoutTitle => 'Vaqt tugadi';

  @override
  String get faceScanTimeoutBody => 'Qayta urinasizmi yoki davom etasizmi?';

  @override
  String get faceScanHowTitle => 'Qanday ishlaydi?';

  @override
  String get faceScanHowBody =>
      '• Yuzingizni oval ichiga joylang\n• To\'g\'ri va frontal qarang\n• Ko\'zingizni oching\n• Yaxshi yorug\'lik bo\'lsin\n• Skaner avtomatik boshlanadi';

  @override
  String get faceScanDisclaimer =>
      'Bu kosmetik tahlil bo\'lib, tibbiy tashxis hisoblanmaydi.';

  @override
  String get productsTitle => 'Koreya brend\nmahsulotlar';

  @override
  String get productsEmpty => 'Mahsulot topilmadi';

  @override
  String get productsBenefits => 'Foydali tomonlari';

  @override
  String get productsError => 'Mahsulotlarni yuklashda xato';

  @override
  String get lessonBadge => 'Maqola';

  @override
  String get lessonsSubtitle => 'Yuz yogasi, ingrediyentlar va maqolalar';

  @override
  String get lessonsYoga => 'Yuz Yoga';

  @override
  String get lessonsYogaExercises => 'Yoga mashqlari';

  @override
  String lessonsExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta mashq',
    );
    return '$_temp0';
  }

  @override
  String lessonStepOf(int current, int total) {
    return '$current / $total qadam';
  }

  @override
  String lessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count qadam',
    );
    return '$_temp0';
  }

  @override
  String get lessonFinish => 'Darsni tugatish ✓';

  @override
  String get lessonNext => 'Keyingi →';

  @override
  String lessonReadTime(String duration) {
    return 'O\'qish uchun $duration';
  }

  @override
  String get lessonPlayPause => 'Videoni ijro etish yoki to\'xtatish';

  @override
  String get cosmoSearchHint => 'Kosmetolog qidirish...';

  @override
  String cosmoNoSearchResults(String query) {
    return '\"$query\" bo\'yicha hech narsa topilmadi';
  }

  @override
  String cosmoNoFilterResults(String filter) {
    return '$filter bo\'yicha kosmetolog topilmadi';
  }

  @override
  String get cosmoTryOther => 'Boshqa kalit so\'z yoki filtr sinab ko\'ring';

  @override
  String cosmoYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yil',
    );
    return '$_temp0';
  }

  @override
  String cosmoYearsExperience(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years yillik tajriba',
    );
    return '$_temp0';
  }

  @override
  String get cosmoCallFailed => 'Ilovani ochib bo\'lmadi';

  @override
  String get cosmoError => 'Kosmetologlarni yuklashda xato';

  @override
  String get routineError => 'Rejani tuzishda xato yuz berdi';

  @override
  String get productsHeading => 'Mahsulotlar';

  @override
  String productsPrice(String amount) {
    return '$amount so\'m';
  }

  @override
  String get productsPriceOnRequest => 'Narxi so\'rov bo\'yicha';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta mahsulot',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterAll => 'Barchasi';

  @override
  String get productsEmptyBody =>
      'Bu bo\'limda hozircha mahsulot yo\'q. Boshqa turkumni tanlang.';

  @override
  String get productsErrorBody =>
      'Internetni tekshirib, qaytadan urinib ko\'ring.';

  @override
  String get forgotWhyTitle => 'Nima bo\'ladi?';

  @override
  String get forgotStep1 => 'Emailingizga havola yuboramiz';

  @override
  String get forgotStep2 => 'Havolani bosib, yangi parol o\'rnatasiz';

  @override
  String get forgotStep3 => 'Yangi parol bilan ilovaga kirasiz';

  @override
  String get forgotNoEmailHint =>
      'Xat kelmadimi? Spam papkasini tekshiring yoki bir necha daqiqa kuting.';

  @override
  String get forgotGoogleHint =>
      'Google orqali kirgan bo\'lsangiz, parolingiz yo\'q — kirish sahifasidagi Google tugmasidan foydalaning.';

  @override
  String get forgotResend => 'Qayta yuborish';

  @override
  String forgotSentTo(String email) {
    return 'Havola $email manziliga yuborildi';
  }

  @override
  String get commonBack => 'Ortga';

  @override
  String get commonClose => 'Yopish';

  @override
  String get commonDone => 'Tayyor';

  @override
  String get commonRetryShort => 'Qayta';

  @override
  String get commonSettingsApp => 'Sozlamalar';

  @override
  String get lessonsHeading => 'Darslar';

  @override
  String get lessonsIngredients => 'Ingrediyentlar';

  @override
  String get lessonsArticles => 'Maqolalar';

  @override
  String get scanResultsHeading => 'Natijalar';

  @override
  String get scanPrevious => 'Oldingi';

  @override
  String get scanProblemCause => 'Sababi';

  @override
  String get scanProblemSolution => 'Yechimi';

  @override
  String get cosmoHeading => 'Kosmetologlar';

  @override
  String get cosmoExperience => 'Tajriba';

  @override
  String get cosmoAddress => 'Manzil';

  @override
  String get cosmoAbout => 'Mutaxassis haqida';

  @override
  String get cosmoSpecialties => 'Yo\'nalishlari';

  @override
  String get cosmoFilterAll => 'Barchasi';

  @override
  String get cosmoFilterFacialist => 'Facialist';

  @override
  String get cosmoFilterDermatologist => 'Dermatolog';

  @override
  String get cosmoFilterAesthetician => 'Estetik';

  @override
  String get cosmoFilterInjection => 'Injeksion';

  @override
  String get cosmoPhone => 'Telefon';
}
