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

`uclid uclid_behaviour_imperative.ucl` and `uclid uclid_behaviour_semi_functional.ucl` both succeed at reaching the goal. However, `uclid_behaviour_functional.ucl` fails at the two last induction steps. Increasing its induction depth to 20 does not change anything. For this specific case, making it succeed is pretty simple since the counter-example found by UCLID involves `state` being equal to garbage value like 25 (which never happens), so by adding `0 <= state2 <= 2` to the invariant `valid_stuff`, we finally complete the goal for `uclid_behaviour_functional.ucl`.

In conclusion, to be clear, `0 <= state2 <= 2` is **not** required to prove `uclid_behaviour_imperative.ucl` and `uclid_behaviour_semi_functional.ucl` while it **is** for `uclid_behaviour_functional.ucl`.

### Conclusion

This little experiment tends to indicate that UCLID has great trouble dealing with variable assignation in complex execution path (i.e. 2+ levels of branching).
