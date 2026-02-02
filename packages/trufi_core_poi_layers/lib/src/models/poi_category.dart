import 'package:flutter/material.dart';

/// Categories of POIs matching the GeoJSON files
enum POICategory {
  transport(
    icon: Icons.directions_bus_rounded,
    color: Color(0xFF1976D2),
    weight: '01',
    filename: 'transport',
    minZoom: 14,
  ),
  food(
    icon: Icons.restaurant_rounded,
    color: Color(0xFFE65100),
    weight: '02',
    filename: 'food',
    minZoom: 14,
  ),
  shopping(
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFF7B1FA2),
    weight: '03',
    filename: 'shopping',
    minZoom: 14,
  ),
  healthcare(
    icon: Icons.local_hospital_rounded,
    color: Color(0xFFD32F2F),
    weight: '04',
    filename: 'healthcare',
    minZoom: 14,
  ),
  education(
    icon: Icons.school_rounded,
    color: Color(0xFF1565C0),
    weight: '05',
    filename: 'education',
    minZoom: 14,
  ),
  finance(
    icon: Icons.account_balance_rounded,
    color: Color(0xFF00695C),
    weight: '06',
    filename: 'finance',
    minZoom: 14,
  ),
  tourism(
    icon: Icons.photo_camera_rounded,
    color: Color(0xFFFF6F00),
    weight: '07',
    filename: 'tourism',
    minZoom: 14,
  ),
  recreation(
    icon: Icons.park_rounded,
    color: Color(0xFF388E3C),
    weight: '08',
    filename: 'recreation',
    minZoom: 14,
  ),
  government(
    icon: Icons.account_balance_rounded,
    color: Color(0xFF455A64),
    weight: '09',
    filename: 'government',
    minZoom: 14,
  ),
  religion(
    icon: Icons.church_rounded,
    color: Color(0xFF5D4037),
    weight: '10',
    filename: 'religion',
    minZoom: 14,
  ),
  emergency(
    icon: Icons.emergency_rounded,
    color: Color(0xFFC62828),
    weight: '11',
    filename: 'emergency',
    minZoom: 14,
  ),
  accommodation(
    icon: Icons.hotel_rounded,
    color: Color(0xFF6A1B9A),
    weight: '12',
    filename: 'accommodation',
    minZoom: 14,
  );

  /// Icon to display for this category
  final IconData icon;

  /// Color associated with this category
  final Color color;

  /// Weight for layer ordering (lower = rendered first)
  final String weight;

  /// Filename for the GeoJSON file (without extension)
  final String filename;

  /// Minimum zoom level to show POIs of this category
  final int minZoom;

  const POICategory({
    required this.icon,
    required this.color,
    required this.weight,
    required this.filename,
    this.minZoom = 14,
  });
}

/// Types of POIs within categories
enum POIType {
  // Transport
  busStop(category: POICategory.transport, icon: Icons.directions_bus),
  platform(category: POICategory.transport, icon: Icons.directions_bus),
  stopPosition(category: POICategory.transport, icon: Icons.place),
  station(category: POICategory.transport, icon: Icons.train),
  taxiStand(category: POICategory.transport, icon: Icons.local_taxi),
  parking(category: POICategory.transport, icon: Icons.local_parking),

  // Food & Drink
  restaurant(category: POICategory.food, icon: Icons.restaurant),
  cafe(category: POICategory.food, icon: Icons.local_cafe),
  fastFood(category: POICategory.food, icon: Icons.fastfood),
  bar(category: POICategory.food, icon: Icons.local_bar),
  bakery(category: POICategory.food, icon: Icons.bakery_dining),
  iceCream(category: POICategory.food, icon: Icons.icecream),

  // Shopping
  supermarket(category: POICategory.shopping, icon: Icons.shopping_cart),
  convenience(category: POICategory.shopping, icon: Icons.storefront),
  marketplace(category: POICategory.shopping, icon: Icons.store),
  clothes(category: POICategory.shopping, icon: Icons.checkroom),
  electronics(category: POICategory.shopping, icon: Icons.devices),
  mall(category: POICategory.shopping, icon: Icons.local_mall),
  shop(category: POICategory.shopping, icon: Icons.store),

  // Healthcare
  hospital(category: POICategory.healthcare, icon: Icons.local_hospital),
  clinic(category: POICategory.healthcare, icon: Icons.medical_services),
  pharmacy(category: POICategory.healthcare, icon: Icons.local_pharmacy),
  dentist(category: POICategory.healthcare, icon: Icons.medical_services),
  doctor(category: POICategory.healthcare, icon: Icons.medical_services),

  // Education
  school(category: POICategory.education, icon: Icons.school),
  university(category: POICategory.education, icon: Icons.account_balance),
  college(category: POICategory.education, icon: Icons.school),
  kindergarten(category: POICategory.education, icon: Icons.child_care),
  library(category: POICategory.education, icon: Icons.local_library),

  // Finance
  bank(category: POICategory.finance, icon: Icons.account_balance),
  atm(category: POICategory.finance, icon: Icons.atm),
  exchangePoint(category: POICategory.finance, icon: Icons.currency_exchange),

  // Tourism
  hotel(category: POICategory.tourism, icon: Icons.hotel),
  attraction(category: POICategory.tourism, icon: Icons.attractions),
  viewpoint(category: POICategory.tourism, icon: Icons.landscape),
  museum(category: POICategory.tourism, icon: Icons.museum),
  monument(category: POICategory.tourism, icon: Icons.account_balance),
  artwork(category: POICategory.tourism, icon: Icons.palette),
  information(category: POICategory.tourism, icon: Icons.info),

  // Recreation
  park(category: POICategory.recreation, icon: Icons.park),
  sportsCentre(category: POICategory.recreation, icon: Icons.sports),
  playground(category: POICategory.recreation, icon: Icons.child_care),
  stadium(category: POICategory.recreation, icon: Icons.stadium),
  pitch(category: POICategory.recreation, icon: Icons.sports_soccer),
  cinema(category: POICategory.recreation, icon: Icons.movie),
  theatre(category: POICategory.recreation, icon: Icons.theater_comedy),
  nightclub(category: POICategory.recreation, icon: Icons.nightlife),
  gym(category: POICategory.recreation, icon: Icons.fitness_center),
  swimmingPool(category: POICategory.recreation, icon: Icons.pool),

  // Government
  townhall(category: POICategory.government, icon: Icons.account_balance),
  embassy(category: POICategory.government, icon: Icons.account_balance),
  postOffice(category: POICategory.government, icon: Icons.local_post_office),
  courthouse(category: POICategory.government, icon: Icons.gavel),
  publicBuilding(category: POICategory.government, icon: Icons.business),

  // Religion
  placeOfWorship(category: POICategory.religion, icon: Icons.church),
  church(category: POICategory.religion, icon: Icons.church),
  mosque(category: POICategory.religion, icon: Icons.mosque),
  synagogue(category: POICategory.religion, icon: Icons.synagogue),

  // Emergency
  police(category: POICategory.emergency, icon: Icons.local_police),
  fireStation(category: POICategory.emergency, icon: Icons.local_fire_department),
  ambulanceStation(category: POICategory.emergency, icon: Icons.emergency),

  // Accommodation
  hostel(category: POICategory.accommodation, icon: Icons.hotel),
  guestHouse(category: POICategory.accommodation, icon: Icons.house),
  motel(category: POICategory.accommodation, icon: Icons.hotel),
  apartment(category: POICategory.accommodation, icon: Icons.apartment),

  // Fallback
  unknown(category: POICategory.shopping, icon: Icons.place);

  final POICategory category;
  final IconData icon;

  const POIType({
    required this.category,
    required this.icon,
  });

  /// Get POIType from OSM type string
  static POIType fromString(String? typeStr) {
    if (typeStr == null) return POIType.unknown;

    // Map OSM values to POIType
    switch (typeStr.toLowerCase()) {
      // Transport
      case 'bus_stop':
        return POIType.busStop;
      case 'platform':
        return POIType.platform;
      case 'stop_position':
        return POIType.stopPosition;
      case 'station':
        return POIType.station;
      case 'taxi':
      case 'taxi_stand':
        return POIType.taxiStand;
      case 'parking':
        return POIType.parking;

      // Food
      case 'restaurant':
        return POIType.restaurant;
      case 'cafe':
        return POIType.cafe;
      case 'fast_food':
        return POIType.fastFood;
      case 'bar':
      case 'pub':
        return POIType.bar;
      case 'bakery':
        return POIType.bakery;
      case 'ice_cream':
        return POIType.iceCream;

      // Shopping
      case 'supermarket':
        return POIType.supermarket;
      case 'convenience':
        return POIType.convenience;
      case 'marketplace':
        return POIType.marketplace;
      case 'clothes':
        return POIType.clothes;
      case 'electronics':
        return POIType.electronics;
      case 'mall':
        return POIType.mall;
      case 'shop':
        return POIType.shop;

      // Healthcare
      case 'hospital':
        return POIType.hospital;
      case 'clinic':
        return POIType.clinic;
      case 'pharmacy':
        return POIType.pharmacy;
      case 'dentist':
        return POIType.dentist;
      case 'doctor':
      case 'doctors':
        return POIType.doctor;

      // Education
      case 'school':
        return POIType.school;
      case 'university':
        return POIType.university;
      case 'college':
        return POIType.college;
      case 'kindergarten':
        return POIType.kindergarten;
      case 'library':
        return POIType.library;

      // Finance
      case 'bank':
        return POIType.bank;
      case 'atm':
        return POIType.atm;
      case 'bureau_de_change':
      case 'exchange':
        return POIType.exchangePoint;

      // Tourism
      case 'hotel':
        return POIType.hotel;
      case 'attraction':
        return POIType.attraction;
      case 'viewpoint':
        return POIType.viewpoint;
      case 'museum':
        return POIType.museum;
      case 'monument':
      case 'memorial':
        return POIType.monument;
      case 'artwork':
        return POIType.artwork;
      case 'information':
        return POIType.information;

      // Recreation
      case 'park':
        return POIType.park;
      case 'sports_centre':
        return POIType.sportsCentre;
      case 'playground':
        return POIType.playground;
      case 'stadium':
        return POIType.stadium;
      case 'pitch':
        return POIType.pitch;
      case 'cinema':
        return POIType.cinema;
      case 'theatre':
        return POIType.theatre;
      case 'nightclub':
        return POIType.nightclub;
      case 'gym':
      case 'fitness_centre':
        return POIType.gym;
      case 'swimming_pool':
        return POIType.swimmingPool;

      // Government
      case 'townhall':
        return POIType.townhall;
      case 'embassy':
        return POIType.embassy;
      case 'post_office':
        return POIType.postOffice;
      case 'courthouse':
        return POIType.courthouse;
      case 'public_building':
        return POIType.publicBuilding;

      // Religion
      case 'place_of_worship':
        return POIType.placeOfWorship;
      case 'church':
        return POIType.church;
      case 'mosque':
        return POIType.mosque;
      case 'synagogue':
        return POIType.synagogue;

      // Emergency
      case 'police':
        return POIType.police;
      case 'fire_station':
        return POIType.fireStation;
      case 'ambulance_station':
        return POIType.ambulanceStation;

      // Accommodation
      case 'hostel':
        return POIType.hostel;
      case 'guest_house':
        return POIType.guestHouse;
      case 'motel':
        return POIType.motel;
      case 'apartment':
        return POIType.apartment;

      default:
        return POIType.unknown;
    }
  }
}
