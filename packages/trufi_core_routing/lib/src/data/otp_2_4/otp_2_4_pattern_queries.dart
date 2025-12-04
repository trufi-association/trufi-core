/// GraphQL query to fetch all transit patterns.
const String allPatterns = r'''
{
  patterns {
    id
    name
    code
    route {
      longName
      shortName
      color
      mode
      textColor
    }
  }
}
''';

/// GraphQL query to fetch a single pattern with geometry and stops.
const String patternById = r'''
query pattern($id: String!) {
  pattern(id: $id) {
    geometry {
      lat
      lon
    }
    stops {
      name
      lat
      lon
    }
  }
}
''';
