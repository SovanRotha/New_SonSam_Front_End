class Login {
  final String email;
  final String password;

  Login({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}


class User {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String currency;
  // final String? profile;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.currency,
    // required this.profile,
  });

  Map<String, dynamic> toJson() {
    return {
      'name' : name,
      'email': email, 
      'password': password,
      'phone' : phone,
      'currency' : currency,
      // 'profile' : profile,
      };
  }
}
