import 'package:flutter/material.dart';

import 'custom_icons.dart' as custom_icon;

Widget typeToIconData(
  String? type, {
  Color? color,
  double? size,
}) {
  Widget? icon;
  IconData? iconData;
  switch (type ?? '') {
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
      iconData = Icons.local_play;
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

    case 'public_transport:platform':
      icon = custom_icon.busStopIcon(color: color);
      break;

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

    case 'tourism:hotel':
    case 'tourism:hostel':
    case 'tourism:guest_house':
    case 'tourism:motel':
    case 'tourism:apartment':
      iconData = Icons.local_hotel;
      break;

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

    default:
      iconData = Icons.place;
  }
  return iconData != null
      ? Icon(iconData, color: color)
      : SizedBox(
          width: 24,
          height: 24,
          child: icon!,
        );
}
