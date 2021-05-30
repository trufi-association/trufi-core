import 'package:graphql/client.dart';

GraphQLClient getClient() {
  final HttpLink _httpLink = HttpLink(
    'https://api.dev.stadtnavi.eu/routing/v1/router/index/graphql',
  );
  return GraphQLClient(
    cache: GraphQLCache(
      store: HiveStore(),
    ),
    link: _httpLink,
  );
}
