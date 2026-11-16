import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aula14_gps/main.dart';

void main() {
  testWidgets('App renders GeolocalizacaoScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuApp());

    expect(find.text('Check-in & GPS'), findsOneWidget);
    expect(find.text('Capturar Localização Atual'), findsOneWidget);
  });
}
