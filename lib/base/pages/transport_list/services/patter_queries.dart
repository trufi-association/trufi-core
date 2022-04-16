const String allPatterns = r'''
 {
  patterns{
    id
    name
    code
    route{
      longName
      shortName
      color
      mode
    }
  }
}
''';

const String dataPattern = r'''
 query parking(
   $id: String!
 ) {
  pattern(
    id:$id
  ){
    geometry{
      lat
      lon
    }
    stops{
      name
      lat
      lon
    }
  }
}
''';
