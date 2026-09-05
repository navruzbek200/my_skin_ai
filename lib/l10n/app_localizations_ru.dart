// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'My Skin AI';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Пароль';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonSettings => 'Настройки';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonAllow => 'Разрешить';

  @override
  String get commonPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageUz => 'O\'zbekcha';

  @override
  String get languageRu => 'Русский';

  @override
  String get languageEn => 'English';

  @override
  String get introTitle => 'Здоровая кожа —\nкрасивая жизнь';

  @override
  String get introSubtitle =>
      'Персональный анализ кожи и корейские рекомендации по уходу';

  @override
  String get introStart => 'Начать';

  @override
  String get introChooseLanguage => 'Выберите язык';

  @override
  String get authWelcome => 'Добро пожаловать';

  @override
  String get authWelcomeBack => 'Рады видеть вас снова';

  @override
  String get authSubtitle =>
      'Введите email и пароль — если аккаунта нет, мы создадим его сами.';

  @override
  String get authSubtitleReturning =>
      'Войдите в свой аккаунт и продолжите программу ухода.';

  @override
  String get authContinue => 'Продолжить';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authOr => 'или';

  @override
  String get authGoogleButton => 'Войти через Google';

  @override
  String get authAppleButton => 'Войти через Apple';

  @override
  String get authPasswordHelper => 'Минимум 6 символов';

  @override
  String get authShowPassword => 'Показать пароль';

  @override
  String get authHidePassword => 'Скрыть пароль';

  @override
  String get authEmailRequired => 'Введите email';

  @override
  String get authEmailInvalid => 'Введите настоящий email';

  @override
  String get authPasswordRequired => 'Введите пароль';

  @override
  String get authPasswordTooShort => 'Пароль должен быть не короче 6 символов';

  @override
  String get authTermsNote => 'Продолжая, вы соглашаетесь с нашими условиями';

  @override
  String authResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Отправить снова — $seconds с',
      one: 'Отправить снова — $seconds с',
    );
    return '$_temp0';
  }

  @override
  String get authErrorGeneric => 'Произошла ошибка. Попробуйте ещё раз';

  @override
  String get authErrorTimeout =>
      'Ответ не пришёл. Проверьте интернет и повторите';

  @override
  String get authErrorUserNotFound => 'Такой email не найден';

  @override
  String get authErrorWrongPassword => 'Неверный пароль';

  @override
  String get authErrorWrongPasswordOrGoogle =>
      'Неверный пароль. Если вы регистрировались через Google, войдите кнопкой Google ниже';

  @override
  String get authErrorEmailInUse => 'Этот email уже зарегистрирован';

  @override
  String get authErrorInvalidEmail => 'Неверный формат email';

  @override
  String get authErrorNetwork => 'Нет интернет-соединения';

  @override
  String get authErrorTooManyRequests =>
      'Слишком много попыток. Подождите немного';

  @override
  String get authErrorRequiresRecentLogin =>
      'В целях безопасности войдите заново';

  @override
  String get authErrorSessionExpired =>
      'Сессия истекла. Войдите в приложение заново';

  @override
  String get authErrorGoogle => 'Ошибка входа через Google';

  @override
  String get authErrorApple => 'Ошибка входа через Apple';

  @override
  String get authErrorAccountExists =>
      'Этот email уже зарегистрирован другим способом. Войдите тем же способом, что и раньше.';

  @override
  String get authErrorPasswordRequired => 'Введите пароль';

  @override
  String get authErrorNotVerifiedYet =>
      'Пока не подтверждено. Откройте ссылку из письма';

  @override
  String get authErrorDisposableEmail =>
      'Временные почты не принимаются. Укажите постоянный адрес';

  @override
  String get authErrorEmailTypo => 'Похоже, в адресе опечатка. Проверьте его';

  @override
  String get authErrorEmailUnreachable =>
      'Такого почтового домена не существует. Проверьте адрес';

  @override
  String get authConfirmTitle => 'Адрес верный?';

  @override
  String get authConfirmBody =>
      'Ссылка для подтверждения придёт на этот адрес. Одна неверная буква — и письмо не дойдёт: в аккаунт не войти и пароль не восстановить.';

  @override
  String get authConfirmEdit => 'Исправить';

  @override
  String get authConfirmSend => 'Да, это мой';

  @override
  String get authInfoResetSent =>
      'Ссылка для сброса пароля отправлена (проверьте и папку «Спам»)';

  @override
  String get authInfoVerificationSent =>
      'Ссылка для подтверждения отправлена (проверьте и папку «Спам»)';

  @override
  String get authInfoProfileUpdated => 'Сохранено';

  @override
  String get authInfoEmailVerified => 'Email подтверждён';

  @override
  String get verifyTitle => 'Подтвердите email';

  @override
  String verifyBody(String email) {
    return 'Мы отправили ссылку для подтверждения на $email. Откройте письмо и перейдите по ссылке.';
  }

  @override
  String get verifyHint =>
      'Письмо не пришло? Проверьте папку «Спам» — доставка может занять несколько минут.';

  @override
  String get verifyCheck => 'Я подтвердил, проверить';

  @override
  String get verifyResend => 'Отправить ссылку снова';

  @override
  String get verifyWhy =>
      'Если вы забудете пароль, ссылка для восстановления придёт только на подтверждённый адрес. Поэтому этот шаг нужен один раз.';

  @override
  String get verifyUseAnother => 'Начать с другого email';

  @override
  String get verifyStartOverTitle => 'Начать с другого email?';

  @override
  String get verifyStartOverBody =>
      'Этот аккаунт будет удалён, и вы зарегистрируетесь с новым email. Профиль кожи и история анализов останутся на устройстве.';

  @override
  String get verifyStartOverConfirm => 'Да, введу другой';

  @override
  String get forgotTitle => 'Сброс пароля';

  @override
  String get forgotSubtitle =>
      'Введите свой email,\nи мы пришлём ссылку для восстановления';

  @override
  String get forgotSend => 'Отправить ссылку';

  @override
  String get forgotSentTitle => 'Ссылка отправлена!';

  @override
  String get forgotSentBody =>
      'Проверьте почту (и папку «Спам») и задайте новый пароль по ссылке';

  @override
  String get forgotBackToSignIn => 'Вернуться ко входу';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get accountDefaultName => 'Пользователь My Skin AI';

  @override
  String get accountSkinProfile => 'Профиль кожи';

  @override
  String get accountRetakeAnalysis => 'Пройти анализ заново';

  @override
  String get accountNotAnalysed => 'Анализ ещё не пройден';

  @override
  String get accountStartAnalysis => 'Начать анализ';

  @override
  String get accountLanguage => 'Язык';

  @override
  String get accountEmailUnverified => 'Email не подтверждён';

  @override
  String get accountEmailUnverifiedBody =>
      'Если вы забудете пароль, ссылка для восстановления придёт только на подтверждённый адрес.';

  @override
  String get accountSendLink => 'Отправить ссылку';

  @override
  String get accountResendLink => 'Отправить ссылку снова';

  @override
  String get accountSignOut => 'Выйти';

  @override
  String get accountSignOutTitle => 'Выйти?';

  @override
  String get accountSignOutBody => 'Подтвердить выход из аккаунта?';

  @override
  String get accountDeleteAccount => 'Удалить аккаунт';

  @override
  String get accountDeleteBody => 'Аккаунт будет удалён навсегда. Продолжить?';

  @override
  String get accountDeletedNotice =>
      'Аккаунт удалён — данные на устройстве очищены';

  @override
  String get accountNoEmail => 'У этого аккаунта нет email';

  @override
  String get accountConfirmIdentity => 'Подтвердите личность';

  @override
  String get accountConfirmPasswordBody =>
      'Введите пароль, чтобы удалить аккаунт.';

  @override
  String get accountConfirmGoogleBody =>
      'Подтвердите через аккаунт Google, чтобы удалить аккаунт.';

  @override
  String get accountConfirmAppleBody =>
      'Подтвердите через аккаунт Apple, чтобы удалить аккаунт.';

  @override
  String accountResetSentBody(String email) {
    return 'Ссылка для сброса отправлена на $email (проверьте и папку «Спам»). Задайте новый пароль в браузере, затем вернитесь сюда и введите его.';
  }

  @override
  String get accountNewPassword => 'Новый пароль';

  @override
  String get accountConfirmDelete => 'Подтвердить и удалить';

  @override
  String get accountConfirmDeleteGoogle => 'Подтвердить через Google и удалить';

  @override
  String get accountConfirmDeleteApple => 'Подтвердить через Apple и удалить';

  @override
  String accountVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get navToday => 'Сегодня';

  @override
  String get navProducts => 'Товары';

  @override
  String get navScan => 'Анализ';

  @override
  String get navLessons => 'Уроки';

  @override
  String get navCosmetologist => 'Косметолог';

  @override
  String homeTasksProgress(int done, int total) {
    return '$done / $total задач';
  }

  @override
  String get homeStartAnalysisTitle => 'Начните анализ кожи';

  @override
  String get homeStartAnalysisBody =>
      'Пройдите короткий анализ, чтобы получить персональную программу ухода.';

  @override
  String homeStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дней',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String get homeStreakLabel => 'Дней подряд';

  @override
  String get homeAllDone => 'Всё выполнено!';

  @override
  String get homeGoal => 'Цель ухода';

  @override
  String get homeMorning => 'Утро';

  @override
  String get homeEvening => 'Вечер';

  @override
  String get promoTitle => 'Проанализируйте свою кожу';

  @override
  String get promoBody =>
      'Ответьте на короткую анкету, чтобы определить тип кожи и получить персональный план ухода.';

  @override
  String get promoStart => 'Начать анализ';

  @override
  String get quizTitle => 'Анализ кожи';

  @override
  String quizQuestionNumber(int number) {
    return 'Вопрос $number';
  }

  @override
  String get quizSelectOne => 'Пожалуйста, выберите один вариант';

  @override
  String get quizWriteAnswer => 'Напишите свой ответ';

  @override
  String get quizWriteHere => 'Пишите здесь...';

  @override
  String get quizExitTitle => 'Выйти?';

  @override
  String get quizExitBody => 'Ваши ответы не сохранятся.';

  @override
  String get quizPrivacyTitle => 'Данные и конфиденциальность';

  @override
  String get quizPrivacyBody =>
      'Ответы анкеты хранятся только на вашем устройстве и никогда не отправляются в интернет.\n\nНа этапе с камерой изображения обрабатываются только внутри устройства — ничего не сохраняется и не отправляется.\n\nРезультат анализа рассчитывается по вашим ответам.';

  @override
  String get quizAccept => 'Принимаю';

  @override
  String get analysisTitle => 'Идёт анализ...';

  @override
  String get analysisSubtitle => 'Анализируем ваши ответы';

  @override
  String get analysisStep1 => 'Обрабатываем ответы';

  @override
  String get analysisStep2 => 'Определяем тип кожи';

  @override
  String get analysisStep3 => 'Оцениваем проблемы';

  @override
  String get analysisStep4 => 'Готовим результаты';

  @override
  String get resultsTitle => 'Анализ кожи готов!';

  @override
  String get resultsSkinType => 'Ваш тип кожи';

  @override
  String resultsSkinTypeValue(String type) {
    return '$type кожа';
  }

  @override
  String resultsMoreAdvice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count советов',
      many: '+$count советов',
      few: '+$count совета',
      one: '+$count совет',
    );
    return '$_temp0';
  }

  @override
  String get resultsMainAdvice => 'Основная рекомендация';

  @override
  String get resultsExtraAdvice => 'Дополнительные рекомендации';

  @override
  String get resultsDisclaimer =>
      'Это косметический анализ, а не медицинский диагноз. При проблемах с кожей обратитесь к специалисту.';

  @override
  String get resultsStart => 'Начать программу';

  @override
  String get scanInstructionsTitle => 'Инструкция по сканированию';

  @override
  String get scanTipGlasses => 'Снимите очки';

  @override
  String get scanTipGlassesSub => 'И найдите светлое место';

  @override
  String get scanTipHead => 'Держите голову прямо';

  @override
  String get scanTipHeadSub => 'И нажмите «Начать»';

  @override
  String get scanTipLook => 'Смотрите прямо в камеру';

  @override
  String get scanTipLookSub => 'Снимок сделается автоматически';

  @override
  String get scanStartTitle => 'Начните анализ кожи';

  @override
  String get scanStartBody => 'Определите тип кожи с помощью анкеты';

  @override
  String get scanStartCta => 'Начать анализ кожи';

  @override
  String get scanStartHint => 'Это займёт пару минут';

  @override
  String get scanFirstSaved => 'Ваш первый скан сохранён';

  @override
  String get scanFirstSavedBody =>
      'Сделайте ещё один скан, чтобы увидеть изменения';

  @override
  String get scanComparison => 'Последний и предыдущий скан';

  @override
  String get scanLatest => 'Последний';

  @override
  String scanSkinTypeValue(String type) {
    return '$type кожа';
  }

  @override
  String get scanAiNote => 'AI-анализ — не медицинский диагноз';

  @override
  String get scanProblems => 'Проблемы кожи';

  @override
  String get scanCauses => 'Причины и решения';

  @override
  String get faceScanAlign => 'Поместите лицо в рамку';

  @override
  String get faceScanHold => 'Не двигайтесь';

  @override
  String get faceScanStep1 => 'Обрабатываем ответы анкеты';

  @override
  String get faceScanStep2 => 'Определяем тип кожи';

  @override
  String get faceScanStep3 => 'Формируем рекомендации';

  @override
  String get faceScanStep4 => 'Готовим результат';

  @override
  String get faceScanPreparingResult => 'Готовим результат...';

  @override
  String get faceScanPreparingCamera => 'Камера готовится';

  @override
  String get faceScanPermissionTitle => 'Нужен доступ к камере';

  @override
  String get faceScanPermissionBody =>
      'Фронтальная камера нужна, чтобы правильно расположить лицо. Результат анализа строится по вашим ответам в анкете.';

  @override
  String get faceScanPermissionDeniedTitle => 'Доступ к камере отключён';

  @override
  String get faceScanPermissionDeniedBody =>
      'Включите разрешение «Камера» в Настройках, чтобы расположить лицо (необязательно).';

  @override
  String get faceScanContinueWithQuiz => 'Продолжить с анкетой';

  @override
  String get faceScanNoCameraTitle => 'Камера не найдена';

  @override
  String get faceScanNoCameraBody =>
      'Камера на устройстве недоступна. Можно продолжить по анкете.';

  @override
  String get faceScanTooDark => 'Перейдите в более светлое место';

  @override
  String get faceScanOneFace => 'Покажите одно лицо';

  @override
  String get faceScanCloser => 'Подойдите ближе';

  @override
  String get faceScanFurther => 'Немного отодвиньтесь';

  @override
  String get faceScanCenter => 'Расположите лицо по центру';

  @override
  String get faceScanLookStraight => 'Смотрите прямо';

  @override
  String get faceScanOpenEyes => 'Откройте глаза';

  @override
  String get faceScanTimeoutTitle => 'Время вышло';

  @override
  String get faceScanTimeoutBody => 'Попробуете снова или продолжите?';

  @override
  String get faceScanHowTitle => 'Как это работает?';

  @override
  String get faceScanHowBody =>
      '• Поместите лицо в овал\n• Смотрите прямо в камеру\n• Держите глаза открытыми\n• Обеспечьте хорошее освещение\n• Сканирование начнётся автоматически';

  @override
  String get faceScanDisclaimer =>
      'Это косметический анализ, а не медицинский диагноз.';

  @override
  String get productsTitle => 'Корейские\nбренды';

  @override
  String get productsEmpty => 'Товары не найдены';

  @override
  String get productsBenefits => 'Преимущества';

  @override
  String get productsError => 'Ошибка загрузки товаров';

  @override
  String get lessonBadge => 'Статья';

  @override
  String get lessonsSubtitle => 'Фейс-йога, ингредиенты и статьи';

  @override
  String get lessonsYoga => 'Фейс-йога';

  @override
  String get lessonsYogaExercises => 'Упражнения йоги';

  @override
  String lessonsExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count упражнений',
      many: '$count упражнений',
      few: '$count упражнения',
      one: '$count упражнение',
    );
    return '$_temp0';
  }

  @override
  String lessonStepOf(int current, int total) {
    return 'Шаг $current / $total';
  }

  @override
  String lessonStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шагов',
      many: '$count шагов',
      few: '$count шага',
      one: '$count шаг',
    );
    return '$_temp0';
  }

  @override
  String get lessonFinish => 'Завершить урок ✓';

  @override
  String get lessonNext => 'Далее →';

  @override
  String lessonReadTime(String duration) {
    return 'Чтение — $duration';
  }

  @override
  String get lessonPlayPause => 'Воспроизвести или остановить видео';

  @override
  String get cosmoSearchHint => 'Поиск косметолога...';

  @override
  String cosmoNoSearchResults(String query) {
    return 'По запросу «$query» ничего не найдено';
  }

  @override
  String cosmoNoFilterResults(String filter) {
    return 'Косметологи по фильтру «$filter» не найдены';
  }

  @override
  String get cosmoTryOther => 'Попробуйте другое слово или фильтр';

  @override
  String cosmoYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет',
      many: '$years лет',
      few: '$years года',
      one: '$years год',
    );
    return '$_temp0';
  }

  @override
  String cosmoYearsExperience(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Опыт $years лет',
      many: 'Опыт $years лет',
      few: 'Опыт $years года',
      one: 'Опыт $years год',
    );
    return '$_temp0';
  }

  @override
  String get cosmoCallFailed => 'Не удалось открыть приложение';

  @override
  String get cosmoError => 'Ошибка загрузки косметологов';

  @override
  String get routineError => 'Не удалось составить программу';

  @override
  String get productsHeading => 'Товары';

  @override
  String productsPrice(String amount) {
    return '$amount сум';
  }

  @override
  String get productsPriceOnRequest => 'Цена по запросу';

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      many: '$count товаров',
      few: '$count товара',
      one: '$count товар',
    );
    return '$_temp0';
  }

  @override
  String get productsFilterAll => 'Все';

  @override
  String get productsEmptyBody =>
      'В этом разделе пока нет товаров. Выберите другую категорию.';

  @override
  String get productsErrorBody => 'Проверьте интернет и попробуйте ещё раз.';

  @override
  String get forgotWhyTitle => 'Что дальше?';

  @override
  String get forgotStep1 => 'Мы отправим ссылку вам на email';

  @override
  String get forgotStep2 => 'По ссылке вы зададите новый пароль';

  @override
  String get forgotStep3 => 'Войдёте в приложение с новым паролем';

  @override
  String get forgotNoEmailHint =>
      'Письмо не пришло? Проверьте папку «Спам» или подождите пару минут.';

  @override
  String get forgotGoogleHint =>
      'Если вы входили через Google, пароля у вас нет — используйте кнопку Google на странице входа.';

  @override
  String get forgotResend => 'Отправить снова';

  @override
  String forgotSentTo(String email) {
    return 'Ссылка отправлена на $email';
  }

  @override
  String get commonBack => 'Назад';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonRetryShort => 'Ещё раз';

  @override
  String get commonSettingsApp => 'Настройки';

  @override
  String get lessonsHeading => 'Уроки';

  @override
  String get lessonsIngredients => 'Ингредиенты';

  @override
  String get lessonsArticles => 'Статьи';

  @override
  String get scanResultsHeading => 'Результаты';

  @override
  String get scanPrevious => 'Предыдущий';

  @override
  String get scanProblemCause => 'Причина';

  @override
  String get scanProblemSolution => 'Решение';

  @override
  String get cosmoHeading => 'Косметологи';

  @override
  String get cosmoExperience => 'Опыт';

  @override
  String get cosmoAddress => 'Адрес';

  @override
  String get cosmoAbout => 'О специалисте';

  @override
  String get cosmoSpecialties => 'Направления';

  @override
  String get cosmoFilterAll => 'Все';

  @override
  String get cosmoFilterFacialist => 'Фациалист';

  @override
  String get cosmoFilterDermatologist => 'Дерматолог';

  @override
  String get cosmoFilterAesthetician => 'Эстетист';

  @override
  String get cosmoFilterInjection => 'Инъекционный';

  @override
  String get cosmoPhone => 'Телефон';
}
