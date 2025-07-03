class WeatherAlert {
  final String id;
  final String event;
  final String severity;
  final String urgency;
  final String certainty;
  final String effective;
  final String? expires;
  final String description;
  final String instruction;
  final String area;
  final String? polygon;
  final String status;
  final String scope;
  final String msgType;
  final String backgroundColor;
  final String textColor;
  final String issued;

  WeatherAlert({
    required this.id,
    required this.event,
    required this.severity,
    required this.urgency,
    required this.certainty,
    required this.effective,
    this.expires,
    required this.description,
    required this.instruction,
    required this.area,
    this.polygon,
    required this.status,
    required this.scope,
    required this.msgType,
    required this.backgroundColor,
    required this.textColor,
    required this.issued,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'severity': severity,
      'urgency': urgency,
      'certainty': certainty,
      'effective': effective,
      'expires': expires,
      'description': description,
      'instruction': instruction,
      'area': area,
      'polygon': polygon,
      'status': status,
      'scope': scope,
      'msgType': msgType,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'issued': issued,
    };
  }

  // Create from JSON
  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] as String,
      event: json['event'] as String,
      severity: json['severity'] as String,
      urgency: json['urgency'] as String,
      certainty: json['certainty'] as String,
      effective: json['effective'] as String,
      expires: json['expires'] as String?,
      description: json['description'] as String,
      instruction: json['instruction'] as String,
      area: json['area'] as String,
      polygon: json['polygon'] as String?,
      status: json['status'] as String,
      scope: json['scope'] as String,
      msgType: json['msgType'] as String,
      backgroundColor: json['backgroundColor'] as String,
      textColor: json['textColor'] as String,
      issued: json['issued'] as String,
    );
  }

  // Get severity level (1-150, lower is more severe)
  int get severityLevel {
    final event = this.event.toLowerCase();
    if (event.contains('tsunami warning')) return 1;
    if (event.contains('tornado warning')) return 2;
    if (event.contains('extreme wind warning')) return 3;
    if (event.contains('severe thunderstorm warning')) return 4;
    if (event.contains('flash flood warning')) return 5;
    if (event.contains('flash flood statement')) return 6;
    if (event.contains('severe weather statement')) return 7;
    if (event.contains('shelter in place warning')) return 8;
    if (event.contains('evacuation immediate')) return 9;
    if (event.contains('civil danger warning')) return 10;
    if (event.contains('nuclear power plant warning')) return 11;
    if (event.contains('radiological hazard warning')) return 12;
    if (event.contains('hazardous materials warning')) return 13;
    if (event.contains('fire warning')) return 14;
    if (event.contains('civil emergency message')) return 15;
    if (event.contains('law enforcement warning')) return 16;
    if (event.contains('storm surge warning')) return 17;
    if (event.contains('hurricane force wind warning')) return 18;
    if (event.contains('hurricane warning')) return 19;
    if (event.contains('typhoon warning')) return 20;
    if (event.contains('special marine warning')) return 21;
    if (event.contains('blizzard warning')) return 22;
    if (event.contains('snow squall warning')) return 23;
    if (event.contains('ice storm warning')) return 24;
    if (event.contains('heavy freezing spray warning')) return 25;
    if (event.contains('winter storm warning')) return 26;
    if (event.contains('lake effect snow warning')) return 27;
    if (event.contains('dust storm warning')) return 28;
    if (event.contains('blowing dust warning')) return 29;
    if (event.contains('high wind warning')) return 30;
    if (event.contains('tropical storm warning')) return 31;
    if (event.contains('storm warning')) return 32;
    if (event.contains('tsunami advisory')) return 33;
    if (event.contains('tsunami watch')) return 34;
    if (event.contains('avalanche warning')) return 35;
    if (event.contains('earthquake warning')) return 36;
    if (event.contains('volcano warning')) return 37;
    if (event.contains('ashfall warning')) return 38;
    if (event.contains('flood warning')) return 39;
    if (event.contains('coastal flood warning')) return 40;
    if (event.contains('lakeshore flood warning')) return 41;
    if (event.contains('ashfall advisory')) return 42;
    if (event.contains('high surf warning')) return 43;
    if (event.contains('excessive heat warning')) return 44;
    if (event.contains('tornado watch')) return 45;
    if (event.contains('severe thunderstorm watch')) return 46;
    if (event.contains('flash flood watch')) return 47;
    if (event.contains('gale warning')) return 48;
    if (event.contains('flood statement')) return 49;
    if (event.contains('extreme cold warning')) return 50;
    if (event.contains('freeze warning')) return 51;
    if (event.contains('red flag warning')) return 52;
    if (event.contains('storm surge watch')) return 53;
    if (event.contains('hurricane watch')) return 54;
    if (event.contains('hurricane force wind watch')) return 55;
    if (event.contains('typhoon watch')) return 56;
    if (event.contains('tropical storm watch')) return 57;
    if (event.contains('storm watch')) return 58;
    if (event.contains('tropical cyclone local statement')) return 59;
    if (event.contains('winter weather advisory')) return 60;
    if (event.contains('avalanche advisory')) return 61;
    if (event.contains('cold weather advisory')) return 62;
    if (event.contains('heat advisory')) return 63;
    if (event.contains('flood advisory')) return 64;
    if (event.contains('coastal flood advisory')) return 65;
    if (event.contains('lakeshore flood advisory')) return 66;
    if (event.contains('high surf advisory')) return 67;
    if (event.contains('dense fog advisory')) return 68;
    if (event.contains('dense smoke advisory')) return 69;
    if (event.contains('small craft advisory')) return 70;
    if (event.contains('brisk wind advisory')) return 71;
    if (event.contains('hazardous seas warning')) return 72;
    if (event.contains('dust advisory')) return 73;
    if (event.contains('blowing dust advisory')) return 74;
    if (event.contains('lake wind advisory')) return 75;
    if (event.contains('wind advisory')) return 76;
    if (event.contains('frost advisory')) return 77;
    if (event.contains('freezing fog advisory')) return 78;
    if (event.contains('freezing spray advisory')) return 79;
    if (event.contains('low water advisory')) return 80;
    if (event.contains('local area emergency')) return 81;
    if (event.contains('winter storm watch')) return 82;
    if (event.contains('rip current statement')) return 83;
    if (event.contains('beach hazards statement')) return 84;
    if (event.contains('gale watch')) return 85;
    if (event.contains('avalanche watch')) return 86;
    if (event.contains('hazardous seas watch')) return 87;
    if (event.contains('heavy freezing spray watch')) return 88;
    if (event.contains('flood watch')) return 89;
    if (event.contains('coastal flood watch')) return 90;
    if (event.contains('lakeshore flood watch')) return 91;
    if (event.contains('high wind watch')) return 92;
    if (event.contains('excessive heat watch')) return 93;
    if (event.contains('extreme cold watch')) return 94;
    if (event.contains('freeze watch')) return 95;
    if (event.contains('fire weather watch')) return 96;
    if (event.contains('extreme fire danger')) return 97;
    if (event.contains('911 telephone outage')) return 98;
    if (event.contains('coastal flood statement')) return 99;
    if (event.contains('lakeshore flood statement')) return 100;
    if (event.contains('special weather statement')) return 101;
    if (event.contains('marine weather statement')) return 102;
    if (event.contains('air quality alert')) return 103;
    if (event.contains('air stagnation advisory')) return 104;
    if (event.contains('hazardous weather outlook')) return 105;
    if (event.contains('hydrologic outlook')) return 106;
    if (event.contains('short term forecast')) return 107;
    if (event.contains('administrative message')) return 108;
    if (event.contains('test')) return 109;
    if (event.contains('child abduction emergency')) return 110;
    if (event.contains('blue alert')) return 111;

    // Default severity levels based on alert type
    if (event.contains('warning')) return 46;
    if (event.contains('advisory')) return 83;
    if (event.contains('watch')) return 119;
    if (event.contains('statement')) return 139;
    if (event.contains('air')) return 140;
    if (event.contains('short')) return 136;
    if (event.contains('emergency')) return 145;
    if (event.contains('outage')) return 146;
    if (event.contains('no alerts')) return 150;

    return 149; // Default for unknown alert types
  }

  // Get icon based on event type
  String get icon {
    if (event.toLowerCase().contains('tornado')) return 'tornado';
    if (event.toLowerCase().contains('thunderstorm')) return 'flash_on';
    if (event.toLowerCase().contains('flood')) return 'water';
    if (event.toLowerCase().contains('winter') || event.toLowerCase().contains('snow')) return 'ac_unit';
    if (event.toLowerCase().contains('heat')) return 'wb_sunny';
    if (event.toLowerCase().contains('wind')) return 'air';
    if (event.toLowerCase().contains('freeze') || event.toLowerCase().contains('frost')) return 'thermostat';
    return 'warning';
  }

  // Get alert colors based on event type and severity
  static Map<String, String> getAlertColors(String event, String severity) {
    final eventLower = event.toLowerCase();
    final severityLower = severity.toLowerCase();
    
    // Warning colors (red)
    if (severityLower == 'extreme' || severityLower == 'severe' || 
        eventLower.contains('warning')) {
      return {
        'backgroundColor': '#FF0000',
        'textColor': '#FFFFFF'
      };
    }
    
    // Watch colors (yellow)
    if (eventLower.contains('watch')) {
      return {
        'backgroundColor': '#FFD700',
        'textColor': '#000000'
      };
    }
    
    // Advisory colors (yellow)
    if (eventLower.contains('advisory')) {
      return {
        'backgroundColor': '#FFFF00',
        'textColor': '#000000'
      };
    }
    
    // Statement colors (blue)
    if (eventLower.contains('statement')) {
      return {
        'backgroundColor': '#00BFFF',
        'textColor': '#000000'
      };
    }
    
    // Outlook colors (green)
    if (eventLower.contains('outlook')) {
      return {
        'backgroundColor': '#00FF00',
        'textColor': '#000000'
      };
    }
    
    // Emergency colors (purple)
    if (eventLower.contains('emergency')) {
      return {
        'backgroundColor': '#800080',
        'textColor': '#FFFFFF'
      };
    }
    
    // Default colors (gray)
    return {
      'backgroundColor': '#808080',
      'textColor': '#FFFFFF'
    };
  }

  // Get the timing type of the alert (Expected vs Immediate)
  String get timingType {
    if (msgType.toLowerCase() == 'expected') {
      return 'Expected';
    } else if (msgType.toLowerCase() == 'immediate') {
      return 'Immediate';
    }
    return 'Alert'; // Default for other message types
  }

  // Get a formatted display string for the alert
  String get displayTitle {
    final timing = timingType;
    if (timing == 'Expected' || timing == 'Immediate') {
      return '$timing: $event';
    }
    return event;
  }
} 