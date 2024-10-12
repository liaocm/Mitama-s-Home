#!/usr/bin/python3
import plistlib
from datetime import datetime

def generate_preference_values():
  pref_file = "mitamapref/Resources/Root.plist"
  try:
    with open(pref_file, 'rb') as f:
      list_data = plistlib.load(f)
      generate_file(list_data)
  except Exception as e:
    print("Error generating preference values...")
    raise e

def generate_file(plist):
  output_file = "src/MTMPreferenceValues.m"
  now = datetime.now()
  timestamp = now.strftime("%Y-%m-%d %H:%M:%S")
  indentation = ""

  result = "// MTMPreferenceValues.m\n// libmitamaui\n//\n"
  result += "// Generated on " + timestamp + "\n//\n"
  result += "#import \"MTMPreferenceValues.h\"\n\n"
  result += "NSArray *MTMPreferenceValuesFromKey(NSString *key)\n{\n"
  indentation += "  "
  result += indentation + "NSArray *result = nil;\n"
  result += indentation + "if (false) {}\n"
  for item in plist['items']:
    if 'key' not in item:
      continue

    if 'validValues' not in item:
      continue

    key = item['key']
    values = item['validValues']
    result += indentation + "else if ([key isEqual:@\"{0}\"])".format(key) + " {\n"
    indentation += "  "
    ## transform values
    result += indentation + "result = @["
    for val in values:
      if type(val) is str:
        valString = "@\"{0}\"".format(val)
      else:
        valString = "@{0}".format(val)
      result += valString + ", "
    result = result[:-2]
    result += "];\n"
    indentation = indentation[:-2]
    result += indentation + "}\n"

  # special case: timer
  result += indentation + "else if ([key isEqual:@\"timer\"]) {\n"
  result += indentation + "  return @[@1.0, @1.5, @2.0, @2.5, @3.0, @3.5, @4.0];\n"
  result += indentation + "}\n"

  result += indentation + "return result;\n"
  result += "}\n\n"

  # preference title values
  result += "NSArray *MTMPreferenceTitleValuesFromKey(NSString *key)\n{\n"
  indentation = "  "
  result += indentation + "NSArray *result = nil;\n"
  result += indentation + "if (false) {}\n"
  for item in plist['items']:
    if 'key' not in item:
      continue
    if 'validTitles' not in item:
      continue

    key = item['key']
    values = item['validTitles']
    result += indentation + "else if ([key isEqual:@\"{0}\"])".format(key) + " {\n"
    indentation += "  "
    ## transform values
    result += indentation + "result = @["
    for val in values:
      result += "@\"{0}\"".format(val) + ", "
    result = result[:-2]
    result += "];\n"
    indentation = indentation[:-2]
    result += indentation + "}\n"

  # special case: timer
  result += indentation + "else if ([key isEqual:@\"timer\"]) {\n"
  result += indentation + "  return @[@\"1.0\", @\"1.5\", @\"2.0\", @\"2.5\", @\"3.0\", @\"3.5\", @\"4.0\"];\n"
  result += indentation + "}\n"

  result += indentation + "return result;\n"
  result += "}\n\n"

  result += "// End of MTMPreferenceValues.m"
  with open(output_file, 'w') as f:
    f.write(result)

if __name__ == '__main__':
  print("Generating Preference Values...")
  generate_preference_values()
  print("Done.")