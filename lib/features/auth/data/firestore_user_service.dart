import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/user_model.dart';
import '../domain/user_role.dart';

class FirestoreUserService {
  FirebaseFirestore? _firestore;

  FirestoreUserService({FirebaseFirestore? firestore}) {
    if (firestore != null) _firestore = firestore;
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (FirebaseService.isInitialized) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>>? get _usersCollection =>
      firestore?.collection('users');

  Future<void> saveUser(UserModel user) async {
    final col = _usersCollection;
    if (col == null) return;
    await col.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final col = _usersCollection;
    if (col == null) return null;
    final doc = await col.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateUserRole(String uid, UserRole newRole) async {
    final col = _usersCollection;
    if (col == null) return;
    await col.doc(uid).update({'role': newRole.name});
  }
}
