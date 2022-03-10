import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_detection/modules/volunteer/ui/login/cubit/states.dart';
import 'package:object_detection/modules/volunteer/ui/login/login_screen.dart';

class LoginCubit extends Cubit<InitialLoginState>
{
  LoginCubit() : super(InitialLoginState());
  static LoginCubit get(context) => BlocProvider.of(context);

  login()
  {

  }

}