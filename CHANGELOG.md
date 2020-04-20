# Tourmaline Changelog

I will do my best to keep this updated with changes as they happen.

## 0.17.0 (Unreleased)

+ KeyboardMarkup
  - **(breaking change)** Replace `Markup` class with `KeyboardBuilder` abstract class and extend it with   `ReplyKeyboardMarkup::Builder` and `InlineKeyboardMarkup::Builder`.
  - Add `.build` methods to `ReplyKeyboardMarkup` and `InlineKeyboardMarkup`.
  - **(breaking change)** Replace `QueryResultBuilder` with `InlineQueryResult::Builder`.
  - Update examples with new `Builder` classes being used.
+ InlineQueryResult
  - **(breaking change)** Replace `QueryResultBuilder` with `InlineQueryResult::Builder`.
  - Add `.build` method to `InlineQueryResult`.
  - Update examples with new `Builder` classes being used.
+ Persistence
  - **(breaking change)** Made `Persistence` a class rather than a module and updated `HashPersistence`
    and `JsonPersistence` to use it.
  - Add `persistence` instance variable to `Client`
  - Add `NilPersistence` and make it the default persistence for new `Client`s
  - Add `DBPersistence`

## 0.16.0

- Add CHANGELOG
- Add support for Filters.
- Add `users` methods to `Update` and `Message` to return all users included in the same.
- Replaced usage of the `strange` logger with the new Crystal `Log` class.
- Log all updates with `Debug` severity if `VERBOSE` environment variable is set to `true`.
- **(breaking change)** Renamed `File` to `TFile` to avoid conflicting with the builtin `File` class.
- **(breaking change)** removed the `Handler` class and all subclasses. Update handling is now done exclusively with the `EventHandler` class and `Filter`s.

## 0.15.1

- Fix bug with event handler that was causing `On` handlers to run on every update.
- Add CNAME file for tourmaline.dev
- Update the logo.
- Add `DiceBot` example.

## 0.15.0

Updated to bot API 4.7

- Add `send_dice` method to client.
- Add `BotCommand` model along with `get_my_commands` and `set_my_commands` methods.
- Add new sticker/sticker set methods.
- Add `Dice` update action.