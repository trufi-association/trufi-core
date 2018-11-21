import '../lib/routing/routing_manager.dart';

void main() {
  RoutingManager routingManager = RoutingManager();
  routingManager.loadForTest();

  print("test 1");
  print(
    routingManager.findRoutes(
      -17.448907,
      -66.117019,
      -17.437882,
      -66.116468,
      20,
    ),
  );

  print("test 2 : from sam house to luz house");
  print(
    routingManager.findRoutes(
      -17.380628,
      -66.148590,
      -17.448750,
      -66.116171,
      20,
    ),
  );

  print("test 3 : from luz house to luz sam");
  print(
    routingManager.findRoutes(
      -17.448750,
      -66.116171,
      -17.380628,
      -66.148590,
      20,
    ),
  );

  print("test 4 : from quillacollo to pacata");
  print(
    routingManager.findRoutes(
      -17.391259,
      -66.277824,
      -17.369473,
      -66.130329,
      20,
    ),
  );
}
