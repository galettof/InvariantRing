restart
installPackage "InvariantRing"
--shows all installing messages

-- keeps track if any are not the same
allTrue := true

same := false

--P list
P = {2,3,5,7,11,13,17,19,23,29}


-- Matrix List any matrix works
for W in {
    matrix{{1,0,1},{0,1,1}},
    matrix{{1,1,1,1},{1,1,0,0}},
    matrix{{1,0,0,1,1},{1,1,0,0,0}}
} do (
R = QQ[x_1..x_(numgens source W)];
for p in P do (
    --W = matrix{{1,0,1},{0,1,1}};
    print((numgens target W) | "X" | (numgens source W) | " Matrix, with p = " | p); 
    L = {p,p};
    T = diagonalAction(W,L,R);
    print("DerksenGandini Time: ");
    elapsedTime inv = invariants(T, Strategy => "DerksenGandini");
    print("Elementary Time: ");
    elapsedTime einv = invariants(T, Strategy => "Elementary");
    same = (set inv == set einv);
    print("Match: " | toString(same));
    allTrue = allTrue and (set inv == set einv);
    print(" "); -- new line so looks good
);

);

print("All same:" | toString(allTrue))

-- Dr.G second methods appears faster and is now the default strategy
-- replaced seedGenExpansion.m2 and integrated in the invariants.m2 file

-- results on Fred's laptop:
-- p=3, DG .0137053s, EI .00292116s
-- p=19, DG 2.14085s, EI 3.10214s
-- p=23, DG 4.45032s, EI 10.5367s
-- p=37, DG 32.4892s, EI 227.757s
