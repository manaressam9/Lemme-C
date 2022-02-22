import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:object_detection/modules/volunteer/ui/volunteer_screen/cubit/states.dart';
import 'package:object_detection/shared/constants.dart';

import '../../../data/location/location_api.dart';


class VolunteerCubit extends Cubit<VolunteerStates> {
  VolunteerCubit() : super(InitialState());

  static VolunteerCubit get(context) => BlocProvider.of(context);

  onVolunteerRequest() async {
    emit(RequestLoading());
    await LocationApi.sendRealTimeLocationUpdates();
    emit(LocationApi.requestState);
  }
}
