import 'package:jetleaf_lang/lang.dart';
import 'package:test/test.dart';

class TestUser {
  final String name;
  TestUser(this.name);
}

void helperMethod() {}

void main() {
  group('DefaultClassPathResource (real fixture)', () {
    late DefaultClassPathResource resource;

    setUpAll(() async {
      await runTestScan();
      resource = DefaultClassPathResource("test/meta/class_path_resource_test.dart");
    });

    test('getPackage returns correct package', () {
      final pkg = resource.getPackage();
      expect(pkg.getName(), isNotEmpty); // should resolve to test package
    });

    test('getClass(Type) resolves our TestUser class', () {
      final cls = resource.getClass(TestUser);
      expect(cls.getSimpleName(), equals('TestUser'));
    });

    test('getClasses contains our TestUser class', () {
      final classes = resource.getClasses();
      final names = classes.map((c) => c.getSimpleName()).toList();
      expect(names, contains('TestUser'));
    });

    test('getMethod resolves helperMethod', () {
      final method = resource.getMethod('helperMethod');
      expect(method.getName(), equals('helperMethod'));
    });

    test('getMethods contains helperMethod', () {
      final methods = resource.getMethods().map((m) => m.getName()).toList();
      expect(methods, contains('helperMethod'));
    });

    test('getInputStream reads source file bytes', () async {
      final stream = resource.getInputStream();
      final chunks = await stream.readAll();
      final total = chunks.fold<int>(0, (a, b) => a + b.length);
      expect(total, greaterThan(0));
    });

    test('getClass throws for unknown type', () {
      expect(() => resource.getClass(String), throwsA(isA<IllegalStateException>()));
    });

    test('getMethod throws for unknown method', () {
      expect(() => resource.getMethod('definitelyNotAMethod'),
          throwsA(isA<IllegalStateException>()));
    });
  });
}