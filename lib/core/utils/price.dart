import 'package:flutter/widgets.dart';

import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';

/// Renders a stored price in the interface language.
///
/// The catalogue stores prices the way the buyer's tooling writes them —
/// `"189 000 so'm"` — with the currency word baked into the string. That word
/// is Uzbek, so a Russian or English reader was being shown "so'm" in the
/// middle of their own interface, and it cannot simply be translated in place
/// because the number has to stay exactly as priced.
///
/// So: pull the digits out, and let the ARB supply the wrapper. Anything that
/// does not parse is passed through untouched rather than mangled — a price
/// written some other way is still better shown than hidden.
extension PriceFormatting on BuildContext {
  /// Digits and the separators between them, at the start of the string. The
  /// separator class is deliberately wide: the catalogue uses ordinary spaces,
  /// non-breaking spaces and commas in different rows.
  static final _amount = RegExp(r'^[\d\s .,]+');

  /// The formatted price, or null when the catalogue has none.
  ///
  /// Null rather than "price on request": `price` is an optional column in the
  /// buyer's tooling (see `tools/build_products.py`) and is currently empty for
  /// the whole shelf, so a placeholder would put the same meaningless line on
  /// all fifty-four cards. Callers show something useful instead — see
  /// `_ProductCard`.
  String? priceOrNull(String stored) {
    final trimmed = stored.trim();
    if (trimmed.isEmpty) return null;

    final amount = _amount.firstMatch(trimmed)?.group(0)?.trim();
    // Priced in some form we do not parse — still better shown than hidden.
    if (amount == null || amount.isEmpty) return trimmed;

    // Non-breaking spaces between the digit groups, so a long price never
    // wraps mid-number at the end of a narrow card.
    return l10n.productsPrice(amount.replaceAll(' ', ' '));
  }

  /// For the detail page, where the line is always drawn and an unpriced
  /// product still has to say something about what it costs.
  String price(String stored) =>
      priceOrNull(stored) ?? l10n.productsPriceOnRequest;
}
