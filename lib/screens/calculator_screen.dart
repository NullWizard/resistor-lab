import 'package:flutter/material.dart';
import '../services/resistor_scanner_service.dart';

/// Screen for the Resistor Color Code Calculator.
///
/// Supports 4-band, 5-band, and 6-band resistors:
/// - 4-Band: (Band 1 * 10 + Band 2) * Multiplier, Tolerance
/// - 5-Band: (Band 1 * 100 + Band 2 * 10 + Band 3) * Multiplier, Tolerance
/// - 6-Band: (Band 1 * 100 + Band 2 * 10 + Band 3) * Multiplier, Tolerance, TempCo
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Available color sets from ResistorScannerService
  static const List<ResistorBandInfo> _digitColors = ResistorScannerService.digitColors;
  static const List<ResistorBandInfo> _multiplierColors = ResistorScannerService.multiplierColors;
  static const List<ResistorBandInfo> _toleranceColors = ResistorScannerService.toleranceColors;
  static const List<ResistorBandInfo> _tempCoColors = ResistorScannerService.tempCoColors;

  // Selected number of bands (4, 5, or 6; default: 4)
  int _bandCount = 4;

  // Selected band indices
  int _band1Index = 1; // Brown (1)
  int _band2Index = 7; // Violet (7)
  int _band3DigitIndex = 0; // Black (0) for 5/6-band
  int _multiplierIndex = 2; // Red (×100)
  int _toleranceIndex = 2; // Gold (±5%) for 4-band
  int _tempCoIndex = 0; // Brown (100 ppm/K) for 6-band

  /// Resets selections back to default reference values.
  void _resetCalculator() {
    setState(() {
      if (_bandCount == 4) {
        _band1Index = 1; // Brown
        _band2Index = 7; // Violet
        _multiplierIndex = 2; // Red
        _toleranceIndex = 2; // Gold
      } else {
        _band1Index = 1; // Brown
        _band2Index = 0; // Black
        _band3DigitIndex = 0; // Black
        _multiplierIndex = 2; // Red
        _toleranceIndex = 0; // Brown (±1%)
        _tempCoIndex = 0; // Brown (100 ppm/K)
      }
    });
  }

  /// Formats integer ohms with thousands separators for clarity in viva explanations.
  String _formatRawOhms(double ohms) {
    if (ohms == ohms.roundToDouble() && ohms < 1e12) {
      final intVal = ohms.round();
      final str = intVal.toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    }
    String s = ohms.toStringAsFixed(3);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Compute calculation result using unified ResistorScannerService
    final ResistorCalculationResult calc;
    if (_bandCount == 4) {
      calc = ResistorScannerService.calculate(
        bandCount: 4,
        band1Index: _band1Index,
        band2Index: _band2Index,
        band3Index: _multiplierIndex,
        band4Index: _toleranceIndex,
      );
    } else if (_bandCount == 5) {
      calc = ResistorScannerService.calculate(
        bandCount: 5,
        band1Index: _band1Index,
        band2Index: _band2Index,
        band3Index: _band3DigitIndex,
        band4Index: _multiplierIndex,
        band5Index: _toleranceIndex,
      );
    } else {
      calc = ResistorScannerService.calculate(
        bandCount: 6,
        band1Index: _band1Index,
        band2Index: _band2Index,
        band3Index: _band3DigitIndex,
        band4Index: _multiplierIndex,
        band5Index: _toleranceIndex,
        band6Index: _tempCoIndex,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Code Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Calculator',
            onPressed: _resetCalculator,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Number of Bands Selector
                  _buildBandCountSelector(theme),
                  const SizedBox(height: 14),

                  // Visual Resistor Graphic Card
                  _buildResistorVisualizerCard(context),
                  const SizedBox(height: 16),

                  // Calculation Results Card
                  _buildResultsCard(context, calc),
                  const SizedBox(height: 20),

                  // Section Title for Band Selectors
                  Text(
                    'Select Resistor Bands',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Band Dropdowns
                  ..._buildDynamicBandDropdowns(),
                  const SizedBox(height: 18),

                  // Reset Action Button
                  OutlinedButton.icon(
                    onPressed: _resetCalculator,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(
                      _bandCount == 4
                          ? 'Reset to Default (1.7 kΩ)'
                          : 'Reset to Default (10 kΩ)',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Number of Bands selector with choices 4, 5, 6.
  Widget _buildBandCountSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Bands',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 4, label: Text('4')),
              ButtonSegment<int>(value: 5, label: Text('5')),
              ButtonSegment<int>(value: 6, label: Text('6')),
            ],
            selected: {_bandCount},
            onSelectionChanged: (newSelection) {
              setState(() {
                final prev = _bandCount;
                _bandCount = newSelection.first.clamp(4, 6);
                if (prev == 4 && _bandCount >= 5) {
                  _band2Index = 0; // Black
                  _band3DigitIndex = 0; // Black
                  _toleranceIndex = 0; // Brown (±1%)
                } else if (prev >= 5 && _bandCount == 4) {
                  _band2Index = 7; // Violet
                  _toleranceIndex = 2; // Gold (±5%)
                }
                _band1Index = _band1Index.clamp(0, _digitColors.length - 1);
                _band2Index = _band2Index.clamp(0, _digitColors.length - 1);
                _band3DigitIndex = _band3DigitIndex.clamp(0, _digitColors.length - 1);
                _multiplierIndex = _multiplierIndex.clamp(0, _multiplierColors.length - 1);
                _toleranceIndex = _toleranceIndex.clamp(0, _toleranceColors.length - 1);
                _tempCoIndex = _tempCoIndex.clamp(0, _tempCoColors.length - 1);
              });
            },
          ),
        ),
      ],
    );
  }

  /// Generates the appropriate band dropdowns based on _bandCount.
  List<Widget> _buildDynamicBandDropdowns() {
    final list = <Widget>[];

    // Band 1: 1st Digit
    list.add(
      _buildDigitDropdown(
        label: 'Band 1: 1st Digit',
        value: _band1Index,
        onChanged: (newVal) {
          if (newVal != null) setState(() => _band1Index = newVal);
        },
      ),
    );
    list.add(const SizedBox(height: 12));

    // Band 2: 2nd Digit
    list.add(
      _buildDigitDropdown(
        label: 'Band 2: 2nd Digit',
        value: _band2Index,
        onChanged: (newVal) {
          if (newVal != null) setState(() => _band2Index = newVal);
        },
      ),
    );
    list.add(const SizedBox(height: 12));

    if (_bandCount >= 5) {
      // Band 3: 3rd Digit (for 5 and 6 bands)
      list.add(
        _buildDigitDropdown(
          label: 'Band 3: 3rd Digit',
          value: _band3DigitIndex,
          onChanged: (newVal) {
            if (newVal != null) setState(() => _band3DigitIndex = newVal);
          },
        ),
      );
      list.add(const SizedBox(height: 12));

      // Band 4: Multiplier
      list.add(
        _buildMultiplierDropdown(
          label: 'Band 4: Multiplier',
          value: _multiplierIndex,
          onChanged: (newVal) {
            if (newVal != null) setState(() => _multiplierIndex = newVal);
          },
        ),
      );
      list.add(const SizedBox(height: 12));

      // Band 5: Tolerance
      list.add(
        _buildToleranceDropdown(
          label: 'Band 5: Tolerance',
          value: _toleranceIndex,
          onChanged: (newVal) {
            if (newVal != null) setState(() => _toleranceIndex = newVal);
          },
        ),
      );
      list.add(const SizedBox(height: 12));

      if (_bandCount == 6) {
        // Band 6: Temperature Coefficient
        list.add(
          _buildTempCoDropdown(
            label: 'Band 6: Temperature Coefficient',
            value: _tempCoIndex,
            onChanged: (newVal) {
              if (newVal != null) setState(() => _tempCoIndex = newVal);
            },
          ),
        );
      }
    } else {
      // 4-Band: Band 3 = Multiplier, Band 4 = Tolerance
      list.add(
        _buildMultiplierDropdown(
          label: 'Band 3: Multiplier',
          value: _multiplierIndex,
          onChanged: (newVal) {
            if (newVal != null) setState(() => _multiplierIndex = newVal);
          },
        ),
      );
      list.add(const SizedBox(height: 12));

      list.add(
        _buildToleranceDropdown(
          label: 'Band 4: Tolerance',
          value: _toleranceIndex,
          onChanged: (newVal) {
            if (newVal != null) setState(() => _toleranceIndex = newVal);
          },
        ),
      );
    }

    return list;
  }

  /// Visual Resistor graphic component showing leads and colored bands.
  Widget _buildResistorVisualizerCard(BuildContext context) {
    final theme = Theme.of(context);

    final b1 = _digitColors[_band1Index];
    final b2 = _digitColors[_band2Index];
    final b3Digit = _digitColors[_band3DigitIndex];
    final mult = _multiplierColors[_multiplierIndex];
    final tol = _toleranceColors[_toleranceIndex];
    final tempCo = _tempCoColors[_tempCoIndex];

    final List<Widget> stripes = [];
    final List<Widget> legendChips = [];

    if (_bandCount == 4) {
      stripes.add(_buildBandStripe(b1.color, '1'));
      stripes.add(_buildBandStripe(b2.color, '2'));
      stripes.add(_buildBandStripe(mult.color, '3'));
      stripes.add(const SizedBox(width: 14)); // Gap before tolerance band
      stripes.add(_buildBandStripe(tol.color, '4'));

      legendChips.add(_buildLegendChip('B1', b1.name, b1.color));
      legendChips.add(_buildLegendChip('B2', b2.name, b2.color));
      legendChips.add(_buildLegendChip('Mult', mult.name, mult.color));
      legendChips.add(_buildLegendChip('Tol', tol.name, tol.color));
    } else if (_bandCount == 5) {
      stripes.add(_buildBandStripe(b1.color, '1'));
      stripes.add(_buildBandStripe(b2.color, '2'));
      stripes.add(_buildBandStripe(b3Digit.color, '3'));
      stripes.add(_buildBandStripe(mult.color, '4'));
      stripes.add(const SizedBox(width: 14)); // Gap before tolerance band
      stripes.add(_buildBandStripe(tol.color, '5'));

      legendChips.add(_buildLegendChip('B1', b1.name, b1.color));
      legendChips.add(_buildLegendChip('B2', b2.name, b2.color));
      legendChips.add(_buildLegendChip('B3', b3Digit.name, b3Digit.color));
      legendChips.add(_buildLegendChip('Mult', mult.name, mult.color));
      legendChips.add(_buildLegendChip('Tol', tol.name, tol.color));
    } else {
      // 6 Bands
      stripes.add(_buildBandStripe(b1.color, '1'));
      stripes.add(_buildBandStripe(b2.color, '2'));
      stripes.add(_buildBandStripe(b3Digit.color, '3'));
      stripes.add(_buildBandStripe(mult.color, '4'));
      stripes.add(const SizedBox(width: 14)); // Gap before tolerance band
      stripes.add(_buildBandStripe(tol.color, '5'));
      stripes.add(_buildBandStripe(tempCo.color, '6'));

      legendChips.add(_buildLegendChip('B1', b1.name, b1.color));
      legendChips.add(_buildLegendChip('B2', b2.name, b2.color));
      legendChips.add(_buildLegendChip('B3', b3Digit.name, b3Digit.color));
      legendChips.add(_buildLegendChip('Mult', mult.name, mult.color));
      legendChips.add(_buildLegendChip('Tol', tol.name, tol.color));
      legendChips.add(_buildLegendChip('TCR', tempCo.name, tempCo.color));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
        child: Column(
          children: [
            Text(
              'Resistor Preview',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),

            // Resistor Axial Body with Leads
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Terminal Wire / Lead
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(2),
                    ),
                  ),
                ),

                // Ceramic Resistor Body
                Container(
                  width: _bandCount == 6 ? 240 : 220,
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8D7BE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC7B299),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: stripes,
                  ),
                ),

                // Right Terminal Wire / Lead
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Active Color Legend Row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: legendChips,
            ),
          ],
        ),
      ),
    );
  }

  /// Vertical band stripe inside the resistor graphic body.
  Widget _buildBandStripe(Color color, String bandNumber) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: _bandCount == 6 ? 11 : 13,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: color == const Color(0xFFFFFFFF)
                  ? Colors.grey.shade400
                  : Colors.black.withValues(alpha: 0.2),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Legend badge chip displaying the color name.
  Widget _buildLegendChip(String tag, String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF080D1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color == Colors.white ? Colors.grey : Colors.transparent,
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$tag: $name',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculation results card showing the readable value, ohms, range, and tempCo.
  Widget _buildResultsCard(BuildContext context, ResistorCalculationResult calc) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(
              'CALCULATED RESISTANCE',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),

            // Primary Formatted Result: e.g. "1.7 kΩ ±5%"
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${calc.readableNominal} ${calc.toleranceLabel}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Exact resistance in ohms
            Text(
              '${_formatRawOhms(calc.nominalOhms)} Ω',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Temperature coefficient display for 6-band resistors
            if (_bandCount == 6 && calc.tempCoLabel != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Temp. Coefficient: ${calc.tempCoLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],

            const Divider(height: 24),

            // Minimum and Maximum Resistance Range
            Row(
              children: [
                Expanded(
                  child: _buildLimitColumn(
                    context,
                    label: 'Minimum Resistance',
                    readableVal: calc.readableMin,
                    rawOhms: _formatRawOhms(calc.minOhms),
                    color: const Color(0xFF38BDF8),
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: const Color(0xFF1E293B),
                ),
                Expanded(
                  child: _buildLimitColumn(
                    context,
                    label: 'Maximum Resistance',
                    readableVal: calc.readableMax,
                    rawOhms: _formatRawOhms(calc.maxOhms),
                    color: const Color(0xFFA78BFA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for rendering Minimum and Maximum limit columns.
  Widget _buildLimitColumn(
    BuildContext context, {
    required String label,
    required String readableVal,
    required String rawOhms,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          readableVal,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$rawOhms Ω',
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// Dropdown for Significant Digits (0 - 9).
  Widget _buildDigitDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = (value >= 0 && value < _digitColors.length) ? value : 0;
    return DropdownButtonFormField<int>(
      key: ValueKey('digit-$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: _digitColors.map((digit) {
        return DropdownMenuItem<int>(
          value: digit.value,
          child: Row(
            children: [
              _buildColorSwatch(digit.color),
              const SizedBox(width: 12),
              Text('${digit.name} (${digit.value})'),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  /// Dropdown for Multipliers.
  Widget _buildMultiplierDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = (value >= 0 && value < _multiplierColors.length) ? value : 0;
    return DropdownButtonFormField<int>(
      key: ValueKey('multiplier-$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: List.generate(_multiplierColors.length, (index) {
        final mult = _multiplierColors[index];
        final String multLabel;
        if (mult.multiplier >= 1) {
          multLabel = '×${ResistorScannerService.formatResistance(mult.multiplier)}';
        } else if (mult.multiplier == 0.1) {
          multLabel = '×0.1';
        } else {
          multLabel = '×0.01';
        }
        return DropdownMenuItem<int>(
          value: index,
          child: Row(
            children: [
              _buildColorSwatch(mult.color),
              const SizedBox(width: 12),
              Text('${mult.name} ($multLabel)'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  /// Dropdown for Tolerance.
  Widget _buildToleranceDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = (value >= 0 && value < _toleranceColors.length) ? value : 0;
    return DropdownButtonFormField<int>(
      key: ValueKey('tolerance-$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: List.generate(_toleranceColors.length, (index) {
        final tol = _toleranceColors[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Row(
            children: [
              _buildColorSwatch(tol.color),
              const SizedBox(width: 12),
              Text('${tol.name} (±${tol.tolerance}%)'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  /// Dropdown for Temperature Coefficient (6th Band).
  Widget _buildTempCoDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
  }) {
    final safeValue = (value >= 0 && value < _tempCoColors.length) ? value : 0;
    return DropdownButtonFormField<int>(
      key: ValueKey('tempCo-$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      items: List.generate(_tempCoColors.length, (index) {
        final tc = _tempCoColors[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Row(
            children: [
              _buildColorSwatch(tc.color),
              const SizedBox(width: 12),
              Text('${tc.name} (${tc.value} ppm/K)'),
            ],
          ),
        );
      }),
      onChanged: onChanged,
    );
  }

  /// Color circle swatch indicator for dropdown items.
  Widget _buildColorSwatch(Color color) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: color == const Color(0xFFFFFFFF)
              ? Colors.grey.shade400
              : Colors.black.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    );
  }
}
