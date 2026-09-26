class BusinessProfile {
  final String businessName;
  final String tin;
  final String address;
  final String phone;
  final String email;
  final String invoicePrefix;

  const BusinessProfile({
    required this.businessName,
    required this.tin,
    required this.address,
    required this.phone,
    required this.email,
    this.invoicePrefix = 'INV',
  });

  bool get isComplete =>
      businessName.trim().isNotEmpty && tin.trim().isNotEmpty && address.trim().isNotEmpty;

  BusinessProfile copyWith({
    String? businessName,
    String? tin,
    String? address,
    String? phone,
    String? email,
    String? invoicePrefix,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      tin: tin ?? this.tin,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
    );
  }

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'tin': tin,
        'address': address,
        'phone': phone,
        'email': email,
        'invoicePrefix': invoicePrefix,
      };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
        businessName: json['businessName'] as String? ?? '',
        tin: json['tin'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        email: json['email'] as String? ?? '',
        invoicePrefix: json['invoicePrefix'] as String? ?? 'INV',
      );

  static const empty = BusinessProfile(businessName: '', tin: '', address: '', phone: '', email: '');
}
