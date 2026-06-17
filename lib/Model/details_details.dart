class Command {
  int id;
  String command;

  Command({
    required this.id,
    required this.command,
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
        id: _parseInt(json["id"]),
        command: _parseString(json["command"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "command": command,
      };
}

class DeviceDetails {
  int id;
  String imei;
  dynamic firmwareVersion;
  int power;
  int gnssFix;
  int gsmSignalStrength;
  int ignition;
  String primaryMobileNumber;
  String secondaryMobileNumber;
  String networkProvider;
  String simProvider;
  DateTime? simActivationDate;
  DateTime? expirationtime;
  String latitude;
  String longitude;
  String alertId;
  String deviceModel;
  dynamic lastUpdateDate;
  dynamic lastUpdateTime;

  DeviceDetails(
      {required this.id,
      required this.imei,
      required this.firmwareVersion,
      required this.power,
      required this.gnssFix,
      required this.gsmSignalStrength,
      required this.ignition,
      required this.primaryMobileNumber,
      required this.secondaryMobileNumber,
      required this.networkProvider,
      required this.simProvider,
      required this.simActivationDate,
      required this.expirationtime,
      required this.latitude,
      required this.longitude,
      required this.alertId,
      required this.deviceModel,
      required this.lastUpdateDate,
      required this.lastUpdateTime});

  factory DeviceDetails.fromJson(Map<String, dynamic> json) => DeviceDetails(
        id: _parseInt(json["id"]),
        imei: _parseString(json["imei"]),
        firmwareVersion: json["firmware_version"],
        power: _parseInt(json["power"]),
        gnssFix: _parseInt(json["gnss_fix"]),
        gsmSignalStrength: _parseInt(json["gsm_signal_strength"]),
        ignition: _parseInt(json["ignition"]),
        primaryMobileNumber: _parseString(json["primary_mobile_number"]),
        secondaryMobileNumber: _parseString(json["secondary_mobile_number"]),
        networkProvider: _parseString(json["network_provider"]),
        simProvider: _parseString(json["sim_provider"]),
        simActivationDate: json["sim_activation_date"] == null ||
                json["sim_activation_date"].toString().isEmpty
            ? null
            : DateTime.tryParse(json["sim_activation_date"].toString()),
        expirationtime: json["expirationtime"] == null ||
                json["expirationtime"].toString().isEmpty
            ? null
            : DateTime.tryParse(json["expirationtime"].toString()),
        latitude: _parseString(json["latitude"] ?? "0.00"),
        longitude: _parseString(json["longitude"] ?? "0.00"),
        alertId: _parseString(json["alert_id"]),
        deviceModel: _parseString(json["device_model"]),
        lastUpdateDate: json["lastupdate_date"],
        lastUpdateTime: json["lastupdate_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "imei": imei,
        "firmware_version": firmwareVersion,
        "power": power,
        "gnss_fix": gnssFix,
        "gsm_signal_strength": gsmSignalStrength,
        "ignition": ignition,
        "primary_mobile_number": primaryMobileNumber,
        "secondary_mobile_number": secondaryMobileNumber,
        "network_provider": networkProvider,
        "sim_provider": simProvider,
        "sim_activation_date": simActivationDate,
        "expirationtime": expirationtime,
        "latitude": latitude,
        "longitude": longitude,
        "alert_id": alertId,
        "device_model": deviceModel,
        "lastupdate_date": lastUpdateDate,
        "lastupdate_time": lastUpdateTime,
      };
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ??
      double.tryParse(value.toString())?.toInt() ??
      0;
}

String _parseString(dynamic value) {
  if (value == null) return "";
  return value.toString();
}
