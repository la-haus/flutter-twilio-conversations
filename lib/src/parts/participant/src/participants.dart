import 'dart:async';
import 'dart:convert';

import 'package:twilio_conversations/twilio_conversations.dart';

class Participants {
  final String conversationSid;

  Participants({this.conversationSid});

  Future<bool> addParticipantByIdentity(String identity) async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ParticipantsMethods.addParticipantByIdentity',
        {'identity': identity, 'conversationSid': conversationSid});

    return result;
  }

  Future<bool> removeParticipantByIdentity(String identity) async {
    final result = await TwilioConversations.methodChannel.invokeMethod<bool>(
        'ParticipantsMethods.removeParticipantByIdentity',
        {'identity': identity, 'conversationSid': conversationSid});

    return result;
  }

  Future<List<Participant>> getParticipantsList() async {
    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ParticipantsMethods.getParticipantsList',
        {'conversationSid': conversationSid});

    var participants = (jsonDecode(result.toString()) as List)
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();
    return participants;
  }

  Future<List<User>> getUsers() async {
    final result = await TwilioConversations.methodChannel.invokeMethod(
        'ParticipantsMethods.getUsers', {'conversationSid': conversationSid});

    var users = (jsonDecode(result.toString()) as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();

    return users;
  }
}
