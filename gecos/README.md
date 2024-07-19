# GECOS directory content

This folder contains:

- `GecosToUclidConverter.xtend` which is a modified version of the original Gecos file that correctly translates C++ into UCLID.
- `UclidRunner.xtend` which is a modified version of the original Gecos file that runs single_spec.cpp without issues.
- `fsm_x_UCLID_compliant.cpp` which is a hand-tweaked version of the auto-generated fsm_x.cpp that yields correct UCLID once compiled.
- `fsm_x.ucl` which is the result of the compilation of `fsm_x_UCLID_compliant.cpp` with `GecosToUclidConverter.xtend`.
- `single_spec_UCLID_compliant.cpp` which is a not-so hand-tweaked version of the auto-generated single_spec.cpp that yields correct UCLID once compiled.
- `single_spec.ucl` which is the compilation output of `single_spec_UCLID_compliant.cpp`.
- `single_spec_invariant_autogen.cpp` which is a version that allows the auto generation of invariant (on dummy functions).
- `single_spec_invariant_example.ucl` which is the compilation output of `single_spec_invariant_autogen.cpp`.
- `single_spec_cleanedup.ucl` which a complete revamped of the original single_spec.cpp, focused on readability.
