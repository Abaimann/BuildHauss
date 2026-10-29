import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/features/parts/domain/sparepart_image_helper.dart';

void main() {
  group('SparepartImageHelper Tests', () {
    test('Maps exact categories to local webp assets', () {
      expect(
        SparepartImageHelper.getAssetPath('oli_mesin'),
        'assets/images/parts/oli_mesin.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('kampas_rem'),
        'assets/images/parts/kampas_rem.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('busi'),
        'assets/images/parts/busi.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('aki'),
        'assets/images/parts/aki.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('ban'),
        'assets/images/parts/ban.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('cvt'),
        'assets/images/parts/cvt.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('rantai'),
        'assets/images/parts/rantai.webp',
      );
    });

    test('Keyword-based fallback for name and category combinations', () {
      expect(
        SparepartImageHelper.getAssetPath('general', 'Oli MPX2 Honda'),
        'assets/images/parts/oli_mesin.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('unknown', 'Kampas Rem Belakang'),
        'assets/images/parts/kampas_rem.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('unknown', 'Air Radiator Prestone Coolant'),
        'assets/images/parts/radiator_coolant.webp',
      );
      expect(
        SparepartImageHelper.getAssetPath('custom', 'Shockbreaker Tabung Showa'),
        'assets/images/parts/shockbreaker.webp',
      );
    });

    test('Returns null for completely unknown non-motorcycle sparepart', () {
      expect(
        SparepartImageHelper.getAssetPath('elektronik_laptop', 'Mouse Gaming RGB'),
        isNull,
      );
    });
  });
}
