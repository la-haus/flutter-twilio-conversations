import Flutter
import TwilioConversationsClient

class ParticipantsMethods {
    public static func getUsers(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing conversationSid", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                var users = [TCHUser?]()
                conversation.participants().forEach({ participant in
                    participant.subscribedUser() { (result, user) in
                        users.append(user)
                        if users.count == conversation.participants().count {
                            let userList = users.compactMap { Mapper.userToDict($0) }
                            flutterResult(Mapper.encode(userList))
                        }
                    }
                })
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func getParticipantsList(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing conversationSid", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                let participantsMap = conversation.participants().map { Mapper.participantToDict($0, conversationSid: conversationSid)}
                flutterResult(Mapper.encode(participantsMap))
            } else {
                SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func addParticipantByIdentity(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let identity = arguments["identity"] as? String,
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.addParticipant(byIdentity: identity,
                                            attributes: nil) { (result: TCHResult) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        flutterResult(true)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error adding participant to conversation with sid '\(conversationSid)', Error: \(result.error.debugDescription)", details: nil))
                    }
                }
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
    
    public static func removeParticipantByIdentity(_ call: FlutterMethodCall, _ flutterResult: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?],
              let identity = arguments["identity"] as? String,
              let conversationSid = arguments["conversationSid"] as? String else {
            return flutterResult(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }
        
        SwiftTwilioConversationsPlugin.instance?.client?.conversation(withSidOrUniqueName: conversationSid, completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.removeParticipant(byIdentity: identity) { (result: TCHResult) in
                    if result.isSuccessful {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onSuccess")
                        flutterResult(true)
                    } else {
                        SwiftTwilioConversationsPlugin.debug("\(call.method) => onError: \(String(describing: result.error))")
                        flutterResult(FlutterError(code: "ERROR", message: "Error removing participant from conversation with sid '\(conversationSid)', Error: \(result.error.debugDescription)", details: nil))
                    }
                }
            } else {
                flutterResult(FlutterError(code: "ERROR", message: "Error retrieving conversation with sid '\(conversationSid)'", details: nil))
            }
        })
    }
}
