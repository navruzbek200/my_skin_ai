import 'package:flutter/foundation.dart';

/// One published reference behind a piece of skin-care copy.
///
/// The title is left untranslated on purpose: it is the name of a paper or a
/// page as its publisher wrote it, and a reader following the link should find
/// the same words at the other end.
@immutable
class Source {
  const Source(this.title, this.url);

  /// "Publisher — Headline", the way every entry in `Sources` is written.
  final String title;
  final String url;

  static const _separator = ' — ';

  /// Who published it: "American Academy of Dermatology", "Marques et al.,
  /// 2024". Empty when the title has no separator.
  String get publisher {
    final i = title.indexOf(_separator);
    return i < 0 ? '' : title.substring(0, i);
  }

  /// What it is called, without the publisher in front.
  String get headline {
    final i = title.indexOf(_separator);
    return i < 0 ? title : title.substring(i + _separator.length);
  }

  /// The site the link lands on, as a reader would recognise it:
  /// "aad.org", "pmc.ncbi.nlm.nih.gov", "doi.org".
  String get domain {
    final host = Uri.tryParse(url)?.host ?? '';
    return host
        .replaceFirst(RegExp(r'^www\.'), '')
        .replaceFirst(RegExp(r'^dx\.'), '');
  }
}
