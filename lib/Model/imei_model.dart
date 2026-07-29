class IMEIModel {
  final int? id;
  final String? imei;
  final String? vehicleNo;

  IMEIModel({
    this.id,
    this.imei,
    this.vehicleNo,
  });

  factory IMEIModel.fromJson(dynamic json) {
    if (json == null) return IMEIModel();
    if (json is String || json is int || json is double) {
      return IMEIModel(imei: json.toString().trim());
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      dynamic getValueForKeys(List<String> candidateKeys) {
        for (var entry in map.entries) {
          final lowerKey = entry.key
              .toString()
              .toLowerCase()
              .replaceAll('_', '')
              .replaceAll('-', '')
              .replaceAll(' ', '');
          for (var cand in candidateKeys) {
            final lowerCand = cand
                .toLowerCase()
                .replaceAll('_', '')
                .replaceAll('-', '')
                .replaceAll(' ', '');
            if (lowerKey == lowerCand) {
              if (entry.value != null &&
                  entry.value.toString().trim().isNotEmpty) {
                return entry.value;
              }
            }
          }
        }
        return null;
      }

      dynamic rawImei = getValueForKeys([
        "imei",
        "deviceimei",
        "imeino",
        "deviceid",
        "devicenumber",
        "imeinumber",
        "serialnumber",
        "serialno",
        "code",
        "name",
        "value",
      ]);

      dynamic rawVehicle = getValueForKeys([
        "vehicleno",
        "vehiclenumber",
        "vehno",
        "registrationno",
        "regno",
        "vehicle",
      ]);

      if ((rawImei == null || rawImei.toString().trim().isEmpty)) {
        for (var val in map.values) {
          if (val is Map) {
            final nested = IMEIModel.fromJson(val);
            if (nested.imei != null && nested.imei!.trim().isNotEmpty) {
              return nested;
            }
          }
        }
      }

      final rawId = map["id"] is int
          ? map["id"] as int?
          : int.tryParse(map["id"]?.toString() ??
              getValueForKeys(["id"])?.toString() ??
              '');

      return IMEIModel(
        id: rawId,
        imei: (rawImei ?? "").toString().trim(),
        vehicleNo: (rawVehicle ?? "").toString().trim(),
      );
    }
    return IMEIModel();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id ?? 0,
      "imei": imei ?? "",
      "vehicle_no": vehicleNo ?? "",
    };
  }

  static List<IMEIModel> fromJsonList(List<dynamic>? list) {
    return list?.map((e) => IMEIModel.fromJson(e)).toList() ?? [];
  }
}
