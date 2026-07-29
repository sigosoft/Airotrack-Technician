class APIConfig {
  // static String BASE_URL =
  //     "https://dev-api.airotrack.in/airotrack-api/public/technician/";
  static String BASE_URL = "https://api.airotrack.in/technician/";
  static String Image_URL = "https://api.airotrack.in/storage/app/public/";
  // static String BASE_URL = "https://dev-api.airotrack.in/technician/";
  // static String BASE_URL = "https://api.airotrack.in/technician/";
}

class APIEndpoints {
  static const String command = "commands";
  static const String contactUs = "contactUs";
  static const String deviceDetails = "deviceDetails";
  static const String deviceDetailswithId = "deviceDetailsWithId";
  static const String home = "spdHome";
  static const String login = "login";
  static const String logout = "logout";
  static const String sendCommand = "sendCommand";
  static const String setting = "settings";
  static const String checkIn = "spdCheckIn";
  static const String workDetails = "spdWorkDetails";
  static const String requestCancelling = "cancelRequest";
  static const String generateQrCode = "generateQrCode";
  static const String generateProductCertificate = "generateWorkCertificate";
  static const String postNewWorkDetails = "spdCreateWork";
  static const String fetchRto = "rtoList";
  static const String allDevices = "allDevices";
  static const String vehicleTypes = "spdVehicleTypes";
  static const String checkout = "spdCheckOut";
  static const String companyTitles = "spdCompanyTitles";
  static const String getSpeedGovernorData = "getSpeedGovernorData";
  static const String acceptWork = "spdAcceptWork";
  static const String postCheckoutConfirm = "spdCheckOutConfirm";

  static const String earnings = "spdEarnings";
  static const String rcentJobs = "recentJobs";
  static const String dealerDevices = "dealerDevices";
}
