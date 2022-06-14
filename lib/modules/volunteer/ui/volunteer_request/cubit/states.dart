
abstract class VolunteerRequestStates {}

class RegisterInitState extends VolunteerRequestStates{}

class RegisterFirstStageCompletedState extends VolunteerRequestStates{}
class RegisterFirstStageFailedState extends VolunteerRequestStates{}
class LoginFirstStageFailedState extends VolunteerRequestStates{}
class LoginFirstStageCompletedState extends VolunteerRequestStates{}


// phone verification screen states
class PhoneCodeSentState extends VolunteerRequestStates{}
class PhoneCodeResentState extends VolunteerRequestStates{}
class PhoneVerificationLoading extends VolunteerRequestStates{}
class PhoneAutoVerification extends VolunteerRequestStates{}
class AutoVerificationTimeOut extends VolunteerRequestStates{}
class VerificationFailed extends VolunteerRequestStates{
  final String errMessage ;

  VerificationFailed(this.errMessage);
}


class RegisterSuccessState extends VolunteerRequestStates{}
class VerificationSuccessState extends VolunteerRequestStates{}
class PhoneAlreadyExist extends VolunteerRequestStates{}
class PhoneNotExist extends VolunteerRequestStates{}
class PhoneFilteringLoadingState extends VolunteerRequestStates{}

class RegisterErrorState extends VolunteerRequestStates{
  final String errorMsg ;
  RegisterErrorState(this.errorMsg);
}



//password visibility
class RegisterSecureVisibilityChangeState extends VolunteerRequestStates {}
class RegisterPositionVisibilityChangeState extends VolunteerRequestStates {}

class LoginRegSwitch extends VolunteerRequestStates {}

//volunteer screen
class RequestLoading extends VolunteerRequestStates {}
class RequestFailed extends VolunteerRequestStates{}
class RequestSucceeded extends VolunteerRequestStates{}
class ResponseWaited extends VolunteerRequestStates{}
class ResponseSent extends VolunteerRequestStates{}

