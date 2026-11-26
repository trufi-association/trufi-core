import 'dart:io';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;

/// The planner could not be reached (no connection).
///
/// Timeouts, TLS failures and any answer from the server, even an error
/// status, are not this exception.
class RoutingNetworkException implements Exception {
  RoutingNetworkException(this.message);

  final String message;

  @override
  String toString() => 'RoutingNetworkException: $message';
}

/// Whether [error], the cause of a failed request, means there is no
/// connection: a [SocketException] or an [http.ClientException].
bool isConnectivityFailure(Object? error) =>
    error is SocketException || error is http.ClientException;

/// Whether a GraphQL [link] failure means there is no connection.
bool isLinkConnectivityFailure(LinkException link) =>
    isConnectivityFailure(link.originalException);
