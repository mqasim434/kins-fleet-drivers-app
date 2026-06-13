import 'package:flutter_test/flutter_test.dart';
import 'package:kins_fleet_drivers/main.dart';

void main() {
  testWidgets('shows Firebase ready screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KinsFleetDriversApp());

    expect(find.text('Firebase geïnitialiseerd'), findsOneWidget);
    expect(find.text('Project: kins-fleet-app'), findsOneWidget);
  });
}
