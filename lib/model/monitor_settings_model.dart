class MonitorSettingsModel {
  final bool autoDateAndTime;
  final bool lockAccounts;
  final bool lockPasscode;
  final bool denySiri;
  final bool denyInAppPurchases;
  final int? maximumRating;
  final bool requirePasswordForPurchases;
  final bool denyExplicitContent;
  final bool denyMultiplayerGaming;
  final bool denyMusicService;
  final bool denyAddingFriends;

  MonitorSettingsModel({
    required this.autoDateAndTime,
    required this.lockAccounts,
    required this.lockPasscode,
    required this.denySiri,
    required this.denyInAppPurchases,
    this.maximumRating,
    required this.requirePasswordForPurchases,
    required this.denyExplicitContent,
    required this.denyMultiplayerGaming,
    required this.denyMusicService,
    required this.denyAddingFriends,
  });

  MonitorSettingsModel copyWith({
    bool? autoDateAndTime,
    bool? lockAccounts,
    bool? lockPasscode,
    bool? denySiri,
    bool? denyInAppPurchases,
    int? maximumRating,
    bool? requirePasswordForPurchases,
    bool? denyExplicitContent,
    bool? denyMultiplayerGaming,
    bool? denyMusicService,
    bool? denyAddingFriends,
  }) {
    return MonitorSettingsModel(
      autoDateAndTime: autoDateAndTime ?? this.autoDateAndTime,
      lockAccounts: lockAccounts ?? this.lockAccounts,
      lockPasscode: lockPasscode ?? this.lockPasscode,
      denySiri: denySiri ?? this.denySiri,
      denyInAppPurchases: denyInAppPurchases ?? this.denyInAppPurchases,
      requirePasswordForPurchases:
          requirePasswordForPurchases ?? this.requirePasswordForPurchases,
      maximumRating: maximumRating ?? this.maximumRating,
      denyExplicitContent: denyExplicitContent ?? this.denyExplicitContent,
      denyMultiplayerGaming:
          denyMultiplayerGaming ?? this.denyMultiplayerGaming,
      denyMusicService: denyMusicService ?? this.denyMusicService,
      denyAddingFriends: denyAddingFriends ?? this.denyAddingFriends,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoDateAndTime': autoDateAndTime,
      'lockAccounts': lockAccounts,
      'lockPasscode': lockPasscode,
      'denySiri': denySiri,
      'denyInAppPurchases': denyInAppPurchases,
      'maximumRating': maximumRating ?? 1000,
      'requirePasswordForPurchases': requirePasswordForPurchases,
      'denyExplicitContent': denyExplicitContent,
      'denyMultiplayerGaming': denyMultiplayerGaming,
      'denyMusicService': denyMusicService,
      'denyAddingFriends': denyAddingFriends,
    };
  }

  factory MonitorSettingsModel.fromMap(Map<dynamic, dynamic> map) {
    return MonitorSettingsModel(
      autoDateAndTime: map['autoDateAndTime'] ?? true,
      lockAccounts: map['lockAccounts'] ?? false,
      lockPasscode: map['lockPasscode'] ?? false,
      denySiri: map['denySiri'] ?? false,
      denyInAppPurchases: map['denyInAppPurchases'] ?? false,
      maximumRating: map['maximumRating'] ?? 1000,
      requirePasswordForPurchases: map['requirePasswordForPurchases'] ?? false,
      denyExplicitContent: map['denyExplicitContent'] ?? true,
      denyMultiplayerGaming: map['denyMultiplayerGaming'] ?? false,
      denyMusicService: map['denyMusicService'] ?? false,
      denyAddingFriends: map['denyAddingFriends'] ?? false,
    );
  }
}
