dynamic studentInfo() {
  // TODO 1

  var name ="Diki"; 
  var favNumber = "7";
  var isPraktikan = true;

  // End of TODO 1
  return [name, favNumber, isPraktikan];
}

dynamic circleArea(num r) {
  if (r < 0) {
    return 0.0;
  } else {
    const double pi = 3.1415926535897932; // π dari library dart.math;
    return pi * r * r;
  }
}


int? parseAndAddOne(String? input) {
  if (input == null) return null; // Jika input null, kembalikan null

  int? number = int.tryParse(input); // Coba ubah ke integer

  if (number == null) {
    return null; // Jika bukan angka, kembalikan null
  }

  return number + 1; // Jika angka valid, tambahkan 1 dan kembalikan hasilnya
}

// exam1_main.dart

import 'exam1.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print(
        'Argumen tidak ada, jalankan ulang file exam1_main.dart dengan argumen.');
  } else {
    var studentName = args.join(' ');
    
    if (studentInfo()[0].runtimeType == String &&
        studentInfo()[1].runtimeType == int &&
        studentInfo()[2].runtimeType == bool &&
        studentInfo()[0] == studentName) {
      print(true);
    }

    print(circleArea(7));
    print(circleArea(20));
    print(circleArea(0));
    print(circleArea(-10));

    print(parseAndAddOne('1'));
    print(parseAndAddOne(null));

    try {
      print(parseAndAddOne('a'));
    } catch (e) {
      print(e);
    }
  }
}

// How to run example =
// "dart run .\bin\exam1\exam1_main.dart Your Name"