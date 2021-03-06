import 'dart:io';

import 'package:app/authentication/authentication_provider.dart';
import 'package:app/shared/models/user.dart';
import 'package:app/shared/res/dimens.dart';
import 'package:app/shared/res/strings.dart';
import 'package:app/shared/res/values.dart';
import 'package:app/shared/utils/color_operations.dart';
import 'package:app/shared/utils/snackbar_handler.dart';
import 'package:app/shared/widgets/buttons.dart';
import 'package:app/shared/widgets/flat_app_bar.dart';
import 'package:app/shared/widgets/flex_spacer.dart';
import 'package:app/shared/widgets/formfields.dart';
import 'package:app/shared/widgets/page_header.dart';
import 'package:app/shared/widgets/profile_widgets.dart';
import 'package:app/user/profile_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';



/// Page for the profile edition (the form to edit the profile)
/// 
/// It takes the actual [user] information (to pre-fill the fields)
/// 
/// It has the four following elements :
/// - a simple description (just a [Text] in fact)
/// - the actual form [ProfileForm] that contains all fields to edit the profile
/// - a button to submit the form [ProfilEditionButton]
/// - a widget to delete the user account
/// 
/// It's the [ProfilEditionButton] that handles the submission process (call
/// the [ProfileProvider] in fact). So it needs to retreive the form content 
/// to give these data to the provider. To do that, we keep the key of the
/// [ProfileEditPage] state ([_ProfileEditPageState]) to call the function
/// [_ProfileEditPageState.getUser()] upon submission of the form.
/// It's why it's a stateful widget, to keep in the state the form key and not
/// lost data when the widget is rebuild : [_ProfileEditPageState.profileFormKey]
/// If we move this key directly in the stateless widget we lost the key every
/// rebuild and so we lost form data. Here when the tree is rebuild, the state
/// is conserved and so the key.
/// 
/// To know more about keys : https://www.youtube.com/watch?v=kn0EOS-ZiIc
class ProfileEditPage extends StatefulWidget {

  final User user;

  ProfileEditPage({Key key, @required this.user}) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  
  final profileFormKey = GlobalKey<_ProfileFormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlatAppBar(
        action: ProfilEditionButton(profileFormKey: profileFormKey)
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: Dimens.screenPaddingBodyWithAppBar,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              PageHeader(
                subtitle: Text(Strings.profileEditionInfo), 
              ),
              FlexSpacer.big(),
              ProfileForm(
                key: profileFormKey,
                initialUser: widget.user
              ),
              FlexSpacer.big(),
              DeleteAccount()
            ],
          )
        ),
      ),
    );
  }
}



/// Handle the submission of the form to edit the user
///
/// The form result (the result is an [User] in fact) can be retrieve thanks
/// to the [profileFormKey] state ([_ProfileFormState.getUser()]).
/// 
/// It's a stateful widget to display a loading message and disable the button
/// while the user info is being updated.
/// 
/// pop the current page if the user is successfully updated, if not an error
/// snackbar is displayed.
class ProfilEditionButton extends StatefulWidget {

  final GlobalKey<_ProfileFormState> profileFormKey;

  ProfilEditionButton({@required this.profileFormKey});

  @override
  _ProfilEditionButtonState createState() => _ProfilEditionButtonState();
}

class _ProfilEditionButtonState extends State<ProfilEditionButton> {

  bool inProgress = false;

  @override
  Widget build(BuildContext context) {
    return Button(
      child: Text(inProgress ? Strings.loading : Strings.profileEditionSave),
      onPressed: inProgress ? null : handleSubmit,
    );
  }

  /// Handle the form submission
  /// - retrieve the user from the [_ProfileFormState] state
  /// - ask the provider to edit the connected user with these new information
  /// - handle the success or the error result
  handleSubmit() async {
    var user = widget.profileFormKey.currentState.getUser();
    if (user != null) {
      setState(() => inProgress = true);
      var profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      bool success = await profileProvider.editUser(user);
      setState(() => inProgress = false);
      success ? handleSuccess() : handleError();
    }
  }

  /// Display an error snackbar
  handleError() {
    showSnackbar(
      context: context, 
      content: Text(Strings.profileEditionError), 
      critical: true
    );
  }

  /// If the updating succeed, we pop the current page (or we just display
  /// a snackbar if we cannot pop anything)
  handleSuccess() {
    var parentRoute = ModalRoute.of(context);
    var canPop = parentRoute?.canPop ?? false;
    if (canPop)
      Navigator.pop(context);
    else
      showSnackbar(context: context, content: Text(Strings.profileEditionSuccess));
  }
}



/// Display the form to edit the user profile (photo, name, country, etc.)
///
/// It takes the [initialUser] to pre-fill the fields. It DOES NOT handle
/// the form submission, it just handles the form.
/// 
/// But, you can retreive an instance of [User] with the updated information 
/// thanks to the [getUser()] method :
/// 
/// ```dart
/// final profileFormKey = GlobalKey<_ProfileFormState>();
/// 
/// ...
/// 
/// ProfileForm(
///   key: profileFormKey,
///   ...
/// )
/// 
/// ...
/// 
/// var user = profileFormKey.currentState.getUser()
/// ````
/// 
/// To know more about keys : https://www.youtube.com/watch?v=kn0EOS-ZiIc
class ProfileForm extends StatefulWidget {

  final User initialUser;
  
  ProfileForm({Key key, @required this.initialUser}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {

  final _formKey = GlobalKey<FormState>();

  final userNameController = TextEditingController();
  final languageController = TextEditingController();
  final ageController = TextEditingController();
  final descriptionController = TextEditingController();
  final contryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      userNameController.text = widget.initialUser.name;
      languageController.text = widget.initialUser.spokenLanguages;
      ageController.text = widget.initialUser.age?.toString();
      descriptionController.text = widget.initialUser.description;
      contryController.text = widget.initialUser.country;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          UploadPhotoFormField(),
          FlexSpacer(),
          AppTextField(
            controller: userNameController,
            labelText: Strings.profileUsername,
            minLength: Values.profileUsernameMinLength,
            maxLength: Values.profileUsernameMaxLength,
          ),
          FlexSpacer(),
          AppTextField(
            controller: descriptionController,
            labelText: Strings.profileDescription,
            keyboardType: TextInputType.multiline,
            maxLines: Dimens.profileDescriptionFormLineNumber,
            optional: true,
            minLength: Values.profileDescriptionMinLength,
            maxLength: Values.profileDescriptionMaxLength,
            info: Text(Strings.profileDescriptionEditionInfo),
          ),
          FlexSpacer(),
          AppTextField(
            controller: ageController,
            labelText: Strings.profileAge,
            keyboardType: TextInputType.number,
            optional: true,
            minValue: Values.profileAgeMinValue,
            maxValue: Values.profileAgeMaxValue,
          ),
          FlexSpacer(),
          AppTextField(
            controller: languageController,
            labelText: Strings.profileSpokenLanguages,
            optional: true,
            maxLength: Values.profileLanguagesMaxLength,
          ),
          FlexSpacer(),
          AppTextField(
            controller: contryController,
            labelText:  Strings.profileCountry,
            optional: true,
            maxLength: Values.profileCountryMaxLength,
          ),
        ],
      ),
    );
  }

  /// Get the result [User] according to the content of the fields
  /// See the class-level documentation to have an usage example
  User getUser() {
    if (_formKey.currentState.validate()){
      int age;
      try {
        age = int.parse(ageController.text);
      } catch(_) {}
      return User(
        name: userNameController.text.trim(),
        description: descriptionController.text.trim(), 
        age: age, 
        spokenLanguages: languageController.text.trim(), 
        country: contryController.text.trim(),
        urlPhoto: widget.initialUser.urlPhoto
      );
    }
    return null;
  }
}



/// IN PROGRESS
///
/// TBD
///   - initial photo
class UploadPhotoFormField extends StatefulWidget {
  @override
  _UploadPhotoFormFieldState createState() => _UploadPhotoFormFieldState();
}

class _UploadPhotoFormFieldState extends State<UploadPhotoFormField> {

  File _image;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Container(
              height: constraints.maxWidth,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: Dimens.borderRadius
              ),
              child: ClipRRect(
                borderRadius: Dimens.borderRadius,
                child: _image == null
                  ? DefaultProfilePicture()
                  : Image.file(
                      _image,
                      fit: BoxFit.cover
                    ),
                ),
            ),
          ),
        ),
        FlexSpacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Button(
              icon: Icon(Icons.add_photo_alternate),
              child: Text(Strings.profileEditionPickPhoto),
              onPressed: getImageFromGall,
            ),
            Button(
              icon: Icon(Icons.add_a_photo),
              child: Text(Strings.profileEditionTakePhoto),
              onPressed: getImageFromCam,
            )
          ],
        ),
      ],
    );
  }

  Future getImageFromCam() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() => _image = image);
  }

  Future getImageFromGall() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() => _image = image);
  }
}



/// Provide a button with a security verification to delete the user account
///
/// It displays a button to delete the user account. This button is only
/// enabled if the user previously checked the [Switch] (it is the security
/// verification).
/// An informative text is also displayed.
/// 
/// It is a Stateful widget as there are 2 variables state :
/// - [actionVerified] : true if the user HAS checked the verification switch
/// - [loading] : true if the deletion action is in progress
class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {

  bool actionVerified = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var errorColor = Theme.of(context).colorScheme.error;
    var textStyle = TextStyle(color: ColorOperations.darken(errorColor, 0.25));
    return Container(
      padding: EdgeInsets.all(Dimens.normalSpacing),
      width: double.infinity,
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.2),
        borderRadius: Dimens.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            Strings.profileDeleteInfo,
            style: textStyle,
          ),
          Row(
            children: <Widget>[
              Switch(
                value: actionVerified,
                activeColor: errorColor,
                onChanged: (val) => setState(() => actionVerified = val),
              ),
              Text(
                Strings.profileDeleteVerificationLabel,
                style: textStyle,
              )
            ],
          ),
          FlatButton(
            color: errorColor,
            textColor: Theme.of(context).colorScheme.onError,
            child: Text(loading ? Strings.loading : Strings.profileDelete),
            onPressed: !actionVerified || loading ? null : onDelete,
          ),
        ],
      ),
    );
  }

  onDelete() async {
    if (actionVerified) {
      setState(() => loading = true);
      try {
        await Provider.of<AuthenticationProvider>(context, listen: false)
            .deleteUser();
        Navigator.pop(context);
        return ;
      } catch (_) {
        showSnackbar(
          context: context, 
          content: Text(Strings.profileDeleteError),
          critical: true
        );
      }
      setState(() => loading = false);
    }
  }
}