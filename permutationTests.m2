-*
    tests for PermutationAction

    References:
    Computational Invariant Theory:
    Section 3.10.2 covers Goebel's algorithm.

    Dr. Gandini - https://fragandi.github.io/M2forall/ch-invarianttheory.html
*-

loadPackage("InvariantRing", FileName => "./InvariantRing.m2", Reload => true)
debug InvariantRing -- this lets us reach orbit sum and specialMonomials.

print "-- constructor tests --";

-- default ring is QQ[x_1..x_n], n = largest point moved
A = permutationAction {{2,3,1}}
assert(numgens ring A == 3)
assert(coefficientRing ring A === QQ)
assert(#(group A) == 3)

-- shorter permutations are padded with fixed points
C = permutationAction {{2,1},{2,3,1}}
assert(#(group C) == 6) -- generates all of S3

print "-- error tests --";
-- rejects non-permutations
try (permutationAction {{1,1,2}}; print "FAIL: should have rejected {1,1,2}") else print "OK: non-permutation correctly rejected"

-- rejects rings that are not fields
try (permutationAction({{2,1}}, ZZ[x,y]); print "FAIL: should have rejected ZZ[x,y]") else print "OK: non-field coefficient ring correctly rejected"

print "-- pretty printing --";

A
texMath A -- render this in VS Code extension to see typeset output

print "-- special monomials and orbit sums --";

use ring A
print specialMonomials A
print orbitSum(x_1^2*x_2, A)

-- orbitSum only accepts a single monomial from the correct ring
try (orbitSum(x_1+x_2, A); print "FAIL: should have rejected a non-monomial") else print "OK: non-monomial correctly rejected"

print "-- checking against King's results --";
-- minimal generating sets are not unique, so we check that the degrees of the invariants match King's results.
checkAgainstKing = Act -> (
    IG := invariants Act;
    IK := invariants finiteAction(Act.generators, ring Act);
    assert(tally apply(IG, f -> first degree f) === tally apply(IK, f -> first degree f));
    IG
    )

print "-- C3, order 3 --";
IC3 = checkAgainstKing A
print tally apply(IC3, f -> first degree f) -- expect {1 => 1, 2 => 1, 3 => 2}

print "-- S3, order 6 --";
S3act = permutationAction {{2,1,3},{2,3,1}}
IS3 = checkAgainstKing S3act
print tally apply(IS3, f -> first degree f) -- expect {1 => 1, 2 => 1, 3 => 1}

print "-- D4, order 8 --";
D4act = permutationAction {{2,3,4,1},{3,2,1,4}}
ID4 = checkAgainstKing D4act
tD4 = tally apply(ID4, f -> first degree f) -- expect {1 => 1, 2 => 2, 3 => 1, 4 => 1}
print tD4

-- every generator returned is invariant
assert all(ID4, f -> isInvariant(f, D4act))

print "-- fixed variables --";

-- fixed by every generator is itself an invariant.
Atrivial = permutationAction({{1,2}}, QQ[x,y])
Iv = invariants Atrivial
assert(#Iv == 2)
assert(isInvariant(Iv#0, Atrivial) and isInvariant(Iv#1, Atrivial))
print Iv

print "-- modular case --";

try (invariants permutationAction({{2,3,1}}, (ZZ/3)[y_1..y_3]); print "FAIL: should have rejected char 3") else print "OK: modular case correctly rejected"

print "-- speed test on S5 (order 120) --";

G5 = permutationAction {{2,1,3,4,5},{2,3,4,5,1}}
print "Goebel:";
elapsedTime IG5 = invariants G5;
print "King (same action):";
elapsedTime IK5 = invariants finiteAction(G5.generators, ring G5);
assert(tally apply(IG5, f -> first degree f) === tally apply(IK5, f -> first degree f))

print "All permutation action tests passed.";