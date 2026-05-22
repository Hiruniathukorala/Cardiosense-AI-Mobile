class Hospital {
  final String name;
  final String address;
  final String phone;

  Hospital({required this.name, required this.address, required this.phone});
}

class SriLankaRegions {
  static final Map<String, List<Hospital>> locationCenters = {
    'Colombo': [
      Hospital(name: 'Asiri Central Hospital', address: 'No. 340, Union Place, Colombo 2', phone: '+94 11 545 0000'),
      Hospital(name: 'Lanka Hospitals', address: '5, Sir Suleman Street, Colombo 2', phone: '+94 11 754 0202'),
      Hospital(name: 'Durdans Hospital', address: '2, Alfred House Gardens, Colombo 3', phone: '+94 11 268 8989'),
    ],
    'Kandy': [
      Hospital(name: 'Kandy National Hospital', address: 'Gannoruwa, Kandy', phone: '+94 81 222 6020'),
      Hospital(name: 'Durdans Hospital Kandy', address: '2/1, Gannoruwa Road, Kandy', phone: '+94 81 222 8989'),
      Hospital(name: 'Teaching Hospital Kandy', address: 'Gannoruwa, Kandy', phone: '+94 81 247 9000'),
    ],
    'Galle': [
      Hospital(name: 'Southern Hospital', address: '342, Galle Road, Galle', phone: '+94 91 223 4545'),
      Hospital(name: 'Galle General Hospital', address: 'Galle', phone: '+94 91 223 1660'),
      Hospital(name: 'Karapitiya Teaching Hospital', address: 'Karapitiya, Galle', phone: '+94 91 222 2084'),
    ],
    'Jaffna': [
      Hospital(name: 'Jaffna Teaching Hospital', address: 'K.K.S Road, Jaffna', phone: '+94 21 222 1511'),
      Hospital(name: 'Acute Care Hospital Jaffna', address: 'Jaffna', phone: '+94 21 224 0095'),
    ],
    'Trincomalee': [
      Hospital(name: 'Trincomalee Hospital', address: 'Trincomalee', phone: '+94 26 222 2222'),
      Hospital(name: 'Padaviya Hospital', address: 'Padaviya, Trincomalee', phone: '+94 26 226 3145'),
    ],
  };

  static final Map<String, Map<String, List<String>>> regions = {
    'Western': {
      'Colombo': ['Colombo', 'Dehiwala-Mount Lavinia', 'Moratuwa', 'Negombo'],
      'Gampaha': ['Gampaha', 'Wattala', 'Ja-Ela', 'Negombo'],
      'Kalutara': ['Kalutara', 'Panadura', 'Horana', 'Mathugama'],
    },
    'Central': {
      'Kandy': ['Kandy', 'Peradeniya', 'Nawalapitiya', 'Gampola'],
      'Matale': ['Matale', 'Dambulla', 'Rattota', 'Naula'],
      'Nuwara Eliya': ['Nuwara Eliya', 'Hatton', 'Nanuoya', 'Kotagala'],
    },
    'Southern': {
      'Galle': ['Galle', 'Hikkaduwa', 'Ambalangoda', 'Bentota'],
      'Matara': ['Matara', 'Weligama', 'Deniyaya', 'Dickwella'],
      'Hambantota': ['Hambantota', 'Tangalle', 'Tissamaharama', 'Beliatta'],
    },
    'Northern': {
      'Jaffna': ['Jaffna', 'Point Pedro', 'Chavakachcheri', 'Karainagar'],
      'Kilinochchi': ['Kilinochchi', 'Poonakary', 'Paranthan', 'Pachchilaipalli'],
      'Mannar': ['Mannar', 'Madhu', 'Vankalai', 'Erukkalampiddy'],
      'Mullaitivu': ['Mullaitivu', 'Puthukkudiyiruppu', 'Oddusuddan', 'Mankulam'],
      'Vavuniya': ['Vavuniya', 'Venkalacheddikulam', 'Omanthai', 'Mannar'],
    },
    'Eastern': {
      'Trincomalee': ['Trincomalee', 'Nilaveli', 'Kinniya', 'Muttur'],
      'Batticaloa': ['Batticaloa', 'Eravur', 'Kaluwanchikudy', 'Valaichchenai'],
      'Ampara': ['Ampara', 'Kalmunai', 'Mahaoya', 'Akkaraipattu'],
    },
    'North Western': {
      'Kurunegala': ['Kurunegala', 'Kuliyapitiya', 'Nikaweratiya', 'Maho'],
      'Puttalam': ['Puttalam', 'Chilaw', 'Wennappuwa', 'Kalpitiya'],
    },
    'North Central': {
      'Anuradhapura': ['Anuradhapura', 'Mihintale', 'Kekirawa', 'Galenbindunuwewa'],
      'Polonnaruwa': ['Polonnaruwa', 'Habarana', 'Minneriya', 'Medirigiriya'],
    },
    'Uva': {
      'Badulla': ['Badulla', 'Bandarawela', 'Hali-ela', 'Passara'],
      'Monaragala': ['Monaragala', 'Wellawaya', 'Bibile', 'Kataragama'],
    },
    'Sabaragamuwa': {
      'Kegalle': ['Kegalle', 'Mawanella', 'Aranayake', 'Rambukkana'],
      'Ratnapura': ['Ratnapura', 'Balangoda', 'Pelmadulla', 'Embilipitiya'],
    },
  };
}
