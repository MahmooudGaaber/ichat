abstract class AuthStates {}

class AuthInitialState extends AuthStates {}
class AuthLoadingState extends AuthStates {}
class AuthDoneState extends AuthStates {}
class AuthCanceledState extends AuthStates {}
class AuthErrorState extends AuthStates {}