import 'package:vibration/vibration.dart';

class Vibraille {
  bool stopVibration = false;
  bool playing = false;

  void convertToVibraille(String text, double speed) {
    String vibrailleText = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i].toLowerCase();
      String vibrailleChar = getVibrailleChar(char);
      if (vibrailleChar != '') {
        vibrailleText += vibrailleChar;
      }
    }
    vibraillify(vibrailleText, speed);
  }

  void stopVib() {
    if (playing) {
      stopVibration = true;
      playing = false;
    }
  }

  Future<void> vibraillify(String text, double multi) async {
    bool canVibrate = await Vibration.hasVibrator();
    if (!canVibrate) return;

    playing = true;
    for (var element in text.split("")) {
      if (!b2B.containsKey(element)) continue; // Skip invalid characters

      for (var dot in b2B[element]!.split("")) {
        if (stopVibration) {
          stopVibration = false;
          return;
        }
        if (dot == '1') {
          await Vibration.vibrate(duration: (100 / multi).toInt());
          await Future.delayed(Duration(milliseconds: (100 / multi).toInt()));
        } else {
          await Vibration.vibrate(
              duration: (50 / multi).toInt(), amplitude: 128);
          await Future.delayed(Duration(milliseconds: (50 / multi).toInt()));
        }
        // Pause between dots
        await Future.delayed(Duration(milliseconds: (50 / multi).toInt()));
      }
      // Pause between characters
      await Future.delayed(Duration(milliseconds: (200 / multi).toInt()));
    }
    playing = false;
  }

  Map<String, String> b2B = {
    '⠁': '100000',
    '⠂': '010000',
    '⠃': '110000',
    '⠄': '001000',
    '⠅': '101000',
    '⠆': '011000',
    '⠇': '111000',
    '⠈': '000100',
    '⠉': '100100',
    '⠊': '010100',
    '⠋': '110100',
    '⠌': '001100',
    '⠍': '101100',
    '⠎': '011100',
    '⠏': '111100',
    '⠐': '000010',
    '⠑': '100010',
    '⠒': '010010',
    '⠓': '110010',
    '⠔': '001010',
    '⠕': '101010',
    '⠖': '011010',
    '⠗': '111010',
    '⠘': '000110',
    '⠙': '100110',
    '⠚': '010110',
    '⠛': '110110',
    '⠜': '001110',
    '⠝': '101110',
    '⠞': '011110',
    '⠟': '111110',
    '⠠': '000001',
    '⠡': '100001',
    '⠢': '010001',
    '⠣': '110001',
    '⠤': '001001',
    '⠥': '101001',
    '⠦': '011001',
    '⠧': '111001',
    '⠨': '000101',
    '⠩': '100101',
    '⠪': '010101',
    '⠫': '110101',
    '⠬': '001101',
    '⠭': '101101',
    '⠮': '011101',
    '⠯': '111101',
    '⠰': '000011',
    '⠱': '100011',
    '⠲': '010011',
    '⠳': '110011',
    '⠴': '001011',
    '⠵': '101011',
    '⠶': '011011',
    '⠷': '111011',
    '⠸': '000111',
    '⠹': '100111',
    '⠺': '010111',
    '⠻': '110111',
    '⠼': '001111',
    '⠽': '101111',
    '⠾': '011111',
    '⠿': '111111',
  };

  String getVibrailleChar(String char) {
    switch (char) {
      case 'a':
        return '⠠';
      case 'b':
        return '⠃';
      case 'c':
        return '⠉';
      case 'd':
        return '⠙';
      case 'e':
        return '⠑';
      case 'f':
        return '⠋';
      case 'g':
        return '⠛';
      case 'h':
        return '⠓';
      case 'i':
        return '⠊';
      case 'j':
        return '⠚';
      case 'k':
        return '⠅';
      case 'l':
        return '⠇';
      case 'm':
        return '⠍';
      case 'n':
        return '⠝';
      case 'o':
        return '⠕';
      case 'p':
        return '⠏';
      case 'q':
        return '⠟';
      case 'r':
        return '⠗';
      case 's':
        return '⠎';
      case 't':
        return '⠞';
      case 'u':
        return '⠥';
      case 'v':
        return '⠧';
      case 'w':
        return '⠺';
      case 'x':
        return '⠭';
      case 'y':
        return '⠽';
      case 'z':
        return '⠵';
      // Add numbers
      case '1':
        return '⠼⠁';
      case '2':
        return '⠼⠃';
      case '3':
        return '⠼⠉';
      case '4':
        return '⠼⠙';
      case '5':
        return '⠼⠑';
      case '6':
        return '⠼⠋';
      case '7':
        return '⠼⠛';
      case '8':
        return '⠼⠓';
      case '9':
        return '⠼⠊';
      case '0':
        return '⠼⠚';
      // Add special characters
      case '!':
        return '⠮';
      case '?':
        return '⠹';
      case '.':
        return '⠲';
      case ',':
        return '⠂';
      case ';':
        return '⠆';
      case ':':
        return '⠒';
      case '-':
        return '⠤';
      case '(':
        return '⠶';
      case ')':
        return '⠶';
      case '/':
        return '⠌';
      case '\'':
        return '⠄';
      case '"':
        return '⠐';
      case '*':
        return '⠡';
      case '@':
        return '⠈';
      case '#':
        return '⠼';
      case '&':
        return '⠯';
      case '%':
        return '⠩';
      case '+':
        return '⠬';
      case '=':
        return '⠿';
      default:
        return '';
    }
  }
}
