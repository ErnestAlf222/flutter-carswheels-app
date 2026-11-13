import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Provee el traductor de clases que la app inyecta desde AppDependencies.
Widget withClassTranslator(
  Widget child, {
  VehicleClassTranslator translator = const VehicleClassTranslator(),
}) => RepositoryProvider<VehicleClassTranslator>.value(
  value: translator,
  child: child,
);
