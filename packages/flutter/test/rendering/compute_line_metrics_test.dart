import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('RenderParagraph.computeLineMetrics returns valid metrics', () {
    const String text = 'Hello world!\nThis is line two.';

    final RenderParagraph paragraph = RenderParagraph(
      const TextSpan(text: text),
      textDirection: TextDirection.ltr,
    );

    paragraph.layout(const BoxConstraints(maxWidth: 200));

    final List<LineMetrics> metrics = paragraph.computeLineMetrics();

    expect(metrics, isNotEmpty);

    for (final LineMetrics m in metrics) {
      expect(m.lineNumber, greaterThanOrEqualTo(0));
      expect(m.width, greaterThan(0));
      expect(m.height, greaterThan(0));
    }
  });
}
