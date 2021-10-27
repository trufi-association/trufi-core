import 'package:graphql/client.dart';

final serviceTimeRangeFragment = gql('''
fragment serviceTimeRangeFragment on serviceTimeRange {
  start
  end
}
''');
