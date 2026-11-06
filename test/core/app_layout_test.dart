import 'package:bilimusic/core/layout/app_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool enabled in [false, true]) {
    test('desktop never uses car mode, enabled=$enabled', () {
      for (final size in [
        const Size(959, 600),
        const Size(960, 600),
        const Size(1200, 1800),
      ]) {
        expect(
          AppLayout.resolve(size: size, isDesktop: true, carEnabled: enabled),
          size.width < 960 ? AppLayout.mobile : AppLayout.desktop,
        );
      }
    });
    test(
      'mobile car mode requires preference and landscape, enabled=$enabled',
      () {
        for (final size in [
          const Size(390, 844),
          const Size(844, 390),
          const Size(600, 600),
        ]) {
          expect(
            AppLayout.resolve(
              size: size,
              isDesktop: false,
              carEnabled: enabled,
            ),
            enabled && size.width > size.height
                ? AppLayout.car
                : AppLayout.mobile,
          );
        }
      },
    );
  }
}
