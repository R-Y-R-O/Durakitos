import 'package:cloud_firestore/cloud_firestore.dart';

enum Role {
  creator,
  admin,
  superAgent,
  agent,
  user,
}

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final Role role;
  final String? sponsorId;
  final int diamonds;
  final DateTime? trialEndDate;
  final int totalRequestsUsed;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime? lastLogin;
  
  // Perfil extendido
  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? province;
  final String? municipality;
  final String? sex;
  final String? referredBy;
  final bool profileCompleted;
  final String? bio;
  final String? profession;
  final String? sector;
  final String? studies;  final List<String>? skills;
  final List<String>? interests;
  final String? coverImageUrl;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role = Role.user,
    this.sponsorId,
    this.diamonds = 0,
    this.trialEndDate,
    this.totalRequestsUsed = 0,
    this.isLocked = false,
    required this.createdAt,
    this.lastLogin,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.province,
    this.municipality,
    this.sex,
    this.referredBy,
    this.profileCompleted = false,
    this.bio,
    this.profession,
    this.sector,
    this.studies,
    this.skills,
    this.interests,
    this.coverImageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'sponsorId': sponsorId,
      'diamonds': diamonds,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
      'totalRequestsUsed': totalRequestsUsed,
      'isLocked': isLocked,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'firstName': firstName,      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'province': province,
      'municipality': municipality,
      'sex': sex,
      'referredBy': referredBy,
      'profileCompleted': profileCompleted,
      'bio': bio,
      'profession': profession,
      'sector': sector,
      'studies': studies,
      'skills': skills ?? [],
      'interests': interests ?? [],
      'coverImageUrl': coverImageUrl,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      avatarUrl: data['avatarUrl'],
      role: Role.values.firstWhere(
        (e) => e.name == (data['role'] ?? 'user'),
        orElse: () => Role.user,
      ),
      sponsorId: data['sponsorId'],
      diamonds: data['diamonds'] ?? 0,
      trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
      totalRequestsUsed: data['totalRequestsUsed'] ?? 0,
      isLocked: data['isLocked'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      firstName: data['firstName'],
      lastName: data['lastName'],
      phone: data['phone'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      province: data['province'],
      municipality: data['municipality'],
      sex: data['sex'],
      referredBy: data['referredBy'],
      profileCompleted: data['profileCompleted'] ?? false,
      bio: data['bio'],
      profession: data['profession'],
      sector: data['sector'],
      studies: data['studies'],
      skills: data['skills'] != null ? List<String>.from(data['skills']) : null,
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,      coverImageUrl: data['coverImageUrl'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    Role? role,
    String? sponsorId,
    int? diamonds,
    DateTime? trialEndDate,
    int? totalRequestsUsed,
    bool? isLocked,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? province,
    String? municipality,
    String? sex,
    String? referredBy,
    bool? profileCompleted,
    String? bio,
    String? profession,
    String? sector,
    String? studies,
    List<String>? skills,
    List<String>? interests,
    String? coverImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      sponsorId: sponsorId ?? this.sponsorId,
      diamonds: diamonds ?? this.diamonds,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      totalRequestsUsed: totalRequestsUsed ?? this.totalRequestsUsed,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      province: province ?? this.province,
      municipality: municipality ?? this.municipality,
      sex: sex ?? this.sex,
      referredBy: referredBy ?? this.referredBy,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      sector: sector ?? this.sector,
      studies: studies ?? this.studies,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}
