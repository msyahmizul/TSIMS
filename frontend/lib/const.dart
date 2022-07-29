class Backend {
  static const graphQLAPI = "https://api.tsims.ml/query";
  static const adminToken =
      "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTYxNjY0NDEsIlVzZXJuYW1lIjoiYWRtaW4iLCJVc2VyVHlwZSI6IkFETUlOIiwiVXNlckRvY3VtZW50c0lkIjoiNjI2MjcwOGEzZTg3YzcyNTNkZjQifQ.Ti51z2PK8Q_Oom0t-6rIeNwQGp7xBUdavwp22reyB0XKqTOsrT0R2_DtyZ7FxIbq5rH0zFlxXtrynJH_TaDqVg";
  static const Map<String, String> headerAPINetworkImage = {
    "X-Appwrite-Project": "TSIMS",
    "X-Appwrite-key":
        "0e8ac8b62c9cddfa915c9e00bafb2b203003e9191934307af5727a98ea972c13615c219c8e6f5da17eef9fdca49afae3b32c5e4ea8bbabf423af4568fdb11ad5b8f4854266fc3a98e6009305d457f6500e0f2cac83267a6558e11577c1887c834caacf633b43974584380fbbe8fa20f15da14a99cf6dfdb9172ca826853cfb02"
  };
  static const bucketStorageID = "6258f43b8f7c36f5e38d";
}

class AgentURL {
  // static const gov = "http://192.168.88.20:3001";

  static const multiTenant = "https://user.tsims.ml";
  static const gov = "https://gov.tsims.ml";
  static const banking = "https://bank.tsims.ml";
  static const carrier = "https://carrier.tsims.ml";
  static const university = "https://uni.tsims.ml";
  static const agentAPIKey =
      "QYyQxVInTclHk1jJCwPw1sRu+pjAW5a6G8Razf443emGx6u6wL2e0W9kmaGY3Yp5";
}

class AgentSchemaID {
  static const gov = "LHYo5MpgGxp2VdeCSrkeC4:2:userData:7.0";
  static const banking = "PM26otMJK3DSJyrwmzUoKK:2:bankData:2.0";
  static const carrier = "CQqj2HRphzy6iQpWoyfmze:2:carrierData:4.0";
  static const university = "NkETghJchU8CjHJYhADyBD:2:universityData:2.0";
}

class AgentCredDefID {
  static const banking = "PM26otMJK3DSJyrwmzUoKK:3:CL:67:primary";
  static const carrier = "CQqj2HRphzy6iQpWoyfmze:3:CL:73:primary";
  static const university = "NkETghJchU8CjHJYhADyBD:3:CL:79:primary";
}

class BoxName {
  static const name = "TSIMS";
  static const jwtKey = "jwtKey";
  static const pinNumber = "pin";
  static const userData = "userData";
  static const walletData = "walletData";
  static const applicantStatus = "applicantStatus";
  static const walletAutToken = "walletAutToken";
}

enum QRType { connectionRequest, invalid }

class RegexUtil {
  static final username =
      RegExp(r'^[a-zA-Z0-9]([._-](?![._-])|[a-zA-Z0-9]){3,18}[a-zA-Z0-9]$');
}

typedef WidgetTextInputValidateFunction = String? Function(String? input);

class Validator {
  static WidgetTextInputValidateFunction ic = (String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return "IC cannot empty";
      }
      if (value.length != 12) {
        return "IC must be length of 12 digit";
      }
    }
    return null;
  };

  static WidgetTextInputValidateFunction notEmpty = (String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return "Value is required";
      }
    }
    return null;
  };
  static WidgetTextInputValidateFunction username = (String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return "Value is required";
      }
      if (value.length <= 5) {
        return "Minimum of 5 char required";
      }
      if (!RegexUtil.username.hasMatch(value)) {
        return "Invalid char in username";
      }
    }
    return null;
  };
}
