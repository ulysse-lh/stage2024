# Speculative Loop Pipelining 2024 internship Ulysse Le Huitouze

Technical report

## Git project layout

- `gecos` folder contains everything related to compilation, including the main xtend file but also some samples, reworked to become UCLID compliant.
- `slides` contain the slides used throughout this internship.
- `src` contains all UCLID toy examples studied. Their correspondance with the ones in the slides should be fairly obvious.

## Compilation (Gecos HLS part)

The file `gecos/GecosToUclidConverter.xtend` is a modified version of the gecos' `GecosToUclidConverter.xtend` that supports translating simple C++ code into UCLID. Restrictions to the C++ semantics include (non-exhaustive):

- No `goto`, switch fallthrough, `break`, `continue`, `return` as a goto in disguised, etc.
- No assignment-as-an-expression, i.e. no `if ((a = b / 5))` nor `j = i++;`.

The translation step C++ to UCLID has the following builtin behaviour:

1. One function annotated with `#pragma toplevel` is required for the whole project. That function must have the following skeleton:
    ```C
    #pragma toplevel
    void run() {
        init:
        ... // let's call this code A
        while (some_condition) {
            next:
            ... // let's call this code B
        }
    }
    ```

    which will be automatically translated into
    ```uclid
    var finished123: boolean;

    init {
        finished123 = false;
        ... // code A
    }
    next {
        if (!finished123) {
            finished123 = some_condition;
        }
        if (!finished123) {
            ... // code B
        }
    }
    ```
2. Any function whose name starts with `init_` (resp. `next_`) will be called in UCLID's init (resp. next) block.
3. Any cast of the form `(bool)some_integer` is converted into `some_integer == 0`. Any cast of the form `(bool)some_ac_intNbits` is converted into `some_ac_intNbits == 0bvN`. Any cast of the form `(ac_int<N, false>)M` where `M` is an integer literal is converted into `MbvN`. Any other cast is not supported and will print "failure" inside the ouput file or will crash.
4. Procedure calls-as-an-expression are partially supported. While `if (f(...))` and `a = g(f(...), ...);` will yield the uclid code `tmp = f(...); if (tmp)` and `tmp = f(...); a = g(tmp, ...);` respectively, `switch (f(...))` (among others) is not supported yet.
5. Given the following C++ skeleton:
    ```C++
    Type myvar_spec;
    Type myvar;

    #pragma spec
    void f() {
        ... // let's call this code A. Edits myvar_spec.
    }

    #pragma impl
    void g() {
        #pragma HLS PIPELINE II=n
        #pragma HLS PIPELINE worst II=m
        ... // let's call this code B. Edits myvar.
    }
    ```

    , the following UCLID invariant is generated:

    ```uclid
    invariant main_inv: history(myvar_spec, n) = history(myvar, n) ==> history(myvar_spec, n - 1) = myvar;
    ```

    To be more general, the invariant `main_inv` has the following form:

    ```uclid
    invariant main_inv: $for all variable v edited by g such that f edits a variable called v_spec, add 'history(v_spec, n) == history(v, n)' to the implication lefthand side$ ==> $for all variable v edited by g such that f edits a variable called v_spec, add 'history(v_spec, n - 1) == v' to the implication righthand side$
    ```

### Practical notes

Built-in behaviour #1 should not be used, as it is incompatible with UCLID semantics. Indeed, UCLID does not support sequential assignments in the `next` block. Furthermore, since only 1 parallel assignment is allowed per variable (e.g. `x' = x + 1; x' = x' + 1;` is not allowed), directly translating C++ toplevel function into an `init` and a `next` block is not doable unless 1 temporary UCLID variable is added per assignment. For this reason, the toplevel function should be a dummy function along the lines:

```C++
#pragma toplevel
void f() {
    init:
    ;
    while (true) {
        next:
        ;
    }
}
```

, meaning that the actual toplevel functionality should be manually split between `init_f` and `next_f` in the C++ source. Finally, similarly to the singleton parallel assignment problem, only 1 edition of a variable is allowed within the `next` block, meaning the following is invalid:

```uclid
var x: integer;

procedure f() modifies x; {
    x = x + 1;
}

procedure g() modifies x; {
    x = x + 1;
}

next {
    call f();
    call g();
}
```

Therefore, a given variable should only be edited by one function at a time:

```uclid
var x: integer;

procedure f() modifies x; {
    x = x + 1;
}

procedure g() modifies x; {
    call f();
}

next {
    call g();
}
```

is valid UCLID code.

## UCLID platform thoughts

Intermediary invariants seem to be needed practically every time to prove an actual goal. For instance, `static_sched.ucl` requires 3 intermediary invariants in order to prove the goal. The intermediary invariants often contain trivial observations on integer bounds (here about the loop index and the cycle counter) or on valid transitions (which can be trivially verified using an incidence matrix). Increasing the `induction` bound beyond what is necessary (here around 10) does not seem to be useful in such case.

Array-based history (instead of the `history(var, n)` thing) could be explored more, though in my experience it seemed harder to prove. To implement such a mechanism, the following could be added unconditionally to the output file, for each variable `Type myvar` of interest (see built-in behaviour #5):

```uclid
var myvar_array_for_proof: [integer]Type;
var myvar_count_for_proof: integer;
var myvar_spec_array_for_proof: [integer]Type;
var myvar_spec_count_for_proof: integer;

init {
    myvar_count_for_proof = 0;
    myvar_spec_count_for_proof = 0;
    ...
}

procedure myvar_array_for_proof_add() modifies myvar_array_for_proof, myvar_count_for_proof; {
    myvar_array_for_proof[myvar_count_for_proof] = myvar;
    myvar_count_for_proof = myvar_count_for_proof + 1;
}

procedure myvar_spec_array_for_proof_add() modifies myvar_spec_array_for_proof, myvar_spec_count_for_proof; {
    myvar_spec_array_for_proof[myvar_spec_count_for_proof] = myvar_spec;
    myvar_spec_count_for_proof = myvar_spec_count_for_proof + 1;
}
```

Then, every time a set instruction with target `myvar` (resp. `myvar_spec`) would be find, `call myvar_array_for_proof_add()` (resp. `call myvar_spec_array_for_proof_add()`) would be added right after. However, this translation behaviour would require that `myvar` (resp. `myvar_spec`) to be edited at most once per `next` iteration (otherwise, invariant would be too complex).
Finally, the invariant generated would simply be:

```uclid
invariant main_inv: forall (k: integer) :: 0 <= k < myvar_count_for_proof && k < myvar_spec_count_for_proof ==> myvar_array_for_proof[k] == myvar_spec_array_for_proof[k];
```

## GecosToUclidConverter.xtend structure

Additions to the original GecosToUclidConverter.xtend include (non-exhaustive):

- In `convert(GecosSourceFile)`, several sets are used as global state as to remove duplicate symbol, since UCLID does not support redeclaration.
- `correctIdentifier` is used everywhere as to rename variables, functions that are named after UCLID keywords.
- `extractInitTopLevel` and `extractNextTopLevel` implement built-in behaviour #1.
- `extractInitSpec`, `extractNextSpec`, `extractInitImpl` and `extractNextImpl` are used in `extractInvariants` in order to implement built-in behaviour #5.
- `typeName(ACIntTypeImpl)` warns in case the overflow mode is different than wrap, since it is the one and only mode available in UCLID.
- `convert(Procedure)` has been extended as to partially support correct `modifies` UCLID semantics. **IMPORTANT**: It is not finished. UCLID requires that every variable edited within a procedure directly **or** indirectly (modified by another procedure that is called) is listed in the `modifies` clause of the said procedure. For now, only 1 level of call depth is supported. Arbitrary call depth support would require intermediary compilation pass or a stack as global variable. Concretely, the following C++ file will not be valid UCLID once translated:

    ```C++
    int x;

    void h() { // correctly translated
        x++;
    }

    void g() { // correctly translated
        h();
    }

    void f() { // error, missing variable in modifies clause
        g();
    }
    ```
- `static var List<List<String>> tempCallStorage` is a stack used to store procedure-calls-as-an-expression encountered, as to implement built-in behaviour #4. Its usage can be seen in `convertBlock(WhileBlock)`, `convertBlock(DoWhileBlock)`, `convertBlock(IfBlock)` and `convertBlock(BasicBlock)` mainly. It is filled in `convertInstr(CallInstruction)`.
- Similarly to `tempCallStorage`, `static var List<Set<String>> tempVariables` is a stack used to store variables needed to store procedure-call-as-an-expression results. It works in pair with `tempCallStorage` in order to implement built-in behaviour #4. However, contrary to `tempCallStorage`, `tempVariables` grows (as a stack) at the beginning of the file (see `convert(GecosSourceFile)`) and at the beginning of a procedure (see `convert(Procedure)`) since variable declarations are not allowed in the middle of a procedure. Still, similarly to `tempCallStorage`, it is being filled in `convertInstr(CallInstruction)` upon the exact same conditions.
- A few operations were added to `convertInstr(GenericInstruction)`, but some are still missing (e.g. xor, shift).
