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
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String currency;
  final String? status;
  // final String? profile;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.currency,
    this.status,
    // required this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'USD',
      status: json['status']?.toString() ?? 'active',
      // profile: json['profile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name' : name,
      'email': email, 
      'password': password,
      'phone' : phone,
      'currency' : currency,
      'status' : status,
      // 'profile' : profile,
      };
  }
}
