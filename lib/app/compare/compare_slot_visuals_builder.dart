import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Foto y logo de los espacios del comparador, con los widgets de otros features.
const CompareSlotVisuals marketCompareSlotVisuals = CompareSlotVisuals(
  photoBuilder: _buildPhoto,
  logoBuilder: _buildLogo,
);

Widget _buildPhoto(BuildContext context, CompareSlotEntity slot) =>
    _CompareSlotPhoto(slot: slot);

Widget _buildLogo(BuildContext context, CompareSlotEntity slot, double size) =>
    BrandLogoWidget(brandName: slot.brand, size: size);

/// Foto del vehículo: al mostrarse pide su imagen y se queda con la de la caché.
class _CompareSlotPhoto extends StatefulWidget {
  const _CompareSlotPhoto({required this.slot});

  final CompareSlotEntity slot;

  @override
  State<_CompareSlotPhoto> createState() => _CompareSlotPhotoState();
}

class _CompareSlotPhotoState extends State<_CompareSlotPhoto> {
  @override
  void initState() {
    super.initState();
    // Los cubits cambian de estado después de construir, no durante.
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPhoto());
  }

  void _requestPhoto() {
    if (!mounted) return;
    final photos = context.read<PhotosCubit>();
    if (photos.isClosed) return;
    final slot = widget.slot;
    photos.requestPhotos([
      PhotoRequest(brand: slot.brand, model: slot.modelName, year: slot.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    return ModelPhotoWidget(
      brand: slot.brand,
      model: slot.modelName,
      year: slot.year,
      borderRadius: CompareConfig.slotRadius,
      borderRadiusGeometry: const BorderRadius.vertical(
        top: Radius.circular(CompareConfig.slotRadius),
      ),
      showNoPhotoBadge: false,
    );
  }
}
