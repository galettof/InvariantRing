-- this file was used to compare the Derksen-Gandini algorithm
-- with the new algorithm for elementary abelian p-groups
-- introduced in version 2.5
-- it contains many examples with elementary abelian p-groups
-- some of these computations can take a long time

restart
needsPackage "InvariantRing"

-- track if results from different algorithms are not the same
allTrue := true
same := false

-- list of primes
P = {2,3,5,7,11,13,17,19,23,29}

-- list of weight matrices
for W in {
    matrix{{1,0,1},{0,1,1}},
    matrix{{1,1,1,1},{1,1,0,0}},
    matrix{{1,0,0,1,1},{1,1,0,0,0}}
    } do (
    R = QQ[x_1..x_(numgens source W)];
    for p in P do (
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
