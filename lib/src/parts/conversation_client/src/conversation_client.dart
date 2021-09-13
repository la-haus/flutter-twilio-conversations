import 'dart:async';
import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:twilio_conversations/twilio_conversations.dart';

class ConversationUpdatedEvent {
  final Conversation conversation;
  final ConversationUpdateReason reason;

  ConversationUpdatedEvent(this.conversation, this.reason)
      : assert(conversation != null),
        assert(reason != null);
}

class UserUpdatedEvent {
  final User user;

  final UserUpdateReason reason;

  UserUpdatedEvent(this.user, this.reason)
      : assert(user != null),
        assert(reason != null);
}

class NewMessageNotificationEvent {
  final String conversationSid;
  final String messageSid;
  final int messageIndex;

  NewMessageNotificationEvent(
      this.conversationSid, this.messageSid, this.messageIndex)
      : assert(conversationSid != null),
        assert(messageSid != null),
        assert(messageIndex != null);
}

class ConversationClient {
  Conversations conversations;

  String myIdentity;
  ConnectionState connectionState;
  bool isReachabilityEnabled;

  /// Stream for the native client events.
  StreamSubscription<dynamic> _clientStream;

  /// Stream for the notification events.
  StreamSubscription<dynamic> _notificationStream;

  final StreamController<bool> _onClientListenerAttachedCtrl =
      StreamController<bool>.broadcast();

  /// Called when client listener is listening and ready for client creation.
  Stream<bool> onClientListenerAttached;

  final StreamController<String> _onAddedToConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for added to Conversation event.
  Stream<String> onAddedToConversationNotification;

  final StreamController<Conversation> _onConversationAddedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when the current user has a conversation added to their conversation list, conversation status is not specified.
  Stream<Conversation> onConversationAdded;

  final StreamController<Conversation> _onConversationDeletedCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when one of the conversation of the current user is deleted.
  Stream<Conversation> onConversationDeleted;

  final StreamController<ConnectionState> _onConnectionStateCtrl =
      StreamController<ConnectionState>.broadcast();

  /// Called when client connnection state has changed.
  Stream<ConnectionState> onConnectionState;

  final StreamController<ClientSynchronizationStatus>
      _onClientSynchronizationCtrl =
      StreamController<ClientSynchronizationStatus>.broadcast();

  /// Called when client synchronization status changes.
  Stream<ClientSynchronizationStatus> onClientSynchronization;

  final StreamController<Conversation>
      _onConversationSynchronizationChangeCtrl =
      StreamController<Conversation>.broadcast();

  /// Called when conversation synchronization status changed.
  ///
  /// Use [Conversation.synchronizationStatus] to obtain new conversation status.
  Stream<Conversation> onConversationSynchronizationChange;

  final StreamController<ConversationUpdatedEvent> _onConversationUpdatedCtrl =
      StreamController<ConversationUpdatedEvent>.broadcast();

  /// Called when the conversation is updated.
  ///
  /// [Conversation] synchronization updates are delivered via different callback.
  Stream<ConversationUpdatedEvent> onConversationUpdated;

  final StreamController<ErrorInfo> _onErrorCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when an error condition occurs.
  Stream<ErrorInfo> onError;

  final StreamController<NewMessageNotificationEvent>
      _onNewMessageNotificationCtrl =
      StreamController<NewMessageNotificationEvent>.broadcast();

  /// Called when client receives a push notification for new message.
  Stream<NewMessageNotificationEvent> onNewMessageNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationRegisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  Stream<NotificationRegistrationEvent> onNotificationRegistered;

  final StreamController<String> _onRemovedFromConversationNotificationCtrl =
      StreamController<String>.broadcast();

  /// Called when client receives a push notification for removed from conversation event.
  Stream<String> onRemovedFromConversationNotification;

  final StreamController<NotificationRegistrationEvent>
      _onNotificationDeregisteredCtrl =
      StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  Stream<NotificationRegistrationEvent> onNotificationDeregistered;

  final StreamController<ErrorInfo> _onNotificationFailedCtrl =
      StreamController<ErrorInfo>.broadcast();

  /// Called when registering for push notifications fails.
  Stream<ErrorInfo> onNotificationFailed;

  //#region Token events
  final StreamController<void> _onTokenAboutToExpireCtrl =
      StreamController<void>.broadcast();

  /// Called when token is about to expire soon.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  Stream<void> onTokenAboutToExpire;

  final StreamController<void> _onTokenExpiredCtrl =
      StreamController<void>.broadcast();

  /// Called when token has expired.
  ///
  /// In response, [ConversationClient] should generate a new token and call [ConversationClient.updateToken] as soon as possible.
  Stream<void> onTokenExpired;

  final StreamController<User> _onUserSubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is subscribed to and will receive realtime state updates.
  Stream<User> onUserSubscribed;

  final StreamController<User> _onUserUnsubscribedCtrl =
      StreamController<User>.broadcast();

  /// Called when a user is unsubscribed from and will not receive realtime state updates anymore.
  Stream<User> onUserUnsubscribed;

  final StreamController<UserUpdatedEvent> _onUserUpdatedCtrl =
      StreamController<UserUpdatedEvent>.broadcast();

  /// Called when user info is updated for currently loaded users.
  Stream<UserUpdatedEvent> onUserUpdated;

  ConversationClient() {
    onClientListenerAttached = _onClientListenerAttachedCtrl.stream;
    onAddedToConversationNotification =
        _onAddedToConversationNotificationCtrl.stream;
    onClientSynchronization = _onClientSynchronizationCtrl.stream;
    onConnectionState = _onConnectionStateCtrl.stream;
    onConversationAdded = _onConversationAddedCtrl.stream;
    onConversationDeleted = _onConversationDeletedCtrl.stream;
    onConversationSynchronizationChange =
        _onConversationSynchronizationChangeCtrl.stream;
    onConversationUpdated = _onConversationUpdatedCtrl.stream;
    onError = _onErrorCtrl.stream;
    onNewMessageNotification = _onNewMessageNotificationCtrl.stream;
    onNotificationDeregistered = _onNotificationDeregisteredCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;
    onNotificationRegistered = _onNotificationRegisteredCtrl.stream;
    onRemovedFromConversationNotification =
        _onRemovedFromConversationNotificationCtrl.stream;
    onTokenExpired = _onTokenExpiredCtrl.stream;
    onTokenAboutToExpire = _onTokenAboutToExpireCtrl.stream;
    onUserSubscribed = _onUserSubscribedCtrl.stream;
    onUserUnsubscribed = _onUserUnsubscribedCtrl.stream;
    onUserUpdated = _onUserUpdatedCtrl.stream;

    conversations = Conversations();
    _clientStream = TwilioConversations.clientChannel
        .receiveBroadcastStream(0)
        .listen(_parseEvents);
    _notificationStream = TwilioConversations.notificationChannel
        .receiveBroadcastStream(0)
        .listen(_parseNotificationEvents);
  }

  void updateFromMap(Map<String, dynamic> json) {
    myIdentity = json['myIdentity'] as String;
    connectionState = EnumToString.fromString<ConnectionState>(
        ConnectionState.values, json['connectionState'] as String);
    isReachabilityEnabled = json['isReachabilityEnabled'] as bool;
  }

  /// Updates the authentication token for this client.
  Future<void> updateToken(String token) async {
    try {
      return await TwilioConversations.methodChannel.invokeMethod(
          'ConversationClientMethods.updateToken',
          <String, Object>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Shuts down the conversation client.
  ///
  /// This will dispose() the client after shutdown, so the client cannot be used after this call.
  Future<void> shutdown() async {
    try {
      await _clientStream.cancel();
      await _notificationStream.cancel();
      TwilioConversations.conversationClient = null;
      return await TwilioConversations.methodChannel
          .invokeMethod('ConversationClientMethods.shutdown', null);
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Registers for push notifications. Uses APNs on iOS and FCM on Android.
  ///
  /// Twilio iOS SDK handles receiving messages when app is in the background and displaying
  /// notifications.
  Future<void> registerForNotification(String token) async {
    try {
      await TwilioConversations.methodChannel.invokeMethod(
          'registerForNotification', <String, Object>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Unregisters for push notifications.  Uses APNs on iOS and FCM on Android.
  Future<void> unregisterForNotification(String token) async {
    try {
      await TwilioConversations.methodChannel.invokeMethod(
          'unregisterForNotification', <String, Object>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioConversations.convertException(err);
    }
  }

  /// Parse native conversation client events to the right event streams.
  void _parseEvents(dynamic event) {
    var eventMap = jsonDecode(event.toString());
    final String eventName = eventMap['name'] as String;
    final data = Map<String, dynamic>.from(eventMap['data'] as Map ?? {});

    if (data['conversationClient'] != null) {
      final conversationClientMap =
          data['conversationClient'] as Map<String, dynamic>;
      updateFromMap(conversationClientMap);
    }

    ErrorInfo exception;
    if (eventMap['error'] != null) {
      final errorMap =
          Map<String, dynamic>.from(eventMap['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int,
          errorMap['message'] as String, errorMap['status'] as int);
    }

    var conversationSid = data['conversationSid'] as String;

    Map<String, dynamic> conversationMap;
    if (data['conversation'] != null) {
      conversationMap = Map<String, dynamic>.from(
          data['conversation'] as Map<dynamic, dynamic>);
      conversationSid = conversationMap['sid'] as String;
    }

    Map<String, dynamic> userMap;
    if (data['user'] != null) {
      // userMap = Map<String, dynamic>.from(data['user'] as Map<dynamic, dynamic>);
    }
    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap =
          Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      if (reasonMap['type'] == 'conversation') {
        reason = EnumToString.fromString(
            ConversationUpdateReason.values, reasonMap['value'] as String);
      } else if (reasonMap['type'] == 'user') {
        reason = EnumToString.fromString(
            UserUpdateReason.values, reasonMap['value'] as String);
      }
    }

    switch (eventName) {
      case 'clientListenerAttached':
        _onClientListenerAttachedCtrl.add(true);
        break;
      case 'addedToConversationNotification':
        assert(conversationSid != null);
        _onAddedToConversationNotificationCtrl.add(conversationSid);
        break;
      case 'conversationAdded':
        assert(conversationMap != null);
        assert(conversationSid != null);
        Conversations.updateConversationFromMap(conversationMap);
        _onConversationAddedCtrl
            .add(Conversations.conversationsMap[conversationSid]);
        break;
      case 'conversationDeleted':
        assert(conversationMap != null);
        assert(conversationSid != null);
        final conversation = Conversations.conversationsMap[conversationSid];
        Conversations.conversationsMap.remove(conversationSid);
        _onConversationDeletedCtrl.add(conversation);
        break;
      case 'conversationSynchronizationChange':
        assert(conversationMap != null);
        assert(conversationSid != null);
        Conversations.updateConversationFromMap(conversationMap);
        _onConversationSynchronizationChangeCtrl
            .add(Conversations.conversationsMap[conversationSid]);
        break;
      case 'conversationUpdated':
        assert(conversationMap != null);
        assert(reason != null);
        assert(conversationSid != null);
        Conversations.updateConversationFromMap(conversationMap);
        _onConversationUpdatedCtrl.add(ConversationUpdatedEvent(
          Conversations.conversationsMap[conversationSid],
          reason as ConversationUpdateReason,
        ));
        break;
      case 'clientSynchronization':
        var synchronizationStatus = EnumToString.fromString(
            ClientSynchronizationStatus.values,
            data['synchronizationStatus'] as String);
        assert(synchronizationStatus != null);
        _onClientSynchronizationCtrl.add(synchronizationStatus);
        break;
      case 'connectionStateChange':
        var newConnectionState = EnumToString.fromString(
            ConnectionState.values, data['connectionState'] as String);
        assert(newConnectionState != null);
        connectionState = newConnectionState;
        _onConnectionStateCtrl.add(newConnectionState);
        break;
      case 'error':
        assert(exception != null);
        _onErrorCtrl.add(exception);
        break;
      case 'newMessageNotification':
        var messageSid = data['messageSid'] as String;
        var messageIndex = data['messageIndex'] as int;
        assert(conversationSid != null);
        assert(messageSid != null);
        assert(messageIndex != null);
        _onNewMessageNotificationCtrl.add(NewMessageNotificationEvent(
            conversationSid, messageSid, messageIndex));
        break;
      case 'notificationFailed':
        assert(exception != null);
        _onNotificationFailedCtrl.add(exception);
        break;
      case 'removedFromConversationNotification':
        assert(conversationSid != null);
        _onRemovedFromConversationNotificationCtrl.add(conversationSid);
        break;
      case 'tokenAboutToExpire':
        _onTokenAboutToExpireCtrl.add(null);
        break;
      case 'tokenExpired':
        _onTokenExpiredCtrl.add(null);
        break;
      case 'userSubscribed':
        //assert(userMap != null);
        // users._updateFromMap({
        //   'subscribedUsers': [userMap]
        // });
        //_onUserSubscribedCtrl.add(User.fromJson(userMap));
        break;
      case 'userUnsubscribed':
        //TODO Fix
        // assert(userMap != null);
        // var user = users.getUserById(userMap['identity']);
        // user._updateFromMap(userMap);
        // users.subscribedUsers.removeWhere((u) => u.identity == userMap['identity']);
        _onUserUnsubscribedCtrl.add(User.fromJson(userMap));
        break;
      case 'userUpdated':
        assert(userMap != null);
        assert(reason != null);
        // users._updateFromMap({
        //   'subscribedUsers': [userMap]
        // });
        _onUserUpdatedCtrl.add(UserUpdatedEvent(
            User.fromJson(userMap), reason as UserUpdateReason));
        break;
      default:
        TwilioConversations.log("Event '$eventName' not yet implemented");
        break;
    }
  }

  /// Parse notification events to the right event streams.
  void _parseNotificationEvents(dynamic event) {
    final jsonMap = jsonDecode(event.toString()) as Map<String, dynamic>;
    final eventName = jsonMap['name'] as String;
    TwilioConversations.log(
        "ConversationClient => Event '$eventName' => ${jsonMap["data"]}, error: ${jsonMap["error"]}");
    final data =
        Map<String, dynamic>.from(jsonMap['data'] as Map<String, dynamic>);

    ErrorInfo exception;
    if (jsonMap['error'] != null) {
      final errorMap =
          Map<String, dynamic>.from(jsonMap['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int,
          errorMap['message'] as String, errorMap['status'] as int);
    }

    switch (eventName) {
      case 'registered':
        _onNotificationRegisteredCtrl.add(
            NotificationRegistrationEvent(data['result'] as bool, exception));
        break;
      case 'deregistered':
        _onNotificationDeregisteredCtrl.add(
            NotificationRegistrationEvent(data['result'] as bool, exception));
        break;
      default:
        TwilioConversations.log(
            "Notification event '$eventName' not yet implemented");
        break;
    }
  }
}
