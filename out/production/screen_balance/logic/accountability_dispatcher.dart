import 'dart:async';
import 'package:flutter/material.dart';
import 'intervention_engine.dart';
import '../models/boundary_settings.dart';

class AccountabilityAlert {
  final DateTime timestamp;
  final String recipient;
  final String message;

  AccountabilityAlert({
    required this.timestamp,
    required this.recipient,
    required this.message,
  });
}

class AccountabilityDispatcher {
  static final AccountabilityDispatcher _instance = AccountabilityDispatcher._internal();
  factory AccountabilityDispatcher() => _instance;
  AccountabilityDispatcher._internal();

  final List<AccountabilityAlert> dispatchLogs = [];
  StreamSubscription? _subscription;

  void startListening() {
    _subscription?.cancel();
    _subscription = InterventionEngine().eventBusStream.stream.listen((event) {
      _handleEvent(event);
    });
  }

  Future<void> _handleEvent(String event) async {
    final settings = await BoundarySettings.loadFromStorage();
    if (settings.accountabilityContacts.isEmpty) {
      return; // No accountability contacts configured
    }

    final now = DateTime.now();
    final primaryPartner = settings.accountabilityContacts.first;

    if (event.startsWith("EVENT_INTERVENTION_TRIGGERED:")) {
      final triggerId = event.substring("EVENT_INTERVENTION_TRIGGERED:".length);
      final msg = "Alert: Primary user triggered a '$triggerId' boundary event. Mirroring notification in real-time.";
      
      dispatchLogs.add(AccountabilityAlert(
        timestamp: now,
        recipient: primaryPartner,
        message: msg,
      ));
      debugPrint("DISPATCHED: $msg to $primaryPartner");
    } else if (event.startsWith("EVENT_PROFILE_UPDATED:")) {
      final transition = event.substring("EVENT_PROFILE_UPDATED:".length);
      final msg = "Weekly Update: User's psychological intention baseline shifted: $transition. Setting parameters modified.";
      
      dispatchLogs.add(AccountabilityAlert(
        timestamp: now,
        recipient: primaryPartner,
        message: msg,
      ));
      debugPrint("DISPATCHED: $msg to $primaryPartner");
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }
}
