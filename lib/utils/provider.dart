import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_simulation/screens/edit_profile_screen/edit_profile_model/edit_profile_model.dart';
import 'package:social_media_simulation/screens/forgot_password_screen/forgot_password_model/forgot_password_model.dart';
import 'package:social_media_simulation/screens/login_screen/login_model/login_model.dart';
import 'package:social_media_simulation/screens/register_screen/register_model/register_model.dart';
import 'package:social_media_simulation/view_model/status_view_model.dart';
import 'package:social_media_simulation/view_model/theme_view.dart';
import 'package:social_media_simulation/screens/post_screen/post_view_model/post_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginModel()),
  ChangeNotifierProvider(create: (_) => ThemeView()),
  ChangeNotifierProvider(create: (_) => RegisterModel()),
  ChangeNotifierProvider(create: (_) => ForgotPasswordModel()),
  ChangeNotifierProvider(create: (_) => EditProfileModel()),
  ChangeNotifierProvider(create: (_) => StatusViewModel()),
  ChangeNotifierProvider(create: (_) => PostViewModel()),
];
