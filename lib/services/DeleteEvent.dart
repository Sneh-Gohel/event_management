import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteCollection(String collectionPath) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference collectionRef = firestore.collection(collectionPath);

  QuerySnapshot querySnapshot = await collectionRef.get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    await deleteDocumentWithSubcollections(collectionPath, doc.id);
  }
}

Future<void> deleteDocumentWithSubcollections(String collectionPath, String docId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference docRef = firestore.collection(collectionPath).doc(docId);

  // Get subcollections of the document
  List<String> subcollections = await getSubcollections(docRef);

  // Delete all documents in each subcollection
  for (String subcollection in subcollections) {
    CollectionReference subcollectionRef = docRef.collection(subcollection);
    QuerySnapshot subQuerySnapshot = await subcollectionRef.get();
    
    for (QueryDocumentSnapshot subDoc in subQuerySnapshot.docs) {
      await deleteDocumentWithSubcollections("$collectionPath/$docId/$subcollection", subDoc.id);
    }
  }

  // Delete the document itself
  await docRef.delete();
}

Future<List<String>> getSubcollections(DocumentReference docRef) async {
  List<String> subcollections = [];
  try {
    var collections = await docRef.firestore.collectionGroup(docRef.id).get();
    for (var doc in collections.docs) {
      if (!subcollections.contains(doc.reference.parent.id)) {
        subcollections.add(doc.reference.parent.id);
      }
    }
  } catch (e) {
    print("Error getting subcollections: $e");
  }
  return subcollections;
}

Future<void> deleteField(String collectionPath, String docId, String fieldName) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference docRef = firestore.collection(collectionPath).doc(docId);

  await docRef.update({fieldName: FieldValue.delete()});
}