restart
needsPackage "InvariantRing"

-- input:
-- list of integer wts (from one row of weight matrix)
-- list of starting monomials (variables, or invariants from previous rows)
-- output: list of monomials for next iteration
rankOneDerksen = (wts,stMons) -> (
    C := toList(min(wts)..max(wts));
    S := new MutableHashTable from apply(C, w -> w => {});
    mons := stMons;
    scan(#mons, i -> S#(wts_i) = S#(wts_i) | {mons#i});
    U := new MutableHashTable from S;
    local w, local m, local u;
    while any(values U, val -> #val > 0) do (
	w = C#(position(C, w -> #(U#w) > 0));
	m = min U#w;
	scan(mons,wts, (xi,wi) -> (
		u = m * xi;
		v = w + wi;
		if isMember(v,C) and all(S#v, f -> not zero(u%f)) then (
		    S#v = S#v | {u};
		    U#v = U#v | {u};
		    );
		));
	U#w = delete(m, U#w);
	);
    if S#?0 then mons = S#0 else mons = {};
    mons
)

-- input: diagonalAction (but only considers the torus)
-- output: torus invariants
recursiveDerksen = D -> (
    W1 := first weights D;
    R := ring D;
    mons := R_*;
    local wts, local M;
    for i to (numRows W1 - 1) do (
	M = transpose matrix flatten apply(mons,exponents);
	wts = flatten entries (W^{i} * M);
	mons = rankOneDerksen(wts,mons);
	);
    mons
    )

R = QQ[x_1..x_4]
W = matrix{{-3,-1,1,2}}
T = diagonalAction(W, R)
elapsedTime i0 = set recursiveDerksen T
elapsedTime i1 = set invariants T
i0 == i1

R = QQ[x_1..x_4]
W = matrix{{0,1,-1,1},{1,0,-1,-1}}
T = diagonalAction(W, R)
elapsedTime i0 = set recursiveDerksen T
elapsedTime i1 = set invariants T
i0 == i1

R = QQ[x_1..x_5]
W = matrix{{0,1,-1,1,-2},{1,0,-1,-1,2},{-1,1,0,0,0}}
T = diagonalAction(W, R)
elapsedTime i0 = set recursiveDerksen T
elapsedTime i1 = set invariants T
i0 == i1

R = QQ[x_1..x_6]
W = matrix{{0,1,-1,1,-2,0},{1,0,-1,-1,2,0},{-1,1,0,0,1,0},{1,-1,0,0,0,-1}}
T = diagonalAction(W, R)
elapsedTime i0 = set recursiveDerksen T
needsPackage "Normaliz"
elapsedTime normalizInv = torusInvariants(W,R)
i1 = set gens normalizInv
i0 == i1
--elapsedTime invariants T -- stopped after 753 seconds
