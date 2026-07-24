/// GraphQL mutations for authentication
/// Bagisto API: customerLogin, customerSignUp, forgotPassword, customerLogout
library;

const String loginMutation = r'''
  mutation loginCustomer($email: String!, $password: String!) {
    customerLogin(input: { email: $email, password: $password }) {
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

const String registerMutation = r'''
  mutation registerCustomer(
    $firstName: String!,
    $lastName: String!,
    $email: String!,
    $password: String!,
    $passwordConfirmation: String!
  ) {
    customerSignUp(input: {
      firstName: $firstName,
      lastName: $lastName,
      email: $email,
      password: $password,
      passwordConfirmation: $passwordConfirmation,
      subscribedToNewsLetter: true,
      agreement: true
    }) {
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
