class Customer {
  final String id;
  final String name;
  final String tin;
  final String address;
  final String phone;
  final String email;

  const Customer({
    required this.id,
    required this.name,
    this.tin = '',
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tin': tin,
        'address': address,
        'phone': phone,
        'email': email,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        tin: json['tin'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}
