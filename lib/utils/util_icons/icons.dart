import 'package:flutter/material.dart';

import 'custom_icons.dart';

IconData typeToIconData(String type) {
  switch (type) {
    case 'amenity:bar':
    case 'amenity:pub':
    case 'amenity:biergarten':
    case 'amenity:nightclub':
      return Icons.local_bar;

    case 'amenity:cafe':
      return Icons.local_cafe;

    case 'amenity:cinema':
      return Icons.local_movies;

    case 'amenity:pharmacy':
      return Icons.local_pharmacy;

    case 'amenity:fast_food':
      return Icons.fastfood;

    case 'amenity:food_court':
    case 'amenity:restaurant':
      return Icons.restaurant;

    case 'amenity:theatre':
      return Icons.local_play;

    case 'amenity:parking':
      return Icons.local_parking;

    case 'amenity:doctors':
    case 'amenity:dentist':
    case 'amenity:veterinary':
    case 'amenity:clinic':
    case 'amenity:hospital':
      return Icons.local_hospital;

    case 'amenity:library':
      return Icons.local_library;

    case 'amenity:car_wash':
      return Icons.local_car_wash;

    case 'amenity:university':
    case 'amenity:school':
    case 'amenity:college':
      return Icons.school;

    case 'amenity:post_office':
      return Icons.local_post_office;

    case 'amenity:atm':
      return Icons.local_atm;

    case 'amenity:convenience':
      return Icons.local_convenience_store;

    case 'amenity:telephone':
      return Icons.local_phone;

    case 'amenity:internet_cafe':
      return Icons.alternate_email;

    case 'amenity:drinking_water':
      return Icons.local_drink;

    case 'amenity:charging_station':
      return Icons.ev_station;

    case 'amenity:fuel':
      return Icons.local_gas_station;

    case 'amenity:taxi':
      return Icons.local_taxi;

    case 'public_transport:platform':
      return CustomIcons.busStop;

    case 'shop:florist':
      return Icons.local_florist;

    case 'shop:convenience':
      return Icons.local_convenience_store;

    case 'shop:supermarket':
      return Icons.local_grocery_store;

    case 'shop:laundry':
      return Icons.local_laundry_service;

    case 'shop:copyshop':
      return Icons.local_printshop;

    case 'shop:mall':
      return Icons.local_mall;

    case 'tourism:hotel':
    case 'tourism:hostel':
    case 'tourism:guest_house':
    case 'tourism:motel':
    case 'tourism:apartment':
      return Icons.local_hotel;

    case 'saved_place:fastfood':
      return Icons.fastfood;

    case 'saved_place:home':
      return Icons.home;

    case 'saved_place:local_cafe':
      return Icons.local_cafe;

    case 'saved_place:map':
      return Icons.map;

    case 'saved_place:work':
      return Icons.work;

    case 'saved_place:school':
      return Icons.school;

    default:
      return null;
  }
}
