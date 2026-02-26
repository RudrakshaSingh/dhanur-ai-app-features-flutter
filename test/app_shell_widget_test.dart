import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:dhanur_ai_app_features_flutter/app/app_shell.dart';
import 'package:dhanur_ai_app_features_flutter/core/types/permission_state.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/application/live_captioning_controller.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/domain/live_captioning_state.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/domain/speech_event.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/domain/speech_recognition_service.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/presentation/live_captioning_screen.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/application/mic_control_controller.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/domain/mic_control_state.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/domain/microphone_service.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/presentation/mic_control_screen.dart';
import 'package:dhanur_ai_app_features_flutter/features/player/presentation/widgets/speed_control.dart';

void main() {
  testWidgets('App shell renders tab labels and preserves tab state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          screens: const [
            _CounterTab(label: 'Live Caption'),
            _CounterTab(label: 'Mic Control'),
            _CounterTab(label: 'Player'),
          ],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.mic_none), label: 'Live Caption'),
            BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Mic Control'),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Player'),
          ],
        ),
      ),
    );

    expect(find.text('Live Caption'), findsOneWidget);
    expect(find.text('Mic Control'), findsOneWidget);
    expect(find.text('Player'), findsOneWidget);

    await tester.tap(find.byKey(const Key('counter_button_Live Caption')));
    await tester.pumpAndSettle();
    expect(find.text('Live Caption count: 1'), findsOneWidget);

    await tester.tap(find.text('Mic Control'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Live Caption'));
    await tester.pumpAndSettle();

    expect(find.text('Live Caption count: 1'), findsOneWidget);
  });

  testWidgets('Live caption clear button is disabled when transcript is empty', (
    tester,
  ) async {
    final fakeController = _FakeLiveCaptioningController(
      const LiveCaptioningState(
        isListening: false,
        finalized: [],
        interim: '',
        micPermission: PermissionState.granted,
        error: null,
        isAvailable: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          liveCaptioningControllerProvider.overrideWith((ref) => fakeController),
        ],
        child: const MaterialApp(home: LiveCaptioningScreen()),
      ),
    );

    final clearButton = tester.widget<TextButton>(
      find.byKey(const Key('live_caption_clear_button')),
    );
    expect(clearButton.onPressed, isNull);
  });

  testWidgets('Mic screen shows request permission button when denied', (tester) async {
    final fakeController = _FakeMicControlController(
      const MicControlState(
        micPermission: PermissionState.denied,
        isMicEnabled: false,
        inputLevel: 0,
        permissionMessage: 'Microphone permission denied',
        error: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          micControlControllerProvider.overrideWith((ref) => fakeController),
        ],
        child: const MaterialApp(home: MicControlScreen()),
      ),
    );

    expect(find.byKey(const Key('mic_request_permission_button')), findsOneWidget);
  });

  testWidgets('Speed control highlights the selected speed', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _SpeedControlHarness()));

    expect(find.byKey(const Key('speed_active_1.0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('speed_button_1.5')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('speed_active_1.5')), findsOneWidget);
    expect(find.byKey(const Key('speed_inactive_1.0')), findsOneWidget);
  });
}

class _CounterTab extends StatefulWidget {
  const _CounterTab({required this.label});

  final String label;

  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${widget.label} count: $_count'),
          ElevatedButton(
            key: Key('counter_button_${widget.label}'),
            onPressed: () {
              setState(() {
                _count += 1;
              });
            },
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

class _SpeedControlHarness extends StatefulWidget {
  const _SpeedControlHarness();

  @override
  State<_SpeedControlHarness> createState() => _SpeedControlHarnessState();
}

class _SpeedControlHarnessState extends State<_SpeedControlHarness> {
  double _speed = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpeedControl(
        currentSpeed: _speed,
        onSpeedChange: (speed) async {
          setState(() {
            _speed = speed;
          });
        },
      ),
    );
  }
}

class _FakeLiveCaptioningController extends LiveCaptioningController {
  _FakeLiveCaptioningController(LiveCaptioningState initial)
    : super(speechService: _StubSpeechRecognitionService()) {
    state = initial;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> toggleListening() async {}

  @override
  void clearCaptions() {}
}

class _StubSpeechRecognitionService implements SpeechRecognitionService {
  @override
  Future<PermissionState> checkPermission() async => PermissionState.granted;

  @override
  Future<void> dispose() async {}

  @override
  Stream<SpeechEvent> events() => Stream<SpeechEvent>.empty();

  @override
  Future<bool> initialize() async => true;

  @override
  Future<PermissionState> requestPermission() async => PermissionState.granted;

  @override
  Future<void> start({
    required String localeId,
    required bool partialResults,
  }) async {}

  @override
  Future<void> stop() async {}
}

class _FakeMicControlController extends MicControlController {
  _FakeMicControlController(MicControlState initial)
    : super(microphoneService: _StubMicrophoneService()) {
    state = initial;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> refreshPermissionStatus() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> toggleMicrophone() async {}

  @override
  Future<void> enableMicrophone() async {}

  @override
  Future<void> releaseMicrophone() async {}
}

class _StubMicrophoneService implements MicrophoneService {
  @override
  Future<PermissionState> checkPermission() async => PermissionState.granted;

  @override
  Future<void> dispose() async {}

  @override
  Stream<double> inputLevel() => Stream<double>.empty();

  @override
  Future<PermissionState> requestPermission() async => PermissionState.granted;

  @override
  Future<void> startCapture() async {}

  @override
  Future<void> stopCapture() async {}
}
