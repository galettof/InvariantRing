restart
needsPackage "InvariantRing"

P = {2,3,5,7,11,13,17,19,23,29,31,37}
R = QQ[x_1..x_3]

for p in P do (
    W = matrix{{1,0,1},{0,1,1}};
    L = {p,p};
    T = diagonalAction(W,L,R);
    print("DerksenGandini Time: ");
    elapsedTime inv = invariants(T, Strategy => "DerksenGandini");
    print("Elementary Time: ");
    elapsedTime einv = invariants(T, Strategy => "Elementary");
    print("Match: " | toString(set inv == set einv));
    print(" "); -- new line so looks good
)

-- Dr.G second methods appears faster and is now the default strategy
-- replaced seedGenExpansion.m2 and integrated in the invariants.m2 file

-- results on Fred's laptop:
-- p=3, DG .0137053s, EI .00292116s
-- p=19, DG 2.14085s, EI 3.10214s
-- p=23, DG 4.45032s, EI 10.5367s
-- p=37, DG 32.4892s, EI 227.757s
