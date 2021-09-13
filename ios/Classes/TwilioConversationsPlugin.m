#import "TwilioConversationsPlugin.h"
#if __has_include(<twilio_conversations/twilio_conversations-Swift.h>)
#import <twilio_conversations/twilio_conversations-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "twilio_conversations-Swift.h"
#endif

@implementation TwilioConversationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTwilioConversationsPlugin registerWithRegistrar:registrar];
}
@end
