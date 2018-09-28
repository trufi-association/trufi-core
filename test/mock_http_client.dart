import 'dart:async' show Future, Stream;
import 'dart:io'
    show
        HttpClient,
        HttpClientRequest,
        HttpClientResponse,
        HttpHeaders,
        HttpOverrides,
        HttpStatus,
        SecurityContext;

import 'package:mockito/mockito.dart'
    show Mock, any, anyNamed, captureAny, throwOnMissingStub, when;

const String dummyAvatarImagePath = '/avatar.jpg';

class TestHttpOverrides extends HttpOverrides {
  TestHttpOverrides(this.data);

  final Map<Uri, List<int>> data;

  @override
  HttpClient createHttpClient(SecurityContext context) =>
      createMockImageHttpClient(context, data);
}

// Returns a mock HTTP client that responds with an image to all requests.
MockHttpClient createMockImageHttpClient(
    SecurityContext _, Map<Uri, List<int>> data) {
  final client = new MockHttpClient();
  final request = new MockHttpClientRequest();
  final response = new MockHttpClientResponse(data);
  final headers = new MockHttpHeaders();

  throwOnMissingStub(client);
  throwOnMissingStub(request);
  throwOnMissingStub(response);
  throwOnMissingStub(headers);

  when<dynamic>(client.getUrl(captureAny)).thenAnswer((invocation) {
    response.requestedUrl = invocation.positionalArguments[0] as Uri;
    return new Future<HttpClientRequest>.value(request);
  });

  when(request.headers).thenAnswer((_) => headers);

  when(request.close())
      .thenAnswer((_) => new Future<HttpClientResponse>.value(response));

  when(response.contentLength)
      .thenAnswer((_) => data[response.requestedUrl].length);

  when(response.statusCode).thenReturn(HttpStatus.ok);

  when(
    response.listen(
      any,
      cancelOnError: anyNamed('cancelOnError'),
      onDone: anyNamed('onDone'),
      onError: anyNamed('onError'),
    ),
  ).thenAnswer((invocation) {
    final onData =
        invocation.positionalArguments[0] as void Function(List<int>);

    final onDone = invocation.namedArguments[#onDone] as void Function();

    final onError = invocation.namedArguments[#onError] as void Function(Object,
        [StackTrace]);

    final cancelOnError = invocation.namedArguments[#cancelOnError] as bool;

    return new Stream<List<int>>.fromIterable([data[response.requestedUrl]])
        .listen(onData,
            onDone: onDone, onError: onError, cancelOnError: cancelOnError);
  });
  return client;
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {
  MockHttpClientResponse(this.data);

  final Map<Uri, List<int>> data;
  Uri requestedUrl;

  @override
  Future<S> fold<S>(S initialValue, S combine(S previous, List<int> element)) =>
      new Stream.fromIterable([data[requestedUrl]]).fold(initialValue, combine);
}

class MockHttpHeaders extends Mock implements HttpHeaders {}
