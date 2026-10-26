/// Small, compilable entry point for checking the ABI exposed by Dart FFI.
///
/// ABI-specific native types such as [UintPtr] are provided by `dart:ffi`.
/// Do not redeclare Dart SDK internals in an application package.
import 'dart:ffi';

/// Returns the ABI for the current runtime.
Abi get currentRuntimeAbi => Abi.current();
