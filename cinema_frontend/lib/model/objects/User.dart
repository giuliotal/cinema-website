class User {
  int id;
  String firstName;
  String lastName;
  String phoneNumber;
  String email;
  String address;

  User({this.id, this.firstName, this.lastName, this.phoneNumber, this.email, this.address});

  factory User.fromJson(Map<String,dynamic> json) {
    return User (
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address']
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'email': email,
    'address': address
  };

  @override
  String toString() {
    return email;
  }
}