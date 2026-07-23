/// GraphQL mutations for authentication
/// Bagisto API: customerLogin, customerSignUp, forgotPassword, customerLogout
library;

const String loginMutation = r'''
  mutation loginCustomer($input: LoginInput!) {
    customerLogin(input: $input) {
      success
      message
      token: accessToken
      customer {
        id
      }
    }
  }
''';

const String registerMutation = r'''
  mutation registerCustomer($input: SignUpInput!) {
    customerSignUp(input: $input) {
      success
      message
      accessToken
      customer {
        id
        firstName
        lastName
        email
        phone
        status
        apiToken
        customerGroupId
        subscribedToNewsLetter
        isVerified
        isSuspended
        token
        rememberToken
        name
      }
    }
  }
''';

const String forgotPasswordMutation = r'''
  mutation forgotPassword($email: String!) {
    forgotPassword(email: $email) {
      success
      message
    }
  }
''';

const String logoutMutation = r'''
  mutation customerLogout {
    customerLogout {
      success
      message
    }
  }
''';
