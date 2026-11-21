import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/mappers/vehicle_record_mapper.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/fuel_economy_vehicle_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Campos tal como los devuelve FuelEconomy (un Tesla Model 3 RWD 2023 real).
const Map<String, dynamic> _electricJson = {
  'atvType': 'EV',
  'comb08': '132',
  'pv2': '0',
  'pv4': '97',
  'hpv': '0',
  'lv2': '0',
  'lv4': '15',
  'hlv': '0',
  'charge240': '10.4',
  'charge120': '0.0',
  'startStop': 'N',
};

void main() {
  test('el registro lee volúmenes, carga y arranque-parada reales', () {
    final record = VehicleRecordMapper.toEntity(
      FuelEconomyVehicleModel.fromJson(_electricJson),
    );
    expect(record.passengerVolumeCubicFeet, 97);
    expect(record.cargoVolumeCubicFeet, 15);
    expect(record.chargeHours240, 10.4);
    expect(record.chargeHours120, isNull);
    expect(record.hasStartStop, isFalse);
  });

  test('ceros y campos ausentes quedan nulos, no 0', () {
    final record = VehicleRecordMapper.toEntity(
      FuelEconomyVehicleModel.fromJson(const {
        'atvType': '',
        'pv2': '0',
        'pv4': '0',
        'hpv': '0',
        'startStop': '',
      }),
    );
    expect(record.passengerVolumeCubicFeet, isNull);
    expect(record.cargoVolumeCubicFeet, isNull);
    expect(record.hasStartStop, isNull);
  });

  test('el detalle pasa a litros y la carga solo aplica a eléctricos', () {
    const builder = VehicleDetailBuilder();
    final electric = builder.build(
      VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson(_electricJson),
      ),
      1,
      2023,
      'Tesla',
      'Model 3',
    );
    expect(electric.passengerVolumeLiters, closeTo(2746.8, 0.5));
    expect(electric.chargeHours240, 10.4);
    final gasoline = builder.build(
      VehicleRecordMapper.toEntity(
        FuelEconomyVehicleModel.fromJson(const {
          'atvType': '',
          'charge240': '5.0',
        }),
      ),
      2,
      2023,
      'Toyota',
      'Camry',
    );
    expect(gasoline.chargeHours240, isNull);
  });
}
