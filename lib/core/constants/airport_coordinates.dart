class AirportCoordinates {
  static const Map<String, Map<String, double>> data = {
    // Kerala
    'VOCL': {'lat': 11.1374, 'lng': 75.9556}, // Calicut
    'CCJ': {'lat': 11.1374, 'lng': 75.9556},
    'VOCI': {'lat': 10.1518, 'lng': 76.3930}, // Cochin
    'COK': {'lat': 10.1518, 'lng': 76.3930},
    'VOTV': {'lat': 8.4821, 'lng': 76.9200}, // Trivandrum
    'TRV': {'lat': 8.4821, 'lng': 76.9200},
    'VOKN': {'lat': 11.9167, 'lng': 75.5500}, // Kannur
    'CNN': {'lat': 11.9167, 'lng': 75.5500},

    // Major India
    'BOM': {'lat': 19.0896, 'lng': 72.8656}, // Mumbai
    'DEL': {'lat': 28.5562, 'lng': 77.1000}, // Delhi
    'MAA': {'lat': 12.9941, 'lng': 80.1709}, // Chennai
    'BLR': {'lat': 13.1986, 'lng': 77.7066}, // Bangalore
    'HYD': {'lat': 17.2403, 'lng': 78.4294}, // Hyderabad
    'CCU': {'lat': 22.6548, 'lng': 88.4467}, // Kolkata
    'AMD': {'lat': 23.0738, 'lng': 72.6347}, // Ahmedabad
    'GOI': {'lat': 15.3800, 'lng': 73.8314}, // Goa
    'PNQ': {'lat': 18.5821, 'lng': 73.9197}, // Pune

    // Middle East (Common destinations from Kerala)
    'DXB': {'lat': 25.2532, 'lng': 55.3657}, // Dubai
    'SHJ': {'lat': 25.3286, 'lng': 55.5172}, // Sharjah
    'AUH': {'lat': 24.4442, 'lng': 54.6511}, // Abu Dhabi
    'DOH': {'lat': 25.2609, 'lng': 51.6138}, // Doha
    'BAH': {'lat': 26.2708, 'lng': 50.6336}, // Bahrain
    'KWI': {'lat': 29.2266, 'lng': 47.9689}, // Kuwait
    'MCT': {'lat': 23.5933, 'lng': 58.2818}, // Muscat
    'RUH': {'lat': 24.9576, 'lng': 46.6988}, // Riyadh
    'JED': {'lat': 21.6858, 'lng': 39.1725}, // Jeddah
    'DMM': {'lat': 26.4712, 'lng': 49.7979}, // Dammam
    'SLL': {'lat': 17.0396, 'lng': 54.1030}, // Salalah

    // Other International
    'SIN': {'lat': 1.3644, 'lng': 103.9915}, // Singapore
    'KUL': {'lat': 2.7456, 'lng': 101.7072}, // Kuala Lumpur
    'LHR': {'lat': 51.4700, 'lng': -0.4543}, // London Heathrow
    'JFK': {'lat': 40.6413, 'lng': -73.7781}, // New York
    'FRA': {'lat': 50.0379, 'lng': 8.5622}, // Frankfurt
    'CDG': {'lat': 49.0097, 'lng': 2.5479}, // Paris
    'BKK': {'lat': 13.6900, 'lng': 100.7501}, // Bangkok
    'CMB': {'lat': 7.1808, 'lng': 79.8841}, // Colombo
    'MLE': {'lat': 4.1918, 'lng': 73.5291}, // Male
  };

  static Map<String, double>? getCoordinates(String iata) {
    if (data.containsKey(iata)) {
      return data[iata];
    }
    // Fallback? or return null
    return null;
  }
}
