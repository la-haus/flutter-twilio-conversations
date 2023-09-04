=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

⚠️ ⚠️
We are no longer supporting this library. Feel free to fork it and work on your own branch.
⚠️ ⚠️

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


# twilio_conversations

Flutter plugin for [Twilio Conversations](https://www.twilio.com/docs/conversations) "Build conversational, cross-channel messaging through a few API calls with Twilio Conversations."

This package is currently work-in-progress and should not be used for production apps. We can't guarantee that the current API implementation will stay the same between versions, until we have reached v1.0.0.

## Example
Check out the [example](https://gitlab.com/twilio-flutter/conversations/tree/master/example)

## Join the community
If you have any question or problems, please join us on [Discord](https://discord.gg/MWnu4nW)

## FAQ
Read the [Frequently Asked Questions](https://gitlab.com/twilio-flutter/conversations/blob/master/FAQ.md) first before creating a new issue.

## Supported platforms
- Android
- iOS
- ~~Web~~ (not yet)

## Push Notifications

### iOS
- Upon calling `ConversationClient.registerForNotification`, the plugin will retrieve the token and register it
- Notification handling is done by this plugin

### Android
- Token retrieval must be handled by the user of the plugin, and then registered with Twilio using `ConversationClient.registerForNotification(String token)`
- Notification handling must also be set up by the user of the plugin

### Code Gen
`./run_pigeon.sh`
`flutter packages pub run build_runner build --delete-conflicting-outputs`

# Contributions By

[![HomeX - Home Repairs Made Easy](https://homex.com/static/brand/homex-logo-green.svg)](https://homex.com)
[![Trek Medics](https://media.trekmedics.org/wp-content/uploads/2021/04/trek-medics-520_logo.png?strip=all&lossy=1&ssl=1&fit=100,100)](https://www.trekmedics.org/)
