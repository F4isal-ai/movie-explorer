
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_explorer/main.dart';

void main() {
  testWidgets('Movie Explorer menampilkan judul aplikasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MovieExplorerApp());

    expect(find.text('Movie Explorer'), findsOneWidget);
  });
}
