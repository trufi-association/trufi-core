import '../lib/RoutingManager/RoutingManager.dart';

void main() {
  RoutingManager routingManager = new RoutingManager();
  
  print("test 1");
  print(routingManager.find_routes(
      -17.448907, -66.117019, -17.437882, -66.116468));

  print("test 2 : from sam house to luz house");
  print(routingManager.find_routes(
      -17.380628, -66.148590, -17.448750, -66.116171));

  print("test 3 : from luz house to luz sam");
  print(routingManager.find_routes(
      -17.448750, -66.116171, -17.380628, -66.148590));

  print("test 4 : from quillacollo to pacata");
  print(routingManager.find_routes(
      -17.391259, -66.277824, -17.369473, -66.130329));
}
