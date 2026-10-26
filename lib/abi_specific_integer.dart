// Part of dart:ffi

import 'dart:ffi';

/// The supertype of all [Abi]-specific integer types.
///
/// [Abi]-specific integers should extend this class and annotate it with
/// [AbiSpecificIntegerMapping] to declare the integer size and signedness
/// for [Abi.values].
@Since('2.16')
base class AbiSpecificInteger extends NativeType {
  const AbiSpecificInteger();
}

/// Mapping for a subtype of [AbiSpecificInteger].
///
/// See documentation on [AbiSpecificInteger].
@Since('2.16')
final class AbiSpecificIntegerMapping {
  final Map<Abi, NativeType> mapping;

  const AbiSpecificIntegerMapping(this.mapping);
}

/// Example: UintPtr
@AbiSpecificIntegerMapping({
  Abi.androidArm: Uint32(),
  Abi.androidArm64: Uint64(),
  Abi.androidIA32: Uint32(),
  Abi.androidX64: Uint64(),
  Abi.fuchsiaArm64: Uint64(),
  Abi.fuchsiaX64: Uint64(),
  Abi.fuchsiaRiscv64: Uint64(),
  Abi.iosArm: Uint32(),
  Abi.iosArm64: Uint64(),
  Abi.linuxArm: Uint32(),
  Abi.linuxArm64: Uint64(),
  Abi.linuxIA32: Uint32(),
  Abi.linuxX64: Uint64(),
  Abi.linuxRiscv32: Uint32(),
  Abi.linuxRiscv64: Uint64(),
  Abi.macosArm64: Uint64(),
  Abi.macosX64: Uint64(),
  Abi.windowsIA32: Uint32(),
  Abi.windowsX64: Uint64(),
})
final class UintPtr extends AbiSpecificInteger {
  const UintPtr();
}
