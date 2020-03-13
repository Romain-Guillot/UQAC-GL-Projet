// Authors: Romain Guillot and Mamadou Diouldé Diallo
import 'package:app/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Model to represent an activity
/// 
/// See the documentation `documents > archi_models.md` for more information
/// 
/// The class DOES NOT contain any logic inside ! It's not its responsability,
/// it's responsability it's just a representation of an activity.
/// Some project used the models to convert the model to json ([Map]) of to
/// convert the json to the model for noSQL database. We decided to NOT do that 
/// here because these transformations are dependents of the noSQL dataabse
/// strucutre (name of fields). These transformations are directly applied 
/// in the corresponding services (through adapters)
class Activity {
  String title;
  User user;
  String description;
  DateTime createdDate;
  DateTime beginDate;
  DateTime endDate;
  Position location;

  Activity({
    @required this.title,
    @required this.user,
    @required this.description,
    @required this.createdDate,
    @required this.beginDate,
    @required this.endDate,
    @required this.location,
  }); 
}