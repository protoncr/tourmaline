# TDLight

TDLight is a fork of the Telegram Bot API with more methods and optional user support. Tourmaline has out of the box support for TDLight, including support for its User API methods. All supported TDLight specific methods can be found [here][Tourmaline::Client::TDLightMethods].

If you want to use TDLight without running your own API server you can use one of the official TDLight managed servers such as [telegram.rest](https://telegram.rest).

## User API

Unlike the normal Bot API, TDLight supports user mode. While pretty limited at the moment, this gives you the ability to log in with a user account and treat it as you would a normal bot (with some restrictions of course). Logging in with a user account is a 2 step process:

First: Call [login][Tourmaline::Client::TDLightMethods#login(phone_number)] with the phone number that's attached to your account. This will return a `user_token` which can be saved and provided directly to the `Client.new` method later.

Second: Telegram should've sent a code to a logged in client or your phone. Call [send_code][Tourmaline::Client::TDLightMethods#send_code(code)] with that code to complete the authorization process.

If all went well you should now be logged in and able to do most of the same things that bots can do. Some methods are (obviously) not available as a user. This includes:

- `answer_callback_query`
- `set_my_commands`
- `edit_message_reply_markup`
- `upload_sticker_file`
- `create_new_sticker_set`
- `add_sticker_to_set`
- `set_sticker_position_in_set`
- `delete_sticker_from_set`
- `set_sticker_set_thumb`
- `send_invoice`
- `answer_shipping_query`
- `answer_pre_checkout_query`
- `set_passport_data_errors`
- `send_game`
- `set_game_score`
- `get_game_highscores`

It is also not possible to attach `reply_markup` to your messages.

## Outgoing Messages

The main downside to using TDLight for your userbot is the lack of support (currently) for outgoing messages. There is [an issue](https://github.com/tdlight-team/tdlight-telegram-bot-api/issues/32) for this, and hopefully it will be resolved soon.