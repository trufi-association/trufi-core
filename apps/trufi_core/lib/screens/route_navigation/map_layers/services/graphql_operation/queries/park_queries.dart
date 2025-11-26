const String parking = r'''
 query parking(
   $parkId: String!
 ){
  vehicleParking(id: $parkId) {
    vehicleParkingId
    name
    lon
    lat
    capacity {
      carSpaces
      bicycleSpaces
      wheelchairAccessibleCarSpaces
    }
    availability {
      carSpaces
      bicycleSpaces
      wheelchairAccessibleCarSpaces
    }
    imageUrl
    tags
    anyCarPlaces
    detailsUrl
    note
    openingHours{
      osm
    }
  }
}
''';
