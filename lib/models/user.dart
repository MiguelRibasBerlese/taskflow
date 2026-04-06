class User {
  final String name;
  final String email;
  final String phone;
  final String password;

  const User({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
