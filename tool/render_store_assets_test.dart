// Renders the Google Play icon, feature graphic and phone screenshots into
// build/store/ from the real screens with made-up sample nights. Run from the
// project root after changing the UI or the launcher mark:
//   flutter test tool/render_store_assets_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/app/lucid_app.dart';
import 'package:lucid/l10n/l10n.dart';

import '../test/fake_channels.dart';
import 'rgb_png.dart';

const _outDir = 'build/store';

void main() {
  setUpAll(() async {
    await _loadFonts();
    Directory(_outDir).createSync(recursive: true);
  });

  test('play store icon', () async {
    // 512 x 512, full bleed: Google Play rounds the corners itself. Shows the
    // adaptive icon's visible 72 dp middle, like a launcher.
    const size = 512;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(size / 72)
      ..translate(-18, -18);
    _paintMark(canvas, withSky: true);
    final image = await recorder.endRecording().toImage(size, size);
    await _writePng(image, 'play_icon_512');
  });

  testWidgets('feature graphic', (tester) async {
    // Google Play wants exactly 1024 x 500 px.
    await _render(
      tester,
      'feature_graphic',
      const _FeatureGraphic(),
      size: const Size(512, 250),
      pixelRatio: 2,
    );
  });

  for (final locale in const [Locale('en'), Locale('uk')]) {
    final l10n = lookupAppLocalizations(locale);
    Future<void> shot(
      WidgetTester tester,
      String name, {
      Future<void> Function()? act,
      Brightness brightness = Brightness.light,
    }) async {
      _fakeNative();
      tester.platformDispatcher.localesTestValue = [locale];
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await _render(
        tester,
        '${locale.languageCode}_$name',
        const LucidApp(),
        // 9:16, 1080 x 1920 px.
        size: const Size(360, 640),
        pixelRatio: 3,
        act: act,
      );
    }

    testWidgets('${locale.languageCode} home', (tester) async {
      await shot(tester, '1_home');
    });

    testWidgets('${locale.languageCode} window', (tester) async {
      await shot(
        tester,
        '2_window',
        act: () => tester.tap(find.text(l10n.alarmEdit)),
      );
    });

    testWidgets('${locale.languageCode} nights', (tester) async {
      await shot(
        tester,
        '3_nights',
        act: () => tester.tap(find.byTooltip(l10n.sleepTooltip)),
      );
    });

    testWidgets('${locale.languageCode} setup', (tester) async {
      await shot(
        tester,
        '4_setup',
        act: () => tester.tap(find.byTooltip(l10n.setupTooltip)),
      );
    });

    testWidgets('${locale.languageCode} home dark', (tester) async {
      await shot(tester, '5_home_dark', brightness: Brightness.dark);
    });
  }
}

/// The launcher mark in its 108-unit adaptive-icon space; the same shapes as
/// android/app/src/main/res/drawable/ic_launcher_*.xml.
void _paintMark(Canvas canvas, {required bool withSky}) {
  if (withSky) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 108, 108),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(54, 0),
          const Offset(54, 108),
          [const Color(0xFF4A3DB8), const Color(0xFF16123F)],
        ),
    );
  }
  final moon = Path.combine(
    PathOperation.difference,
    Path()..addOval(Rect.fromCircle(center: const Offset(52, 46), radius: 20)),
    Path()..addOval(Rect.fromCircle(center: const Offset(60, 40), radius: 17)),
  );
  canvas
    ..drawPath(moon, Paint()..color = const Color(0xFFFFF2D6))
    ..drawPath(
      Path()
        ..moveTo(33, 77)
        ..cubicTo(38, 71, 43, 71, 47.5, 76)
        ..cubicTo(52, 81, 57, 81, 61.5, 76)
        ..cubicTo(64.5, 72.5, 67, 71.5, 69.5, 71.5),
      Paint()
        ..color = const Color(0xFFB9B2FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    )
    ..drawCircle(
      const Offset(69.5, 71.5),
      3.8,
      Paint()..color = const Color(0xFFFFC56B),
    );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 72)
      ..translate(-18, -18);
    _paintMark(canvas, withSky: false);
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}

/// The feature graphic: the mark, the name and the promise on the night sky.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A3DB8), Color(0xFF16123F)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 150,
                child: CustomPaint(painter: _MarkPainter()),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lucid',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 52,
                        color: Color(0xFFFFF2D6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Galaxy Watch wakes you in your lightest sleep',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 22,
                        height: 1.3,
                        color: const Color(0xFFFFFFFF).withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ready phone and watch, and three past nights with Samsung's stages, all
/// relative to now so the screens read as "last night".
void _fakeNative() {
  final reply = alarmStateReply();
  final watch = reply['watch']! as Map<String, Object?>;
  final status = watch['status']! as Map<String, Object?>;
  status['heartRate'] = true;
  final phone = reply['phone']! as Map<String, Object?>;
  phone['batteryUnrestricted'] = true;

  final today = DateTime.now();
  final samsung = <Object?>[];
  final watchNights = <Object?>[];
  for (var daysAgo = 0; daysAgo < 3; daysAgo++) {
    final morning = DateTime(today.year, today.month, today.day - daysAgo);
    final bed = morning.subtract(Duration(minutes: 55 + daysAgo * 20));
    final wake = morning.add(Duration(hours: 6, minutes: 38 - daysAgo * 6));
    samsung.add(_night(bed, wake, score: 84 - daysAgo * 5));
    watchNights.add({
      'windowStart': morning.add(const Duration(hours: 6, minutes: 30)).ms,
      'windowEnd': morning.add(const Duration(hours: 7)).ms,
      'trackingStart': morning.add(const Duration(hours: 6)).ms,
      'wokeAt': wake.ms,
      'reason': 'LIGHT_SLEEP',
      'dismissedAt': wake.add(const Duration(minutes: 1)).ms,
      'epochs': <Object?>[],
    });
  }

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger
    ..setMockMethodCallHandler(
      const MethodChannel('lucid/alarm'),
      (call) async => call.method == 'getState' ? reply : null,
    )
    ..setMockMethodCallHandler(
      const MethodChannel('lucid/sleep'),
      (call) async => switch (call.method) {
        'status' => 'ready',
        'watchNights' => watchNights,
        'readSleep' => samsung,
        _ => null,
      },
    );
}

/// About four sleep cycles from [bed] to [wake], ending in light sleep.
Map<String, Object?> _night(DateTime bed, DateTime wake, {required int score}) {
  const cycle = [
    ('light', 25),
    ('deep', 40),
    ('light', 20),
    ('rem', 15),
    ('light', 12),
    ('deep', 25),
    ('light', 18),
    ('rem', 22),
    ('awake', 4),
    ('light', 30),
    ('deep', 15),
    ('light', 20),
    ('rem', 28),
    ('light', 26),
    ('rem', 30),
    ('light', 20),
    ('deep', 10),
    ('light', 25),
    ('rem', 35),
  ];
  final stages = <Object?>[];
  var at = bed;
  for (final (stage, minutes) in cycle) {
    final end = at.add(Duration(minutes: minutes));
    if (!end.isBefore(wake)) break;
    stages.add({'start': at.ms, 'end': end.ms, 'stage': stage});
    at = end;
  }
  stages.add({'start': at.ms, 'end': wake.ms, 'stage': 'light'});
  return {
    'start': bed.ms,
    'end': wake.ms,
    'score': score,
    'sessions': [
      {'start': bed.ms, 'end': wake.ms, 'stages': stages},
    ],
  };
}

extension on DateTime {
  int get ms => millisecondsSinceEpoch;
}

Future<void> _render(
  WidgetTester tester,
  String name,
  Widget app, {
  required Size size,
  required double pixelRatio,
  Future<void> Function()? act,
}) async {
  tester.view
    ..physicalSize = size * pixelRatio
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  final boundary = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundary,
      child: ProviderScope(retry: (_, _) => null, child: app),
    ),
  );
  await tester.pumpAndSettle();
  if (act != null) {
    await act();
    await tester.pumpAndSettle();
  }
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary)
            .toImage(pixelRatio: pixelRatio);
    await _writePng(image, name);
  });
}

/// Google Play wants 24-bit PNGs, so the alpha channel is dropped.
Future<void> _writePng(ui.Image image, String name) async {
  final rgba = await image.toByteData();
  final png = encodeRgbPng(
    rgba!.buffer.asUint8List(),
    image.width,
    image.height,
  );
  await File('$_outDir/$name.png').writeAsBytes(png);
}

/// Roboto and the Material icons ship with the Flutter SDK next to
/// flutter_tester; widget tests otherwise draw every glyph as a box.
Future<void> _loadFonts() async {
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  Future<ByteData> font(String file) async => ByteData.sublistView(
    await File('${artifacts.path}/material_fonts/$file').readAsBytes(),
  );
  await (FontLoader('Roboto')
        ..addFont(font('roboto-regular.ttf'))
        ..addFont(font('roboto-medium.ttf'))
        ..addFont(font('roboto-bold.ttf')))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(font('materialicons-regular.otf'))).load();
}
