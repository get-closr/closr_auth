import 'package:closrauth/models/basemodel.dart';

class Person extends BaseModel {
  String _email;
  String _name;
  String photoUrl;
  String text;

  Person();

  Person.fromValues(this._email);

  Person.fromValuesWithId(String id, this._name, this._email) {
    super.id = id;
  }

  Person.map(dynamic obj) {
    this.id = obj['id'];
    this._name = obj['title'];
    this._email = obj['email'];
  }

  String get name => _name;
  String get email => _email;

  @override
  Person createNew() {
    return Person();
  }

  Person.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this._email = map['email'];
    this._name = map['name'];
  }

  @override
  Person fromMap(Map<String, dynamic> map) {
    var person = Person();

    person.id = map['id'];
    person._email = map['email'];
    person._name = map['name'];

    return person;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = _name;
    map['email'] = _email;
    return map;
  }
}
