/// Notes on Dart FFI ABI-specific integer types.
///
/// `AbiSpecificInteger` and `AbiSpecificIntegerMapping` are SDK-level
/// declarations owned by `dart:ffi`. Application code should import
/// `dart:ffi` and use its public native integer types rather than redeclaring
/// SDK classes in a package library.
///
/// This file is intentionally documentation-only: copying SDK implementation
/// declarations into an application library can conflict with the SDK and
/// depends on internal annotations that are not part of the public API.
