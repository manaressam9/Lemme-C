
abstract class RegisterStates {}

class RegisterInitState extends RegisterStates{}

class RegisterFirstStageCompletedState extends RegisterStates{}

class RegisterLoadingState extends RegisterStates{}

// phone verification screen states
class PhoneCodeSentState extends RegisterStates{}
class PhoneCodeResentState extends RegisterStates{}
class PhoneVerificationLoading extends RegisterStates{}
class PhoneAutoVerification extends RegisterStates{}
class AutoVerificationTimeOut extends RegisterStates{}
class VerificationFailed extends RegisterStates{
  final String errMessage ;

  VerificationFailed(this.errMessage);
}


class RegisterSuccessState extends RegisterStates{}
class VerificationSuccessState extends RegisterStates{}
class PhoneAlreadyExist extends RegisterStates{}
class PhoneNotExist extends RegisterStates{}
class PhoneFilteringLoadingState extends RegisterStates{}

class RegisterErrorState extends RegisterStates{
  final String errorMsg ;
  RegisterErrorState(this.errorMsg);
}



//password visibility
class RegisterSecureVisibilityChangeState extends RegisterStates {}
class RegisterPositionVisibilityChangeState extends RegisterStates {}

class LoginRegSwitch extends RegisterStates {}

//volunteer screen
class RequestLoading extends RegisterStates {}
class RequestFailed extends RegisterStates{}
class RequestSucceeded extends RegisterStates{}

