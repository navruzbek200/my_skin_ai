/// What counts as an address this app will accept.
///
/// Confirming the address by mail is the real check — see `VerifyEmailScreen` —
/// but the mail costs a round trip and a wait, and three kinds of address fail
/// it in ways we can see coming from here: one that is malformed, one on a
/// throwaway inbox that expires before it could ever be used again, and one
/// with an obvious typo in a domain everybody uses. Catching those before
/// Firebase is asked turns a silent non-delivery into a sentence under the
/// field.
class EmailRules {
  const EmailRules._();

  /// Deliberately not "anything with an @ in it": Firebase accepts far more
  /// than a person can actually be reached at. The tail insists on a dotted
  /// domain with an alphabetic TLD of at least two letters, which is what rules
  /// out `a@b`, `a@b.` and `a@localhost`.
  static final RegExp _pattern =
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');

  /// The larger disposable services. Not a security boundary — there are
  /// thousands of these domains and new ones daily — but a speed bump that
  /// catches the ones people actually reach for when they want to skip a
  /// sign-up.
  static const Set<String> disposableDomains = {
    '0-mail.com',
    '10minutemail.com',
    '20minutemail.com',
    'anonbox.net',
    'burnermail.io',
    'dispostable.com',
    'dropmail.me',
    'emailondeck.com',
    'fakeinbox.com',
    'fakemail.net',
    'getairmail.com',
    'getnada.com',
    'guerrillamail.com',
    'inboxkitten.com',
    'mail.tm',
    'mail7.io',
    'maildrop.cc',
    'mailinator.com',
    'mailnesia.com',
    'mailsac.com',
    'minuteinbox.com',
    'moakt.com',
    'mohmal.com',
    'mytemp.email',
    'sharklasers.com',
    'spam4.me',
    'temp-mail.io',
    'temp-mail.org',
    'tempmail.com',
    'tempmail.dev',
    'tempmailo.com',
    'tempr.email',
    'throwawaymail.com',
    'trashmail.com',
    'tmpmail.org',
    'yopmail.com',
  };

  /// Misspellings of the handful of providers this audience actually uses,
  /// mapped to what was meant.
  ///
  /// A typo here is worse than a malformed address: it passes every format
  /// check, the account is created, and the confirmation mail bounces into a
  /// domain nobody owns. The person is then holding an account they can never
  /// confirm and never reset.
  static const Map<String, String> _typoDomains = {
    'gmial.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.cm': 'gmail.com',
    'gmaill.com': 'gmail.com',
    'gmail.om': 'gmail.com',
    'gnail.com': 'gmail.com',
    'gmail.ru': 'gmail.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.co': 'hotmail.com',
    'hotmail.con': 'hotmail.com',
    'outlok.com': 'outlook.com',
    'outlook.con': 'outlook.com',
    'yahooo.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'yahoo.con': 'yahoo.com',
    'yandex.ry': 'yandex.ru',
    'yandex.rru': 'yandex.ru',
    'yandx.ru': 'yandex.ru',
    'yndex.ru': 'yandex.ru',
    'mail.ry': 'mail.ru',
    'mai.ru': 'mail.ru',
    'mail.rru': 'mail.ru',
    'iclod.com': 'icloud.com',
    'icloud.co': 'icloud.com',
    'umail.uz': 'umail.uz',
  };

  /// Trimmed and lower-cased. Firebase folds addresses to lower case anyway, so
  /// normalising here keeps "Ali@..." and "ali@..." from looking like two
  /// different accounts anywhere in the app.
  static String normalise(String email) => email.trim().toLowerCase();

  static bool isWellFormed(String email) => _pattern.hasMatch(normalise(email));

  /// Everything after the last `@`, or an empty string when there is no `@`.
  static String domainOf(String email) {
    final address = normalise(email);
    final at = address.lastIndexOf('@');
    return at < 0 ? '' : address.substring(at + 1);
  }

  /// Matches subdomains too, which is how most of these services hand out
  /// addresses (`something.mailinator.com`).
  static bool isDisposable(String email) {
    final domain = domainOf(email);
    if (domain.isEmpty) return false;
    return disposableDomains.any((d) => domain == d || domain.endsWith('.$d'));
  }

  /// The address the user probably meant, or null when the domain looks fine.
  /// Never rewrites anything by itself — a domain that merely resembles a typo
  /// may well be someone's real employer, so the correction is offered, not
  /// applied.
  static String? suggestionFor(String email) {
    final address = normalise(email);
    final domain = domainOf(address);
    final fixed = _typoDomains[domain];
    if (fixed == null || fixed == domain) return null;
    return '${address.substring(0, address.lastIndexOf('@'))}@$fixed';
  }

  /// Domains that resolve to nothing at all. Kept separate from the typo map
  /// because there is no address to suggest — `.test`, `.example`, `.invalid`
  /// and `.localhost` are reserved by RFC 2606 and can never receive mail, and
  /// `example.com` is reserved by RFC 2606 for documentation.
  static bool isUnreachable(String email) {
    final domain = domainOf(email);
    if (domain.isEmpty) return false;
    const reservedTlds = {'test', 'example', 'invalid', 'localhost', 'local'};
    const reservedDomains = {'example.com', 'example.org', 'example.net'};
    final tld = domain.split('.').last;
    return reservedTlds.contains(tld) || reservedDomains.contains(domain);
  }
}
