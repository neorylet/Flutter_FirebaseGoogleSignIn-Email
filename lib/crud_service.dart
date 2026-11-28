import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference<Map<String, dynamic>> items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity, {String? imageUrl}) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'isFavorite': false,
      'image_url': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateItem(
    String id,
    String name,
    int quantity, {
    String? imageUrl,
  }) {
    final data = <String, dynamic>{
      'name': name,
      'quantity': quantity,
    };
    if (imageUrl != null) {
      data['image_url'] = imageUrl;
    }
    return items.doc(id).update(data);
  }

  Future<void> setFavorite(String id, bool isFavorite) {
    return items.doc(id).update({'isFavorite': isFavorite});
  }

  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }
}
