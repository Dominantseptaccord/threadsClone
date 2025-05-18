class AppStrings {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settingsTitle': 'Settings',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'changePassword': 'Change Password',
      'signOut': 'Sign Out',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'russian': 'Russian',
      'kazakh': 'Kazakh',
      'passwordChanged': 'Password changed successfully',
    },
    'ru': {
      'settingsTitle': 'Настройки',
      'currentPassword': 'Текущий пароль',
      'newPassword': 'Новый пароль',
      'changePassword': 'Изменить пароль',
      'signOut': 'Выйти',
      'selectLanguage': 'Выберите язык',
      'english': 'Английский',
      'russian': 'Русский',
      'kazakh': 'Казахский',
      'passwordChanged': 'Пароль успешно изменён',
    },
    'kk': {
      'settingsTitle': 'Параметрлер',
      'currentPassword': 'Қазіргі құпия сөз',
      'newPassword': 'Жаңа құпия сөз',
      'changePassword': 'Құпия сөзді өзгерту',
      'signOut': 'Шығу',
      'selectLanguage': 'Тілді таңдаңыз',
      'english': 'Ағылшын',
      'russian': 'Орыс',
      'kazakh': 'Қазақша',
      'passwordChanged': 'Құпия сөз сәтті өзгертілді',
    },
  };

  final String currentLang;

  AppStrings(this.currentLang);

  String get settingsTitle => _localizedValues[currentLang]?['settingsTitle'] ?? '';
  String get currentPassword => _localizedValues[currentLang]?['currentPassword'] ?? '';
  String get newPassword => _localizedValues[currentLang]?['newPassword'] ?? '';
  String get changePassword => _localizedValues[currentLang]?['changePassword'] ?? '';
  String get signOut => _localizedValues[currentLang]?['signOut'] ?? '';
  String get selectLanguage => _localizedValues[currentLang]?['selectLanguage'] ?? '';
  String get english => _localizedValues[currentLang]?['english'] ?? '';
  String get russian => _localizedValues[currentLang]?['russian'] ?? '';
  String get kazakh => _localizedValues[currentLang]?['kazakh'] ?? '';
  String get passwordChanged => _localizedValues[currentLang]?['passwordChanged'] ?? '';
}
