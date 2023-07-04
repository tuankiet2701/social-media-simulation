import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_simulation/screens/login_screen/login_model/login_model.dart';
import 'package:social_media_simulation/theme/theme_view.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => LoginModel()),
  ChangeNotifierProvider(create: (_) => ThemeView()),
];
