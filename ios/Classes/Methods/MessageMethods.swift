import Flutter
import TwilioConversationsClient

// swiftlint:disable type_body_length
class MessageMethods: NSObject, TWCONMessageApi {
    let TAG = "MessageMethods"

    // swiftlint:disable function_body_length
    public func getMediaContentTemporaryUrlConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        completion: @escaping (String?, FlutterError?) -> Void) {
        debug("getMediaContentTemporaryUrl => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
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
                nil, FlutterError(
                    code: "MissingParameterException",
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing messageIndex",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
                if result.isSuccessful, let conversation = conversation {
                    conversation.message(
                        withIndex: messageIndex,
                        completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful, let message = message {
                            message.getMediaContentTemporaryUrl(completion: { (result: TCHResult, url: String?) in
                                if result.isSuccessful, let url = url {
                                    self.debug("getMediaContentTemporaryUrl => onSuccess: \(url)")
                                    completion(url, nil)
                                } else {
                                    let errorMessage = String(describing: result.error)
                                    self.debug("getMediaContentTemporaryUrl => onError: \(errorMessage)")
                                    completion(
                                        nil,
                                        FlutterError(
                                            code: "TwilioException",
                                            message: "\(result.error?.code)|Error getting mediaContentTemporaryUrl: "
                                            + "\(errorMessage)",
                                            details: nil))
                                }
                            })
                        } else {
                            self.debug("getMediaContentTemporaryUrl => onError: \(String(describing: result.error))")
                            completion(
                                nil,
                                FlutterError(
                                    code: "NotFoundException",
                                    message: "Error locating message with index \(messageIndex) "
                                        + "in conversation \(conversationSid)",
                                    details: nil))
                        }
                    })
                } else {
                    completion(
                        nil,
                        FlutterError(
                            code: "NotFoundException",
                            message: "Error locating conversation \(conversationSid)",
                            details: nil))
                }
        })
    }

    /// getParticipant
    func getParticipantConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        completion: @escaping (TWCONParticipantData?, FlutterError?) -> Void) {
        debug("getParticipant => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
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
                nil, FlutterError(
                    code: "MissingParameterException",
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing messageIndex",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
                if result.isSuccessful, let conversation = conversation {
                    conversation.message(
                        withIndex: messageIndex,
                        completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful, let message = message {
                            guard let participant = message.participant else {
                                return completion(
                                    nil,
                                    FlutterError(
                                        code: "NotFoundException",
                                        message: "Participant not found for message: \(messageIndex).",
                                        details: nil))
                            }

                            self.debug("getParticipant => onSuccess")
                            let participantData =
                                Mapper.participantToPigeon(participant, conversationSid: conversationSid)
                            return completion(participantData, nil)
                        } else {
                            self.debug("getParticipant => onError: \(String(describing: result.error))")
                            completion(
                                nil,
                                FlutterError(
                                    code: "NotFoundException",
                                    message: "Error getting message at index \(messageIndex) "
                                        + "in conversation \(conversationSid)",
                                    details: nil))
                        }
                    })
                } else {
                    completion(
                        nil,
                        FlutterError(
                            code: "NotFoundException",
                            message: "Error locating conversation \(conversationSid)",
                            details: nil))
                }
        })
    }

    /// setAttributes
    func setAttributesConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        attributes: TWCONAttributesData?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("setAttributes => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
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
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing messageIndex",
                    details: nil))
        }

        guard let attributesData = attributes else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'attributes' parameter",
                    details: nil))
        }

        var messageAttributes: TCHJsonAttributes?
        do {
            messageAttributes = try Mapper.pigeonToAttributes(attributesData)
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
                conversation.message(
                    withIndex: messageIndex,
                    completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful, let message = message {
                        message.setAttributes(messageAttributes) { (result: TCHResult) in
                            if result.isSuccessful {
                                self.debug("setAttributes => onSuccess")
                                return completion(nil)
                            } else {
                                self.debug("setAttributes => onError: \(String(describing: result.error))")
                                return completion(
                                    FlutterError(
                                        code: "TwilioException",
                                        message: "\(result.error?.code)|Error setting attributes for message at "
                                            + "index \(messageIndex) in conversation \(conversationSid)",
                                        details: nil))
                            }
                        }
                    } else {
                        self.debug("setAttributes => onError: \(String(describing: result.error))")
                        completion(
                            FlutterError(
                                code: "NotFoundException",
                                message: "Error getting message at index \(messageIndex) "
                                    + "in conversation \(conversationSid)",
                                details: nil))
                    }
                })
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

    /// updateMessageBody
    func updateMessageBodyConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        messageBody: String?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("updateMessageBody => conversationSid: \(String(describing: conversationSid)), "
                + "messageIndex: \(String(describing: messageIndex))")
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
                    message: "Missing conversationSid",
                    details: nil))
        }

        guard let messageIndex = messageIndex else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing messageIndex",
                    details: nil))
        }

        guard let messageBody = messageBody else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing messageBody",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
                if result.isSuccessful, let conversation = conversation {
                    conversation.message(
                        withIndex: messageIndex,
                        completion: { (result: TCHResult, message: TCHMessage?) in
                        if result.isSuccessful, let message = message {
                            message.updateBody(messageBody) { (result: TCHResult) in
                                if result.isSuccessful {
                                    self.debug("updateMessageBody => onSuccess")
                                    return completion(nil)
                                } else {
                                    self.debug("updateMessageBody => onError: \(String(describing: result.error))")
                                    return completion(
                                        FlutterError(
                                            code: "TwilioException",
                                            message: "\(result.error?.code)|Error updating message at index "
                                                + "\(messageIndex) in conversation \(conversationSid)",
                                            details: nil))
                                }
                            }
                        } else {
                            self.debug("updateMessageBody => onError: \(String(describing: result.error))")
                            completion(
                                FlutterError(
                                    code: "NotFoundException",
                                    message: "Error getting message at index \(messageIndex) "
                                        + "in conversation \(conversationSid)",
                                    details: nil))
                        }
                    })
                } else {
                    completion(
                        FlutterError(
                            code: "NotFoundException",
                            message: "Error locating conversation \(conversationSid)",
                            details: nil))
                }
        })
    }

    private func debug(_ msg: String) {
        SwiftTwilioConversationsPlugin.debug("\(TAG)::\(msg)")
    }
}
