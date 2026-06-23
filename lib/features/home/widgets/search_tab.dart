
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:durakitos/models/user_model.dart';
import 'package:durakitos/features/home/widgets/user_card.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _searchTerm = '';
  Stream<List<UserModel>>? _userStream;

  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm.trim();
      if (_searchTerm.isNotEmpty) {
        _userStream = _searchUsers(_searchTerm);
      }
    });
  }

  Stream<List<UserModel>> _searchUsers(String searchTerm) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('displayName_lowercase', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
        .where('displayName_lowercase', isLessThan: '${searchTerm.toLowerCase()}\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              labelText: 'Buscar usuarios por nombre',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          if (_searchTerm.isNotEmpty)
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _userStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No se encontraron usuarios.'));
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: users[index]);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
