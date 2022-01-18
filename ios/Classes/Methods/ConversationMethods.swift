// swiftlint:disable file_length type_body_length
import Flutter
import TwilioConversationsClient

class ConversationMethods: NSObject, TWCONConversationApi {
    let TAG = "ConversationMethods"

    // swiftlint:disable function_body_length
    /// joinConversation
    func joinConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("join => conversationSid: \(String(describing: conversationSid))")
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

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.join { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("join => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("join => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error joining "
                                    + "conversation with sid \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("join => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation with sid \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// leaveConversation
    func leaveConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("leave => conversationSid: \(String(describing: conversationSid))")
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

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.leave { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("leave => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("leave => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error leaving conversation \(conversationSid): "
                                    + "\(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("leave => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation with sid \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// destroyConversation
    func destroyConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("destroy => conversationSid: \(String(describing: conversationSid))")
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

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.destroy(completion: { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("destroy => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("destroy => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error destroying conversation \(conversationSid): "
                                    + "\(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("destroy => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// typing
    func typingConversationSid(_ conversationSid: String?, completion: @escaping (FlutterError?) -> Void) {
        debug("typing => conversationSid: \(String(describing: conversationSid))")
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

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("typing => onSuccess")
                conversation.typing()
                completion(nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("typing => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// sendMessage
    func sendMessageConversationSid(
        _ conversationSid: String?,
        options: TWCONMessageOptionsData?,
        completion: @escaping (TWCONMessageData?, FlutterError?) -> Void) {
        debug("sendMessage => conversationSid: \(String(describing: conversationSid))")
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let options = options else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'options' parameter",
                    details: nil))
        }

        let messageOptions = TCHMessageOptions()

        if let messageBody = options.body {
            messageOptions.withBody(messageBody)
        }
        if let input = options.inputPath {
            guard let mimeType = options.mimeType else {
                return completion(
                    nil,
                    FlutterError(
                        code: "MissingParameterException",
                        message: "Missing 'mimeType' in MessageOptions",
                        details: nil))
            }

            if let inputStream = InputStream(fileAtPath: input) {
                messageOptions.withMediaStream(inputStream, contentType: mimeType, defaultFilename: options.filename,
                                               onStarted: nil,
                                               onProgress: nil,
                                               onCompleted: nil)
//                                               ,
//                                               onStarted: {
//                    // implement media stream progress listener
//
//                },
//                                               onProgress: { (bytes: UInt) in
//                    // implement media stream progress listener
//
//                },
//                                               onCompleted: { (mediaSid: String) in
//                    // implement media stream progress listener
//
//                }
//                )
            } else {
                return completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating file for upload from `\(input)`",
                        details: nil))
            }
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.sendMessage(
                    with: messageOptions,
                    completion: { (result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful,
                       let message = message {
                        self.debug("sendMessage => onSuccess")
                        completion(Mapper.messageToPigeon(message, conversationSid: conversationSid), nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("sendMessage => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error sending message in conversation "
                                    + "\(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("typing => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// addParticipantByIdentity
    func addParticipant(
        byIdentityConversationSid conversationSid: String?,
        identity: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        debug("addParticipantByIdentity => conversationSid: \(String(describing: conversationSid))")
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.addParticipant(byIdentity: identity,
                                            attributes: nil) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("addParticipantByIdentity => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("addParticipantByIdentity => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error adding participant to conversation "
                                    + "\(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                self.debug("addParticipantByIdentity => onError: \(String(describing: result.error))")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation with sid '\(conversationSid)'",
                        details: nil))
            }
        })
    }

    /// removeParticipant
    func removeParticipantConversationSid(
        _ conversationSid: String?,
        participantSid: String?,
        completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'sid' parameter",
                    details: nil))
        }

        debug("removeParticipant => conversationSid: \(conversationSid) participantSid: \(participantSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid) { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                guard let participant = conversation.participant(withSid: participantSid) else {
                    return completion(
                        nil,
                        FlutterError(
                            code: "NotFoundException",
                            message: "Error locating participant \(participantSid)",
                            details: nil))
                }
                conversation.removeParticipant(participant) { (result: TCHResult) in
                    if result.isSuccessful {
                        return completion(true, nil)
                    } else {
                        return completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error removing participant \(participantSid)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("removeParticipant => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        }
    }

    /// removeParticipantByIdentity
    func removeParticipant(
        byIdentityConversationSid conversationSid: String?,
        identity: String?, completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        debug("removeParticipantByIdentity => conversationSid: \(conversationSid) identity: \(identity)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.removeParticipant(byIdentity: identity) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("removeParticipantByIdentity => onSuccess")
                        completion(true, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("removeParticipantByIdentity => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error removing participant from "
                                    + "conversation \(conversationSid): Error: \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("removeParticipantByIdentity => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    /// getParticipantByIdentity
    func getParticipantByIdentityConversationSid(
        _ conversationSid: String?,
        identity: String?,
        completion: @escaping (TWCONParticipantData?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let identity = identity else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'identity' parameter",
                    details: nil))
        }

        debug("getParticipantByIdentity => conversationSid: \(conversationSid) identity: \(identity)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getParticipantByIdentity => onSuccess")
                guard let participant = conversation.participant(withIdentity: identity) else {
                    completion(nil, FlutterError(
                        code: "NotFoundException",
                        message: "No participant found with identity \(identity)",
                        details: nil))
                    return
                }
                let participantData = Mapper.participantToPigeon(participant, conversationSid: conversationSid)
                completion(participantData, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getParticipantByIdentity => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    /// getParticipantBySid
    func getParticipantBySidConversationSid(
        _ conversationSid: String?,
        participantSid: String?,
        completion: @escaping (TWCONParticipantData?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let participantSid = participantSid else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'participantSid' parameter",
                    details: nil))
        }

        debug("getParticipantBySid => conversationSid: \(conversationSid) participantSid: \(participantSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getParticipantBySid => onSuccess")
                guard let participant = conversation.participant(withSid: participantSid) else {
                    completion(nil, FlutterError(
                        code: "NotFoundException",
                        message: "No participant found with sid \(participantSid)",
                        details: nil))
                    return
                }
                let participantData = Mapper.participantToPigeon(participant, conversationSid: conversationSid)
                completion(participantData, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getParticipantBySid => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    /// getParticipantsList
    func getParticipantsListConversationSid(
        _ conversationSid: String?,
        completion: @escaping ([TWCONParticipantData]?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("getParticipantsList => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("getParticipantsList => onSuccess")
                let participantsList = conversation.participants().compactMap {
                    Mapper.participantToPigeon($0, conversationSid: conversationSid)
                }
                completion(participantsList, nil)
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getParticipantsList => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    /// getMessagesCount
    func getMessagesCountConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("getMessagesCount => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("getMessagesCount => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getMessagesCount => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error getting message count "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getMessagesCount => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid)",
                        details: nil))
            }
        })
    }

    /// getUnreadMessagesCount
    func getUnreadMessagesCountConversationSid(
        _ conversationSid: String?,
        completion: @escaping (NSNumber?, FlutterError?) -> Void) {
        debug("getUnreadMessagesCount => conversationSid: \(String(describing: conversationSid))")
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getUnreadMessagesCount { (result: TCHResult, count: NSNumber?) in
                    if result.isSuccessful {
                        self.debug("getUnreadMessagesCount => onSuccess: \(String(describing: count))")
                        completion(count ?? 0, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getUnreadMessagesCount => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error retrieving unread messages count "
                                    + "for conversation \(conversationSid): Error: \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getUnreadMessagesCount => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// advanceLastReadMessageIndex
    func advanceLastReadMessageIndexConversationSid(
        _ conversationSid: String?,
        lastReadMessageIndex: NSNumber?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let lastReadMessageIndex = lastReadMessageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'lastReadMessageIndex' parameter",
                    details: nil))
        }

        debug("advanceLastReadMessageIndex => conversationSid: \(conversationSid) index: \(lastReadMessageIndex)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.advanceLastReadMessageIndex(
                    lastReadMessageIndex,
                    completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("advanceLastReadMessageIndex => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("advanceLastReadMessageIndex => onError: \(errorMessage))")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error advancing last consumed message index "
                                    + "\(lastReadMessageIndex) for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("advanceLastReadMessageIndex => onError: \(errorMessage))")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// setLastReadMessageIndex
    func setLastReadMessageIndexConversationSid(
        _ conversationSid: String?,
        lastReadMessageIndex: NSNumber?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let lastReadMessageIndex = lastReadMessageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'lastReadMessageIndex' parameter",
                    details: nil))
        }

        debug("setLastReadMessageIndex => conversationSid: \(conversationSid) index: \(lastReadMessageIndex)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setLastReadMessageIndex(
                    lastReadMessageIndex,
                    completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("setLastReadMessageIndex => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setLastReadMessageIndex => onError: \(errorMessage))")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting last consumed message index "
                                    + "\(lastReadMessageIndex) for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setLastReadMessageIndex => onError: \(errorMessage))")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// setAllMessagesRead
    func setAllMessagesReadConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("setAllMessagesRead => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setAllMessagesReadWithCompletion({ (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("setAllMessagesRead => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        self.debug("setAllMessagesRead => onError: \(String(describing: result.error))")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting all messages read for conversation "
                                    + "\(conversationSid)",
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

    /// setAllMessagesUnread
    func setAllMessagesUnreadConversationSid(
        _ conversationSid: String?,
        completion: @escaping (TWCONMessageCount?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("setAllMessagesUnread => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful,
               let conversation = conversation {
                conversation.setAllMessagesUnreadWithCompletion({ (result: TCHResult, count: NSNumber?) in
                    if result.isSuccessful {
                        self.debug("setAllMessagesUnread => onSuccess")
                        let result = TWCONMessageCount()
                        result.count = count
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setAllMessagesUnread => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting all messages read for conversation " +
                                    "\(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setAllMessagesUnread => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// getParticipantsCount
    func getParticipantsCountConversationSid(
        _ conversationSid: String?,
        completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        debug("getParticipantsCount => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getParticipantsCount(completion: { (result: TCHResult, count: UInt) in
                    if result.isSuccessful {
                        self.debug("getParticipantsCount => onSuccess")
                        let result = NSNumber(value: count)
                        completion(result, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getParticipantsCount => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error getting message count "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getParticipantsCount => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation "
                            + "\(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// removeMessage
    func removeMessageConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        completion: @escaping (NSNumber?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let index = messageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'index' parameter",
                    details: nil))
        }

        debug("removeMessage => conversationSid: \(conversationSid) index: \(index)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.message(withIndex: index) { (_ result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful, let message = message {
                        conversation.remove(message) { (result: TCHResult) in
                            if result.isSuccessful {
                                completion(true, nil)
                            } else {
                                let errorMessage = String(describing: result.error)
                                self.debug("removeMessage => onError: \(errorMessage)")

                                completion(
                                    false,
                                    FlutterError(
                                        code: "TwilioException",
                                        message: "\(result.error?.code)|Error removing message \(index): "
                                            + "\(errorMessage)",
                                        details: nil))
                            }
                        }
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("removeMessage => onError: \(errorMessage)")

                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// getMessagesAfter
    func getMessagesAfterConversationSid(
        _ conversationSid: String?,
        index: NSNumber?,
        count: NSNumber?,
        completion: @escaping ([TWCONMessageData]?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let index = index else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'index' parameter",
                    details: nil))
        }

        guard let count = count else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'count' parameter",
                    details: nil))
        }

        debug("getMessagesAfter => conversationSid: \(conversationSid) index: \(index) count: \(count)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesAfter(
                    index.uintValue,
                    withCount: count.uintValue,
                    completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        self.debug("getMessagesAfter => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToPigeon(message, conversationSid: conversationSid)
                        }
                        completion(messagesMap, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getMessagesAfter => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error retrieving \(count) messages before " +
                                    "message index: \(index) from conversation \(conversationSid): " +
                                    "\(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getMessagesAfter => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// getMessagesBefore
    func getMessagesBeforeConversationSid(
        _ conversationSid: String?,
        index: NSNumber?,
        count: NSNumber?,
        completion: @escaping ([TWCONMessageData]?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let index = index else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'index' parameter",
                    details: nil))
        }

        guard let count = count else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'count' parameter",
                    details: nil))
        }

        debug("getMessagesBefore => conversationSid: \(conversationSid)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getMessagesBefore(
                    index.uintValue,
                    withCount: count.uintValue,
                    completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        self.debug("getMessagesBefore => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToPigeon(message, conversationSid: conversationSid)
                        }
                        completion(messagesMap, nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getMessagesBefore => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error retrieving \(count) messages before " +
                                    "message index: \(index) from conversation \(conversationSid)" +
                                    "\(errorMessage)",
                                details: nil))
                    }
                })
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getMessagesBefore => onError: \(errorMessage)")
                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// getMessageByIndex
    func getMessageByIndexConversationSid(
        _ conversationSid: String?,
        messageIndex: NSNumber?,
        completion: @escaping (TWCONMessageData?, FlutterError?) -> Void) {
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let index = messageIndex else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'index' parameter",
                    details: nil))
        }

        debug("getMessageByIndex => conversationSid: \(conversationSid) index: \(index)")

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.message(withIndex: index) { (_ result: TCHResult, message: TCHMessage?) in
                    if result.isSuccessful, let message = message {
                        completion(
                            Mapper.messageToPigeon(
                                message,
                                conversationSid: conversationSid),
                            nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("getMessageByIndex => onError: \(errorMessage)")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error retrieving message \(messageIndex) " +
                                    "in conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("getMessageByIndex => onError: \(errorMessage)")

                completion(
                    nil,
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error retrieving conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// getLastMessages
    func getLastMessagesConversationSid(
        _ conversationSid: String?,
        count: NSNumber?,
        completion: @escaping ([TWCONMessageData]?, FlutterError?) -> Void) {
        debug("getLastMessages => conversationSid: \(String(describing: conversationSid))")
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
                    message: "Missing 'conversationSid' parameter",
                    details: nil))
        }

        guard let count = count else {
            return completion(
                nil,
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'count' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.getLastMessages(
                    withCount: count.uintValue,
                    completion: { (result: TCHResult, messages: [TCHMessage]?) in
                    if result.isSuccessful, let messages = messages {
                        self.debug("getLastMessages => onSuccess")
                        let messagesMap = messages.map { message in
                            Mapper.messageToPigeon(message, conversationSid: conversationSid)
                        }
                        completion(messagesMap, nil)
                    } else {
                        self.debug("getLastMessages => onError: \(String(describing: result.error))")
                        completion(
                            nil,
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error retrieving last \(count) "
                                    + "messages for conversation \(conversationSid)",
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

        guard let attributesData = attributes else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'attributes' parameter",
                    details: nil))
        }

        var conversationAttributes: TCHJsonAttributes?
        do {
            conversationAttributes = try Mapper.pigeonToAttributes(attributesData)
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
                conversation.setAttributes(conversationAttributes) { (result: TCHResult) in
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
                                    + "for conversation \(conversationSid): \(errorMessage)",
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

    /// setFriendlyName
    func setFriendlyNameConversationSid(
        _ conversationSid: String?,
        friendlyName: String?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("setFriendlyName => conversationSid: \(String(describing: conversationSid))")
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

        guard let friendlyName = friendlyName else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'friendlyName' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("setFriendlyName => onSuccess")
                conversation.setFriendlyName(friendlyName) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("setFriendlyName => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setFriendlyName => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting friendly name "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setFriendlyName => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// setNotificationLevel
    func setNotificationLevelConversationSid(
        _ conversationSid: String?,
        notificationLevel: String?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("setNotificationLevel => conversationSid: "
            + "\(String(describing: conversationSid)) notificationLevel: \(String(describing: notificationLevel))")
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

        guard let notificationLevel = notificationLevel,
              let level = Mapper.stringToNotificationLevel(notificationLevel) else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'notificationLevel' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                conversation.setNotificationLevel(level) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("setNotificationLevel => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setNotificationLevel => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting notification level "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setNotificationLevel => onError: \(errorMessage)")
                completion(
                    FlutterError(
                        code: "NotFoundException",
                        message: "Error locating conversation \(conversationSid): \(errorMessage)",
                        details: nil))
            }
        })
    }

    /// setUniqueName
    func setUniqueNameConversationSid(
        _ conversationSid: String?,
        uniqueName: String?,
        completion: @escaping (FlutterError?) -> Void) {
        debug("setUniqueName => conversationSid: \(String(describing: conversationSid))")
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

        guard let uniqueName = uniqueName else {
            return completion(
                FlutterError(
                    code: "MissingParameterException",
                    message: "Missing 'uniqueName' parameter",
                    details: nil))
        }

        client.conversation(
            withSidOrUniqueName: conversationSid,
            completion: { (result: TCHResult, conversation: TCHConversation?) in
            if result.isSuccessful, let conversation = conversation {
                self.debug("setUniqueName => onSuccess")
                conversation.setUniqueName(uniqueName) { (result: TCHResult) in
                    if result.isSuccessful {
                        self.debug("setUniqueName => onSuccess")
                        completion(nil)
                    } else {
                        let errorMessage = String(describing: result.error)
                        self.debug("setUniqueName => onError: \(errorMessage)")
                        completion(
                            FlutterError(
                                code: "TwilioException",
                                message: "\(result.error?.code)|Error setting unique name "
                                    + "for conversation \(conversationSid): \(errorMessage)",
                                details: nil))
                    }
                }
            } else {
                let errorMessage = String(describing: result.error)
                self.debug("setFriendlyName => onError: \(errorMessage)")
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
