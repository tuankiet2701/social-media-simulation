import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_simulation/components/text_form_builder.dart';
import 'package:social_media_simulation/models/user.dart';
import 'package:social_media_simulation/screens/edit_profile_screen/edit_profile_model/edit_profile_model.dart';
import 'package:social_media_simulation/utils/firebase.dart';
import 'package:social_media_simulation/utils/validation.dart';
import 'package:social_media_simulation/widgets/indicator.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? user;
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserModel? user;

  String currentUid() {
    return firebaseAuth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileModel editProfileModel = Provider.of<EditProfileModel>(context);
    return LoadingOverlay(
      progressIndicator: circularProgress(context),
      isLoading: editProfileModel.loading,
      child: Scaffold(
        key: editProfileModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Edit Profile'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25),
                child: GestureDetector(
                  onTap: () => editProfileModel.EditProfile(context),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => editProfileModel.pickImage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: const Offset(0, 0),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: editProfileModel.imgLink != null
                      ? Padding(
                          padding: const EdgeInsets.all(1),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundImage:
                                NetworkImage(editProfileModel.imgLink!),
                          ),
                        )
                      : editProfileModel.image == null
                          ? Padding(
                              padding: const EdgeInsets.all(1),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundImage:
                                    NetworkImage(widget.user!.photoUrl!),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(1),
                              child: CircleAvatar(
                                radius: 65,
                                backgroundImage:
                                    FileImage(editProfileModel.image!),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            buildForm(editProfileModel, context),
          ],
        ),
      ),
    );
  }

  buildForm(EditProfileModel editProfileModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: editProfileModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormBuilder(
              enabled: !editProfileModel.loading,
              initialValue: widget.user!.username,
              prefix: Ionicons.person_outline,
              hintText: 'Username',
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                editProfileModel.setUsername(val);
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Bio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              maxLines: null,
              initialValue: widget.user!.bio,
              validator: (String? value) {
                if (value!.length > 200) {
                  return 'Bio is too long';
                }
                return null;
              },
              onSaved: (String? val) {
                editProfileModel.setBio(val!);
              },
              onChanged: (String val) {
                editProfileModel.setBio(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
