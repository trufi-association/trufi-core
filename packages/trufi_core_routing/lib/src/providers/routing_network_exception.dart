import 'dart:async';
import 'dart:io';

import 'package:graphql/client.dart';
import 'package:http/http.dart' as http;

/// The planner could not be reached (no connection, timeout, TLS failure).
///
/// An answer from the server, even an error status, is not this exception.
class RoutingNetworkException implements Exception {
  RoutingNetworkException(this.message);

  final String message;

  @override
  String toString() => 'RoutingNetworkException: $message';
}

/// Whether [error], the cause of a failed request, means the server was not
/// reached.
bool isConnectivityFailure(Object? error) =>
    error is SocketException ||
    error is http.ClientException ||
    error is TimeoutException ||
    error is HandshakeException;

/// Whether a GraphQL [link] failure means the server was not reached.
///
/// A [ServerException] that carries a response or a status code is an HTTP
/// answer (4xx/5xx), not a connectivity failure.
bool isLinkConnectivityFailure(LinkException link) {
  if (isConnectivityFailure(link.originalException)) return true;
  return link is ServerException &&
      link.parsedResponse == null &&
      link.statusCode == null;
}
