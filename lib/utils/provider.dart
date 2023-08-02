import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_simulation/view_model/chat_view_model/chat_view_model.dart';
import 'package:social_media_simulation/view_model/edit_profile_view_model/edit_profile_view_model.dart';
import 'package:social_media_simulation/view_model/forgot_password_view_model/forgot_password_view_model.dart';
import 'package:social_media_simulation/view_model/login_view_model/login_view_model.dart';
import 'package:social_media_simulation/view_model/register_view_model/register_model.dart';
import 'package:social_media_simulation/view_model/story_view_model/story_view_model.dart';
import 'package:social_media_simulation/view_model/theme/theme_view_model.dart';
import 'package:social_media_simulation/view_model/post_view_model/post_view_model.dart';
import 'package:social_media_simulation/view_model/user/user_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeView()),
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => PostViewModel()),
  ChangeNotifierProvider(create: (_) => ChatViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => StoryViewModel()),
];
