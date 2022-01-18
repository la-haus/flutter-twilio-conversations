import Flutter
import TwilioConversationsClient

class ParticipantMethods: NSObject, TWCONParticipantApi {
    let TAG = "ParticipantMethods"

    // swiftlint:disable function_body_length
    func getUserConversationSid(
        _ conversationSid: String?,
        participantSid: String?,
        completion: @escaping (TWCONUserData?, FlutterError?) -> Void) {
        debug("getUser => conversationSid: \(String(describing: conversationSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                nil,
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing participantSid",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getUser => onSuccess")
                guard let participant = conversation.participant(withSid: participantSid) else {
                    completion(
                        nil,
                        FlutterError(
                            code: "NotFoundException",
                            message: "No participant found with sid: \(participantSid)",
                            details: nil))
                    return
                }
                participant.subscribedUser { result, user in
                    if result.isSuccessful {
                        completion(Mapper.userToPigeon(user), nil)
                    } else {
                        completion(
                            nil,
                            FlutterError(
                                code: "NotFoundException",
                                message: "No participant found with sid: \(participantSid)",
                                details: nil))
                    }
                }
            } else {
                self.debug("getUser => onError: \(String(describing: result.error))")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation with sid '\(conversationSid)'",
                        details: nil))
            }
        })
    }

    /// setAttributes
    func setAttributesConversationSid(
        _ conversationSid: String?,
        participantSid: String?,
        attributes: TWCONAttributesData?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("setAttributes => conversationSid: \(String(describing: conversationSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'participantSid' parameter",
                    details: nil))
        }

        guard let attributesData = attributes else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'attributes' parameter",
                    details: nil))
        }

        var participantAttributes: TCHJsonAttributes?
        do {
            participantAttributes = try Mapper.pigeonToAttributes(attributesData)
        } catch LocalizedConversionError.invalidData {
            return completion(
                FlutterError(
                    code: "ConversionException",
                    message: "Could not convert \(attributes?.data) to valid TCHJsonAttributes",
                    details: nil)
            )
        } catch {
            return completion(
                FlutterError(
                    code: "ConversionException",
                    message: "\(attributes?.type) is not a valid type for TCHJsonAttributes.",
                    details: nil)
            )
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("setAttributes => onSuccess")
                guard let participant = conversation.participant(withSid: participantSid) else {
                    completion(
                        FlutterError(
                            code: "NotFoundException",
                            message: "No participant found with sid: \(participantSid)",
                            details: nil))
                    return
                }
                participant.setAttributes(participantAttributes) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("setAttributes => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setAttributes => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting attributes "
                                    + "for participant \(participantSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setAttributes => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// remove
    func removeConversationSid(
        _ conversationSid: String?,
        participantSid: String?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("remove => conversationSid: \(String(describing: conversationSid)), "
            + "participantSid: \(String(describing: participantSid))")
        guard let client = SwiftTwilioConversationsPlugin.instance?.client else {
            return completion(
                FlutterError(
                    code: "ClientNotInitializedException",
                    message: "Client has not been initialized.",
                    details: nil))
        }

        guard let conversationSid = conversationSid else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'participantSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                guard let participant = conversation.participant(withSid: participantSid) else {
                    completion(
                        FlutterError(
                            code: "NotFoundException",
                            message: "No participant found with sid: \(participantSid)",
                            details: nil))
                    return
                }
                participant.remove { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("remove => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("remove => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error removing participant \(participantSid) "
                                + "from conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("remove => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
