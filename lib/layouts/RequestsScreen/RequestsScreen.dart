import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volunteer_application/layouts/RequestsScreen/cubit/cubit.dart';
import 'package:volunteer_application/layouts/RequestsScreen/cubit/states.dart';
import 'package:volunteer_application/layouts/register/register_screen.dart';
import 'package:volunteer_application/models/User.dart';
import 'package:volunteer_application/models/UserLocation.dart';
import 'package:volunteer_application/shared/components.dart';
import 'package:volunteer_application/shared/constants.dart';
import 'package:volunteer_application/shared/remote/user_firebase.dart';
import 'package:volunteer_application/strings.dart';

import '../../models/Request.dart';
import '../../shared/styles/colors.dart';
import '../map_screen/cubit/mab_box_screen.dart';

class RequestsScreen extends StatelessWidget {
  late RequestsCubit cubit;
  late RequestStates state ;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RequestsCubit()..getRequests()..checkLocationPermission(),
      child: BlocConsumer<RequestsCubit, RequestStates>(
        listener: (context, state) => {
          this.state=state
        },
        builder: (context, state) {
          cubit = RequestsCubit.get(context);
          return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Requests',
                ),
                titleSpacing: 20,
                leading: const Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Image(
                    image: AssetImage(CHECKHAND_IMG),
                  ),
                ),
                leadingWidth: 50,
                actions: [
                  IconButton(
                      onPressed: () {
                        {
                          cubit.signOut();
                          navigateAndFinish(context, RegisterScreen());
                        }
                      },
                      icon: const Icon(Icons.logout))
                ],
              ),
              body: state is RequestsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: BLACK_COLOR,
                        strokeWidth: 2,
                      ),
                    )
                  : (state is RequestsRead && cubit.requestsList.isNotEmpty
                      ? buildRequestsList()
                      : const Center(
                          child: Text(
                          'There are no requests',
                          style: TextStyle(
                              color: GREY_COLOR,
                              fontSize: 16,
                              fontFamily: LIGHT_FONT),
                        ))));
        },
      ),
    );
  }

  buildRequestsList() => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
            itemBuilder: (context, index) => buildRequestItem(
                cubit.requestsList[index], cubit.addresses[index], context,index),
            itemCount: cubit.requestsList.length),
      );

  buildRequestItem(Request request, String address, context,int index) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        height: 130,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            buildRow1(request.blindData, address, request.getReadableDate()),
            const Spacer(),
            buildRow2(context, request.blindLocation,request.blindData.phone,index)
          ],
        ),
      ),
    );
  }

  buildRow1(UserModel user, String location, String date) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCircleImage(user.picture),
        const SizedBox(width: 10),
        buildNameWithLocationColumn(user.fullName, location),
        Text(
          date,
          style: const TextStyle(
              fontFamily: LIGHT_FONT, color: GREY_COLOR, fontSize: 10),
        )
      ],
    );
  }

  buildCircleImage(String? imageUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
          color: WHITE_COLOR,
          shape: BoxShape.circle,
          border: Border.all(color: MAIN_COLOR, width: 2),
          image: DecorationImage(
              image: imageUrl != null
                  ? NetworkImage(imageUrl)
                  : const AssetImage(AVATAR_IMG) as ImageProvider,
              fit: BoxFit.cover)),
    );
  }

  buildNameWithLocationColumn(String name, String location) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(color: BLACK_COLOR, fontSize: 14),
            ),
            buildVerticalSpace(height: 2),
            Text(
              location,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GREY_COLOR,
                fontFamily: LIGHT_FONT,
                fontSize: 10,
              ),
            ),
          ],
        ),
      );

  buildRow2(context,MyUserLocation location , String phone, int index) => Row(
        children: [
          Container(
              width: 80,
              child: state is RequestAccepted && (state as RequestAccepted).acceptedRequestIndex == index?
                  const Text('Accepted'):
                  MaterialButton(
                    onPressed: () {
                      _displayDialog(context,index);
                    },
                    color: MAIN_COLOR,
                    textColor: PRIMARY_SWATCH,
                    child: const Text('Accept'),
                  )
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
              width: 80,
              child: MaterialButton(
                onPressed: () {

                },
                color: GREY_COLOR,
                textColor: PRIMARY_SWATCH,
                child: const Text('Refuse'),
              )),
          const Spacer(),
          InkWell(
            onTap: () {
              navigate(context, MabBoxScreen(location,phone));
            },
            child: const Text(
              'See location on the map',
              style: TextStyle(
                  fontFamily: REGULAR_FONT, color: BLACK_COLOR, fontSize: 11),
            ),
          )
        ],
      );

  _displayDialog(BuildContext context, int requestIndex) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you will serve this request?'),
            actions: <Widget>[
               MaterialButton(
                child:  const Text('Yes'),
                onPressed: () {
                  cubit.acceptRequest(requestIndex);
                  Navigator.of(context).pop();
                },
              ),MaterialButton(
                child:  const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

            ],
          );
        });
  }

}
