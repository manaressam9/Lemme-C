
abstract class RequestStates {}

class RequestInitState extends RequestStates{}
class RequestsRead extends RequestStates{}
class RequestsLoading extends RequestStates{}
class RequestAccepted extends RequestStates{
  int acceptedRequestIndex ;
  RequestAccepted(this.acceptedRequestIndex);

}