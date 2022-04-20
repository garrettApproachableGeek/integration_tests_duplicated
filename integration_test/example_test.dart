import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integration_tests_duplicated/firebase_options.dart';
import 'package:integration_tests_duplicated/main.dart';
import 'package:intl/intl.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.now();
  const String collectionName = 'examples';
  String currentMinute = DateFormat.yMd().add_jm().format(now);

  documentsInsertedThisMinute() async {
    var collection = FirebaseFirestore.instance.collection(collectionName);
    var snapshots =
        await collection.where('foobar', isEqualTo: currentMinute).get();
    return snapshots.size;
  }

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets(
    'Single document created',
    (WidgetTester tester) async {
      int preExistingDocuments = await documentsInsertedThisMinute();
      print('Pre-existing documents: $preExistingDocuments');

      await tester.pumpWidget(const MyApp());

      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc()
          .set({'foobar': currentMinute});

      int documentsAfterSingleInsert = await documentsInsertedThisMinute();
      expect(documentsAfterSingleInsert, 1);
    },
  );
}
