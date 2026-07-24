/// Auth data models for Bagisto customer API
///
/// IMPORTANT: The Bagisto API returns some fields as strings that might
/// look like booleans (e.g. status="1", isVerified="1"). We store them
/// as Strings to avoid type-cast crashes.
library;

class CustomerLogin {
  final String? accessToken;
  final String? message;
  final bool success;
  final Customer? customer;

  const CustomerLogin({
    this.accessToken,
    this.message,
    this.success = false,
    this.customer,
  });

  factory CustomerLogin.fromJson(Map<String, dynamic> json) {
    return CustomerLogin(
      accessToken: json['accessToken']?.toString(),
      message: json['message']?.toString(),
      success: _parseBool(json['success']),
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  // Compatibility getters for old code
  String? get id => customer?.id;
  String? get token => accessToken;
  String? get apiToken => accessToken;
}

class Customer {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? status;
  final String? apiToken;
  final String? token;
  final String? rememberToken;
  final String? name;
  final String? isVerified;
  final String? isSuspended;
  final bool? subscribedToNewsLetter;
  final String? customerGroupId;

  const Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.status,
    this.apiToken,
    this.token,
    this.rememberToken,
    this.name,
    this.isVerified,
    this.isSuspended,
    this.subscribedToNewsLetter,
    this.customerGroupId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      status: json['status']?.toString(),
      apiToken: json['apiToken']?.toString(),
      token: json['token']?.toString(),
      rememberToken: json['rememberToken']?.toString(),
      name: json['name']?.toString(),
      isVerified: json['isVerified']?.toString(),
      isSuspended: json['isSuspended']?.toString(),
      subscribedToNewsLetter: _parseBool(json['subscribedToNewsLetter']),
      customerGroupId: json['customerGroupId']?.toString(),
    );
  }

  String get displayName => name ?? '$firstName $lastName';
}

/// Safely parse a value that may be bool, int, or String to a bool.
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    return value == 'true' || value == '1';
  }
  return false;
}
