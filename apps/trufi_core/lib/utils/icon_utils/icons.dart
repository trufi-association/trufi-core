import 'package:flutter/material.dart';
import 'package:trufi_core/screens/route_navigation/maps/trufi_map_controller.dart';

Widget typeToIconData(dynamic type, {Color? color, double? size}) {
  // Handle both TrufiLocationType enum and String
  final String? typeString = type is TrufiLocationType ? type.value : (type as String?);
  final t = (typeString ?? '').toLowerCase();
  IconData iconData;

  switch (t) {
    // ---------------- AMENITY ----------------
    case 'amenity:bar':
    case 'amenity:pub':
    case 'amenity:biergarten':
    case 'amenity:nightclub':
      iconData = Icons.local_bar;
      break;
    case 'amenity:cafe':
      iconData = Icons.local_cafe;
      break;
    case 'amenity:cinema':
      iconData = Icons.local_movies;
      break;
    case 'amenity:pharmacy':
      iconData = Icons.local_pharmacy;
      break;
    case 'amenity:fast_food':
      iconData = Icons.fastfood;
      break;
    case 'amenity:food_court':
    case 'amenity:restaurant':
      iconData = Icons.restaurant;
      break;
    case 'amenity:theatre':
      iconData = Icons.theaters;
      break;
    case 'amenity:parking':
      iconData = Icons.local_parking;
      break;
    case 'amenity:doctors':
    case 'amenity:dentist':
    case 'amenity:veterinary':
    case 'amenity:clinic':
    case 'amenity:hospital':
      iconData = Icons.local_hospital;
      break;
    case 'amenity:library':
      iconData = Icons.local_library;
      break;
    case 'amenity:car_wash':
      iconData = Icons.local_car_wash;
      break;
    case 'amenity:university':
    case 'amenity:school':
    case 'amenity:college':
      iconData = Icons.school;
      break;
    case 'amenity:post_office':
      iconData = Icons.local_post_office;
      break;
    case 'amenity:atm':
      iconData = Icons.local_atm;
      break;
    case 'amenity:convenience':
      iconData = Icons.local_convenience_store;
      break;
    case 'amenity:telephone':
      iconData = Icons.local_phone;
      break;
    case 'amenity:internet_cafe':
      iconData = Icons.alternate_email;
      break;
    case 'amenity:drinking_water':
      iconData = Icons.local_drink;
      break;
    case 'amenity:charging_station':
      iconData = Icons.ev_station;
      break;
    case 'amenity:fuel':
      iconData = Icons.local_gas_station;
      break;
    case 'amenity:taxi':
      iconData = Icons.local_taxi;
      break;

    // ---------------- SHOP ----------------
    case 'shop:florist':
      iconData = Icons.local_florist;
      break;
    case 'shop:convenience':
      iconData = Icons.local_convenience_store;
      break;
    case 'shop:supermarket':
      iconData = Icons.local_grocery_store;
      break;
    case 'shop:laundry':
      iconData = Icons.local_laundry_service;
      break;
    case 'shop:copyshop':
      iconData = Icons.local_printshop;
      break;
    case 'shop:mall':
      iconData = Icons.local_mall;
      break;

    // ---------------- TOURISM ----------------
    case 'tourism:hotel':
    case 'tourism:hostel':
    case 'tourism:guest_house':
    case 'tourism:motel':
      iconData = Icons.local_hotel;
      break;
    case 'tourism:apartment':
      iconData = Icons.apartment;
      break;
    case 'tourism:museum':
      iconData = Icons.museum;
      break;
    case 'tourism:gallery':
      iconData = Icons.photo_library;
      break;

    // ---------------- HIGHWAY ----------------
    case 'highway:footway':
    case 'highway:pedestrian':
      iconData = Icons.directions_walk;
      break;
    case 'highway:cycleway':
      iconData = Icons.pedal_bike;
      break;
    case 'highway:residential':
    case 'highway:primary':
    case 'highway:secondary':
    case 'highway:tertiary':
    case 'highway:unclassified':
    case 'highway:road':
      iconData = Icons.alt_route;
      break;

    // ---------------- PLACE ----------------
    case 'place:country':
      iconData = Icons.public;
      break;
    case 'place:state':
    case 'place:region':
    case 'place:province':
    case 'place:department':
    case 'place:county':
    case 'place:district':
      iconData = Icons.map;
      break;
    case 'place:city':
    case 'place:town':
      iconData = Icons.location_city;
      break;
    case 'place:village':
    case 'place:hamlet':
      iconData = Icons.holiday_village;
      break;
    case 'place:suburb':
    case 'place:neighbourhood':
      iconData = Icons.apartment;
      break;
    case 'place:locality':
      iconData = Icons.place;
      break;

    // ---------------- NATURAL / WATERWAY / RAILWAY ----------------
    case 'natural:peak':
      iconData = Icons.terrain;
      break;
    case 'natural:water':
    case 'natural:lake':
      iconData = Icons.water;
      break;
    case 'waterway:stream':
    case 'waterway:river':
      iconData = Icons.water;
      break;
    case 'railway:station':
      iconData = Icons.train;
      break;

    // ---------------- SAVED PLACES ----------------
    case 'saved_place:fastfood':
      iconData = Icons.fastfood;
      break;
    case 'saved_place:home':
      iconData = Icons.home;
      break;
    case 'saved_place:local_cafe':
      iconData = Icons.local_cafe;
      break;
    case 'saved_place:map':
      iconData = Icons.map;
      break;
    case 'saved_place:work':
      iconData = Icons.work;
      break;
    case 'saved_place:school':
      iconData = Icons.school;
      break;

    // ---------------- DEFAULT ----------------
    default:
      iconData = Icons.place;
  }

  return Icon(iconData, color: color, size: size);
}