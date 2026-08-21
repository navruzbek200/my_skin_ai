import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/features/auth/data/email_rules.dart';

void main() {
  group('isWellFormed', () {
    test('accepts ordinary addresses', () {
      for (final address in [
        'a@b.co',
        'ali.valiyev@gmail.com',
        'ali+shop@gmail.com',
        'a_b-c@mail.ru',
        'user@sub.domain.uz',
      ]) {
        expect(EmailRules.isWellFormed(address), isTrue, reason: address);
      }
    });

    test('rejects what Firebase would take but nobody can be reached at', () {
      for (final address in [
        '',
        'plainstring',
        'no-at-sign.com',
        'a@b', // no dot
        'a@b.', // nothing after the dot
        'a@b.c', // one-letter TLD
        '@nolocal.com',
        'spaces in@gmail.com',
        'a@@b.com',
      ]) {
        expect(EmailRules.isWellFormed(address), isFalse, reason: address);
      }
    });

    test('trims and folds case before judging', () {
      expect(EmailRules.isWellFormed('  Ali@Gmail.COM  '), isTrue);
      expect(EmailRules.normalise('  Ali@Gmail.COM  '), 'ali@gmail.com');
    });
  });

  group('isDisposable', () {
    test('catches the services people actually reach for', () {
      for (final address in [
        'x@mailinator.com',
        'x@10minutemail.com',
        'x@yopmail.com',
        'x@guerrillamail.com',
        'x@temp-mail.org',
      ]) {
        expect(EmailRules.isDisposable(address), isTrue, reason: address);
      }
    });

    test('catches subdomains, which is how most of them hand out addresses',
        () {
      expect(EmailRules.isDisposable('x@inbox.mailinator.com'), isTrue);
      expect(EmailRules.isDisposable('x@a.b.yopmail.com'), isTrue);
    });

    test('does not catch a real provider that merely ends similarly', () {
      // "notmailinator.com" ends with the string but not with ".mailinator.com",
      // and a suffix match without the dot would refuse a real company's domain.
      expect(EmailRules.isDisposable('x@notmailinator.com'), isFalse);
      expect(EmailRules.isDisposable('x@gmail.com'), isFalse);
      expect(EmailRules.isDisposable('x@mail.ru'), isFalse);
    });

    test('an address with no @ is not disposable, it is malformed', () {
      expect(EmailRules.isDisposable('nonsense'), isFalse);
    });
  });

  group('isUnreachable', () {
    test('refuses the RFC 2606 reserved names', () {
      for (final address in [
        'a@example.com',
        'a@example.org',
        'a@anything.test',
        'a@anything.invalid',
        'a@host.localhost',
        'a@printer.local',
      ]) {
        expect(EmailRules.isUnreachable(address), isTrue, reason: address);
      }
    });

    test('leaves real domains alone', () {
      expect(EmailRules.isUnreachable('a@gmail.com'), isFalse);
      expect(EmailRules.isUnreachable('a@realbeauty.uz'), isFalse);
      // "example" as a second-level label under a real TLD is somebody's site.
      expect(EmailRules.isUnreachable('a@example.uz'), isFalse);
    });
  });

  group('suggestionFor', () {
    test('offers the fix for the misspellings that actually happen', () {
      expect(EmailRules.suggestionFor('ali@gmial.com'), 'ali@gmail.com');
      expect(EmailRules.suggestionFor('ali@gmail.con'), 'ali@gmail.com');
      expect(EmailRules.suggestionFor('ali@yandex.ry'), 'ali@yandex.ru');
      expect(EmailRules.suggestionFor('ali@hotmial.com'), 'ali@hotmail.com');
    });

    test('normalises while suggesting', () {
      expect(EmailRules.suggestionFor('  Ali@GMIAL.com '), 'ali@gmail.com');
    });

    test('says nothing about a domain that is already fine', () {
      expect(EmailRules.suggestionFor('ali@gmail.com'), isNull);
      expect(EmailRules.suggestionFor('ali@realbeauty.uz'), isNull);
      expect(EmailRules.suggestionFor('nonsense'), isNull);
    });

    test('a domain that maps to itself produces no suggestion', () {
      // umail.uz is in the table so the entry is not lost on a future edit,
      // but suggesting the address somebody already typed would be noise.
      expect(EmailRules.suggestionFor('ali@umail.uz'), isNull);
    });
  });

  test('domainOf reads everything after the last @', () {
    expect(EmailRules.domainOf('a@b.com'), 'b.com');
    expect(EmailRules.domainOf('a@b@c.com'), 'c.com');
    expect(EmailRules.domainOf('nonsense'), '');
  });
}
