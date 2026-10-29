import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_home_screen/src/services/coordinate_address.dart';
import 'package:trufi_core_search_locations/trufi_core_search_locations.dart';
import 'in_memory_storage.dart';

/// #1023: a "Go to lat, lon" row chosen before its reverse geocode answered
/// pops without an address; Home resolves it afterwards.

class _FakeSearchService implements SearchLocationService {
  _FakeSearchService(this.onReverse);
  final Future<SearchLocation?> Function(double lat, double lng) onReverse;
  int reverseCalls = 0;

  @override
  Future<List<SearchLocation>> search(String query) async => const [];

  @override
  Future<SearchLocation?> reverse(double latitude, double longitude) {
    reverseCalls++;
    return onReverse(latitude, longitude);
  }

  @override
  void dispose() {}
}

SearchLocationsCubit _cubit(_FakeSearchService service) => SearchLocationsCubit(
  searchLocationService: service,
  localRepository: SearchLocationsRepositoryImpl(storage: InMemoryStorage()),
);

const _pair = SearchLocation(
  id: 'coordinates:-17.3937,-66.1568',
  displayName: '-17.3937, -66.1568',
  latitude: -17.3937,
  longitude: -66.1568,
);

void main() {
  group('isBareCoordinateLocation', () {
    test('a coordinates row without address is bare', () {
      expect(isBareCoordinateLocation(_pair), isTrue);
    });

    test('with an address, or any other row, it is not', () {
      const resolved = SearchLocation(
        id: 'coordinates:-17.3937,-66.1568',
        displayName: '-17.3937, -66.1568',
        address: 'Cochabamba',
        latitude: -17.3937,
        longitude: -66.1568,
      );
      const street = SearchLocation(
        id: 's1',
        displayName: 'Avenida Heroínas',
        latitude: -17.39,
        longitude: -66.16,
      );
      expect(isBareCoordinateLocation(resolved), isFalse);
      expect(isBareCoordinateLocation(street), isFalse);
    });
  });

  group('resolveCoordinateAddress', () {
    test('returns the reverse result\'s formattedDisplay: name and address, '
        'or whichever it has', () async {
      final withAddress = _FakeSearchService(
        (lat, lng) async => const SearchLocation(
          id: 'r',
          displayName: 'Plaza 14 de Septiembre',
          address: 'Cochabamba, Bolivia',
          latitude: -17.3937,
          longitude: -66.1568,
        ),
      );
      expect(
        await resolveCoordinateAddress(_cubit(withAddress), -17.3937, -66.1568),
        'Plaza 14 de Septiembre, Cochabamba, Bolivia',
      );
      final nameOnly = _FakeSearchService(
        (lat, lng) async => const SearchLocation(
          id: 'r',
          displayName: 'Plaza 14 de Septiembre',
          latitude: -17.3937,
          longitude: -66.1568,
        ),
      );
      expect(
        await resolveCoordinateAddress(_cubit(nameOnly), -17.3937, -66.1568),
        'Plaza 14 de Septiembre',
      );
    });

    test(
      'null, blank, a throwing geocoder or a timeout leave the pair bare',
      () async {
        expect(
          await resolveCoordinateAddress(
            _cubit(_FakeSearchService((_, _) async => null)),
            -17.39,
            -66.16,
          ),
          isNull,
        );
        expect(
          await resolveCoordinateAddress(
            _cubit(
              _FakeSearchService(
                (_, _) async => const SearchLocation(
                  id: 'r',
                  displayName: '   ',
                  latitude: 0,
                  longitude: 0,
                ),
              ),
            ),
            -17.39,
            -66.16,
          ),
          isNull,
        );
        expect(
          await resolveCoordinateAddress(
            _cubit(_FakeSearchService((_, _) => throw StateError('down'))),
            -17.39,
            -66.16,
          ),
          isNull,
        );
        final never = _FakeSearchService(
          (_, _) => Completer<SearchLocation?>().future,
        );
        expect(
          await resolveCoordinateAddress(
            _cubit(never),
            -17.39,
            -66.16,
            timeout: const Duration(milliseconds: 50),
          ),
          isNull,
        );
        expect(never.reverseCalls, 1);
      },
    );
  });
}
