import os
import re

file_path = "lib/services/resistor_scanner_service.dart"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

# We need to strip out `detectColorsWithGemini`, `parseGeminiResponse`, and `detectColorsFromImage`
code = re.sub(r'static Future<ResistorScanResult> detectColorsWithGemini.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static ResistorScanResult parseGeminiResponse.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static ResistorScanResult detectColorsFromImage.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static int _stringToDigitIndex.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static int _stringToMultiplierIndex.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static int _stringToToleranceIndex.*?\}', '', code, flags=re.DOTALL)
code = re.sub(r'static int _stringToTempCoIndex.*?\}', '', code, flags=re.DOTALL)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Cleaned")
