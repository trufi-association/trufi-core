import 'package:graphql/client.dart';

GraphQLClient getClient(String endpoint) {
  final HttpLink _httpLink = HttpLink(endpoint);
  return GraphQLClient(
    cache: GraphQLCache(
      store: HiveStore(),
      partialDataPolicy: PartialDataCachePolicy.accept,
    ),
    link: _httpLink,
  );
}
