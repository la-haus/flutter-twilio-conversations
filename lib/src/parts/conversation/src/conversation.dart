import 'dart:async';
import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class Conversation {
  final String sid;
  Attributes attributes;
  String uniqueName;
  String friendlyName;
  ConversationStatus status;
  ConversationSynchronizationStatus synchronizationStatus;
  DateTime dateCreated;
  String createdBy;
  DateTime dateUpdated;
  DateTime lastMessageDate;
  int lastMessageIndex;
  int lastReadMessageIndex;

  bool get hasMessages => lastMessageIndex != null;

  bool get hasSynchronized =>
      (status == ConversationStatus.JOINED &&
          synchronizationStatus == ConversationSynchronizationStatus.ALL) ||
      (status == ConversationStatus.NOT_PARTICIPATING &&
          synchronizationStatus == ConversationSynchronizationStatus.METADATA);
  Messages messages;

  Participants participants;

  /// Local caching event stream so each instance will use the same stream.
  static final Map<String, Stream> _conversationStreams = {};
  final StreamController<Message> _onMessageAddedCtrl =
      StreamController<Message>.broadcast();

  /// Called when a [Message] is added to the conversation the current user is subscribed to.
  Stream<Message> onMessageAdded;
  final StreamController<MessageUpdatedEvent> _onMessageUpdatedCtrl =
      StreamController<MessageUpdatedEvent>.broadcast();

  /// Called when a [Message] is changed in the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was updated by using [Message.getConversation] or [Message.conversationSid].
  /// [Message] change events include body updates and attribute updates.
  Stream<MessageUpdatedEvent> onMessageUpdated;

  final StreamController<Message> _onMessageDeletedCtrl =
      StreamController<Message>.broadcast();

  /// Called when a [Message] is deleted from the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was deleted by using [Message.getConversation] or [Message.conversationSid].
  Stream<Message> onMessageDeleted;

  final StreamController<Participant> _onParticipantAddedCtrl =
      StreamController<Participant>.broadcast();

  /// Called when a [Participant] is added to the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was added by using [Participant.getConversation].
  Stream<Participant> onParticipantAdded;

  final StreamController<ParticipantUpdatedEvent> _onParticipantUpdatedCtrl =
      StreamController<ParticipantUpdatedEvent>.broadcast();

  /// Called when a [Participant] is changed in the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was updated by using [Participant.getConversation].
  /// [Participant] change events include body updates and attribute updates.
  Stream<ParticipantUpdatedEvent> onParticipantUpdated;

  final StreamController<Participant> _onParticipantDeletedCtrl =
      StreamController<Participant>.broadcast();

  /// Called when a [Participant] is deleted from the conversation the current user is subscribed to.
  ///
  /// You could obtain the [Conversation] where it was deleted by using [Participant.getConversation].
  Stream<Participant> onParticipantDeleted;

  //#region Typing events
  final StreamController<TypingEvent> _onTypingStartedCtrl =
      StreamController<TypingEvent>.broadcast();

  /// Called when an [Participant] starts typing in a [Conversation].
  Stream<TypingEvent> onTypingStarted;

  final StreamController<TypingEvent> _onTypingEndedCtrl =
      StreamController<TypingEvent>.broadcast();

  /// Called when an [Participant] stops typing in a [Conversation].
  ///
  /// Typing indicator has a timeout after user stops typing to avoid triggering it too often. Expect about 5 seconds delay between stopping typing and receiving typing ended event.
  Stream<TypingEvent> onTypingEnded;

  final StreamController<Conversation> _onSynchronizationChangedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when conversation synchronization status changed.
  Stream<Conversation> onSynchronizationChanged;

  Conversation(this.sid) {
    this.messages = Messages(this);
    this.participants = Participants(conversationSid: sid);
    onMessageAdded = _onMessageAddedCtrl.stream;
    onMessageUpdated = _onMessageUpdatedCtrl.stream;
    onMessageDeleted = _onMessageDeletedCtrl.stream;
    onParticipantAdded = _onParticipantAddedCtrl.stream;
    onParticipantUpdated = _onParticipantUpdatedCtrl.stream;
    onParticipantDeleted = _onParticipantDeletedCtrl.stream;
    onTypingStarted = _onTypingStartedCtrl.stream;
    onTypingEnded = _onTypingEndedCtrl.stream;
    onSynchronizationChanged = _onSynchronizationChangedCtrl.stream;

    _conversationStreams[sid] ??=
        EventChannel('twilio_conversations/$sid').receiveBroadcastStream(0);
    _conversationStreams[sid].listen(_parseEvents);
  }

  void updateFromMap(Map<String, dynamic> map) {
    attributes = map['attributes'] == null
        ? null
        : Attributes.fromJson(map['attributes'] as Map<String, dynamic>);
    uniqueName = map['uniqueName'] as String;
    friendlyName = map['friendlyName'] as String;
    status = EnumToString.fromString(
        ConversationStatus.values, map['status'] as String);
    synchronizationStatus = EnumToString.fromString(
        ConversationSynchronizationStatus.values,
        map['synchronizationStatus'] as String);
    dateCreated = map['dateCreated'] == null
        ? null
        : DateTime.parse(map['dateCreated'] as String);
    createdBy = map['createdBy'] as String;
    dateUpdated = map['dateUpdated'] == null
        ? null
        : DateTime.parse(map['dateUpdated'] as String);
    lastMessageDate = map['lastMessageDate'] == null
        ? null
        : DateTime.parse(map['lastMessageDate'] as String);
    lastReadMessageIndex = map['lastReadMessageIndex'] as int;
    lastMessageIndex = map['lastMessageIndex'] as int;
  }

  /// Construct from a map.
  factory Conversation.fromMap(Map<String, dynamic> map) {
    var conversation = Conversation(
      map['sid'] as String,
    );
    conversation.updateFromMap(map);
    return conversation;
  }

  Future<int> getUnreadMessagesCount() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<int>(
        'ConversationMethods.getUnreadMessagesCount', {'conversationSid': sid});

    return result;
  }

  Future<bool> join() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ConversationMethods.join', {'conversationSid': sid});

    return result;
  }

  Future<bool> leave() async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ConversationMethods.leave', {'conversationSid': sid});

    return result;
  }

  Future<String> setFriendlyName(String friendlyName) async {
    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ConversationMethods.setFriendlyName',
        {'conversationSid': sid, 'friendlyName': friendlyName});

    this.friendlyName = result.toString();
    return friendlyName;
  }

  /// Indicate that Participant is typing in this conversation.
  ///
  /// You should call this method to indicate that a local user is entering a message into current conversation. The typing state is forwarded to users subscribed to this conversation through [Conversation.onTypingStarted] and [Conversation.onTypingEnded] callbacks.
  /// After approximately 5 seconds after the last [Conversation.typing] call the SDK will emit [Conversation.onTypingEnded] signal.
  /// One common way to implement this indicator is to call [Conversation.typing] repeatedly in response to key input events.
  Future<bool> typing() async {
    try {
      return await TwilioConversations.methodChannel
          .invokeMethod('ConversationMethods.typing', {'conversationSid': sid});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Parse native channel events to the right event streams.
  void _parseEvents(dynamic event) {
    var eventMap = jsonDecode(event.toString());
    final String eventName = eventMap['name'] as String;
    final data = Map<String, dynamic>.from(eventMap['data'] as Map);
    if (data['conversation'] != null) {
      final conversationMap =
          Map<String, dynamic>.from(data['conversation'] as Map);
      updateFromMap(conversationMap);
    }

    Message message;
    if (data['message'] != null) {
      final messageMap = Map<String, dynamic>.from(data['message'] as Map);
      message = Message.fromJson(messageMap);
    }

    Participant participant;
    if (data['participant'] != null) {
      final memberMap = Map<String, dynamic>.from(data['participant'] as Map);
      participant = Participant.fromJson(memberMap);
    }

    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap =
          Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      switch (reasonMap['type'] as String) {
        case 'message':
          reason = EnumToString.fromString(
              MessageUpdateReason.values, reasonMap['value'] as String);
          break;
        case 'participant':
          reason = EnumToString.fromString(
              ParticipantUpdateReason.values, reasonMap['value'] as String);
          break;
      }
    }

    switch (eventName) {
      case 'messageAdded':
        assert(message != null);
        _onMessageAddedCtrl.add(message);
        break;
      case 'messageUpdated':
        assert(message != null);
        assert(reason != null);
        _onMessageUpdatedCtrl
            .add(MessageUpdatedEvent(message, reason as MessageUpdateReason));
        break;
      case 'messageDeleted':
        assert(message != null);
        _onMessageDeletedCtrl.add(message);
        break;
      case 'participantAdded':
        assert(participant != null);
        _onParticipantAddedCtrl.add(participant);
        break;
      case 'participantUpdated':
        assert(participant != null);
        assert(reason != null);
        _onParticipantUpdatedCtrl.add(ParticipantUpdatedEvent(
            participant, reason as ParticipantUpdateReason));
        break;
      case 'participantDeleted':
        assert(participant != null);
        _onParticipantDeletedCtrl.add(participant);
        break;
      case 'typingStarted':
        assert(participant != null);
        _onTypingStartedCtrl.add(TypingEvent(this, participant));
        break;
      case 'typingEnded':
        assert(participant != null);
        _onTypingEndedCtrl.add(TypingEvent(this, participant));
        break;
      case 'synchronizationChanged':
        _onSynchronizationChangedCtrl.add(this);
        break;
      default:
        TwilioConversations.log("Event '$eventName' not yet implemented");
        break;
    }
  }
}
