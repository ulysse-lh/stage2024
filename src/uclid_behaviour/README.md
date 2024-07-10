# UCLID black box prover behaviour

This folder aims to study a little bit the behaviour of UCLID, its preference for code formulation.

## Imperative vs Functional style

Assets:

- `uclid_behaviour_imperative.ucl` contains an imperative version of the cond/slow/fast example (without any speculation, just dynamic scheduling). Here, imperative means that the procedures `next1` and `next2` make use of the `modifies` clause in their prototype, implying they cause side-effects.
- `uclid_behaviour_semi_functional.ucl` contains a semi-functional version of `uclid_behaviour_imperative.ucl`. Here, functional means that the procedures `next1` and `next2` are in fact functions that do not rely on any global state and do not cause side-effects (no `modifies` clause in the prototype). In UCLID, the output of a procedures are effectively variables, meaning they can be assigned any number of times inside the procedure. In that sense, this example is "semi-functional" because, in `next2`, the outputs are assigned to multiple times.

    To be more specific, `next2` starts with:

    ```uclid
    procedure next2(x: integer, i: integer, state: integer) returns (x1: integer, i1: integer, state1: integer) {
        x1 = x;
        i1 = i;
        state1 = state;
        ...
    ```

    which can be seen as giving the outputs a sane default (remainder: garbage if not initialized), which can be overriden anytime in the `...`.
- `uclid_behaviour_functional.ucl` contains a fully-functional version of `uclid_behaviour_semi_functional.ucl` in the sense that the outputs of `next2` are written to exactly once.
- For each file, we are trying to prove the following invariants:

    ```uclid
    invariant valid_stuff: t >= 0 && i1 == t && 0 <= i2 <= t;
    invariant goal: i1 == i2 ==> x1 == x2;
    ```

    where `valid_stuff` is used to help UCLID reach the goal. An induction tactic of depth 6 is used for all files.

### Observations

`uclid uclid_behaviour_imperative.ucl` and `uclid uclid_behaviour_semi_functional.ucl` both succeed at reaching the goal. However, `uclid uclid_behaviour_functional.ucl` fails at the two last induction steps. Increasing its induction depth to 20 does not change anything. For this specific case, making it succeed is pretty simple since the counter-example found by UCLID involves `state` being equal to garbage value like 25 (which never happens), so by adding `0 <= state2 <= 2` to the invariant `valid_stuff`, we finally complete the goal for `uclid_behaviour_functional.ucl`.

In conclusion, to be clear, `0 <= state2 <= 2` is **not** required to prove `uclid_behaviour_imperative.ucl` and `uclid_behaviour_semi_functional.ucl` while it **is** for `uclid_behaviour_functional.ucl`.

### Conclusion

This little experiment tends to indicate that UCLID has great trouble dealing with variable assignation in complex execution path (i.e. 2+ levels of branching).

## Fixed-size arithmetic

Asset:

- `arith.ucl` contains several assertions that **should all pass** for any C-like language featuring round-down integer division, comparison and modulo operation. The assertions are only studied for bit-vectors of length 3 (\[0-7\]).

### Observations

1. Comparison is broken: `4 > 0`, `5 > 0`, `6 > 0` and `7 > 0` fail where they should obviously succeed.
2. Division is broken: `6 / 7` yields `2` while `7 / 6` yields `0`.
3. Modulo is broken: While `4 % 2` and `6 % 2` both yield `0`, `5 % 2` and `7 % 2` yield `7`. Since `7 = -1 mod 8`, it could be reasonable to say that UCLID computes modulo negatively (`5 = 1 mod 2 <=> 5 = -1 mod 2 <=> 5 = 7 mod 8 mod 2` and respectively for `7` instead of `5`). **However**, this is **not** the case since `7 % 5` still yields `7` when it should be `2` (and `7 != 2 mod 8`).
4. Addition, substraction and multiplication seems to be working fine.

### Conclusion

Translating C code into UCLID may prove more challenging than expected.

### About bit-vectors length

Using bit-vectors of length 32 instead of length 3 cleans most of the problems encountered before. However, UCLID still does not accept that `n % 2 == 0 || n % 2 == 1` holds, with length 3 and 32 alike.
