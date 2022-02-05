import 'package:graphql/client.dart';

GraphQLClient getClient(String endpoint) {
  final HttpLink _httpLink = HttpLink(endpoint);
  return GraphQLClient(
    cache: GraphQLCache(
      partialDataPolicy: PartialDataCachePolicy.accept,
    ),
    link: _httpLink,
  );
}
