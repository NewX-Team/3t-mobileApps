import 'package:flutter_test/flutter_test.dart';
import 'package:layanan_masyarakat3t/features/splash/splash_screen.dart';
import 'package:layanan_masyarakat3t/main.dart';

void main() {
  testWidgets('Splash screen loads properly', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Verify SplashScreen is loaded
    expect(find.byType(SplashScreen), findsOneWidget);

    // Pump frames to advance animation
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('LAYANAN MASYARAKAT 3T'), findsOneWidget);
  });
}
