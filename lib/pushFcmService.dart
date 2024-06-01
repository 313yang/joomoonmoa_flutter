import 'package:cloud_functions/cloud_functions.dart';

Future<void> pushFCM(bool update) async {
  try {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('update');

    final results = await callable();
    print('pushFCM: success');
  } catch (e) {
    print('pushFAQ: $e');
    throw Exception("pushFAQ: $e");
  }
}
