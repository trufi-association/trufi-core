import 'package:graphql/client.dart';
import 'package:trufi_core/base/utils/trufi_app_id.dart';

GraphQLClient getClient(String endpoint) {
  final uniqueId = TrufiAppId.getUniqueId;
  final HttpLink httpLink = HttpLink(
    endpoint,
    defaultHeaders: {
      "User-Agent": "Trufi/GraphQL/$uniqueId",
    },
  );
  return GraphQLClient(
    cache: GraphQLCache(
      store: HiveStore(),
      partialDataPolicy: PartialDataCachePolicy.accept,
    ),
    link: httpLink,
  );
}
