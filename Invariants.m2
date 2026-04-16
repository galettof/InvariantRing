-*
   Copyright 2020, Luigi Ferraro, Federico Galetto,
   Francesca Gandini, Hang Huang, Matthew Mastroeni, Xianglong Ni.

   You may redistribute this file under the terms of the GNU General Public
   License as published by the Free Software Foundation, either version 2 of
   the License, or any later version.
*-


-------------------------------------------

-------------------------------------------
--- Elementary Invariants Methods ---------
-------------------------------------------

-- Checks if a list is completely 0
isZero := L -> (
    for i in L do if (i != 0) then return false;
    return true;
)
-- Reduces a monomial by all other monomials in a list. 
-- Returns: 1 if it is to be removed
--          2 if it is minimal and can't be removed
reduceit := (l, L) -> (
    for a in L do (
        if (a == l) then return 1;
        killit := true;
        for i to #a - 1 do if (l#i < a#i) then killit = false;
        if killit then (
            l = l - a;
            if isZero(l) then return 1;
        );
    );
    return 2;
)
-- Checks if a given seed is minimal.
-- Returns: 0 if m is not minimal
--          1 if l is not minimal
--          2 if m is minimal
seedminimal := (m, L) -> (
    for l to #L-1 do (
        mmin := true;
        lmin := true;
        for i to #m - 1 when (mmin or lmin) do (
            if (m_i > L#l_i) then mmin = false;
            if (L#l_i > m_i) then lmin = false;
        );
        if lmin then return 0;
        if mmin then return reduceit(L#l - m, L);
    );
    return 2;
)

-->-- Method for p x p group with representative weight matrix --<--
elementaryInvariants = method();
elementaryInvariants(DiagonalAction) := D -> (
    
    W := D.weights_1;
    d := (D.cyclicFactors)#0;
    R := ring D;
    --------------------------
    -->-- generate seeds --<--
    n := numColumns W; m := numRows W;
    -->-- find submatrix with nonzero determinant --<--
    subVars := matrix{{0}}; colList := {};
    mList := toList (0..(m-1));
    for i to n - m do (
        rod := submatrix(W, mList, toList (i..(i + m - 1)));
        if (determinant rod != 0) then (
            subVars = rod;
            colList = toList (i..(i + m - 1));
            break;
        );
        
    );

    -->-- return error if no nonzero submatrix determinant exists --<--
    if (subVars == matrix{{0}}) then (
        error ("No invariants for this weight matrix.\n");
        return {};
    );
    seedList := {};
    -->-- Creates all the representative exponent vectors in accordance with the algorithm --<--
    for v in toList(set(toList (0..(n-1))) - set(colList)) do (
        wColumns := sort({v} | colList); tempVec := {}; signFlip := 1;
        for i in wColumns do (
            e := for j from 0 to n-1 list (if j == i then 1 else 0);
            subM := submatrix(W, mList, sort(toList(set(wColumns) - set({i}))));
            print ("submatrix plucker:");
            print(subM);
            tempVec = tempVec | {signFlip * (determinant subM) * e};
            signFlip = signFlip * -1;
        );
        seedList = seedList | {sum tempVec};
    );

    print("Old seedList: ");
	print(seedList);
    ------------------------
    -->-- expand seeds --<--
    gR := gens R;
    ind := numgens R - 1;
    seedList = for l in seedList list apply(l, x -> ((x % d) + d) % d);
    newList := seedList;
    trashList := seedList | {apply(ind + 1, i -> 0)};
    -->-- Expands each of the seeds in accordance with the representative exponent vectors --<--
    -->-- The monomials are represented via their exponent vectors as lists in m2 --<--
    for i from 1 to (d) do (
            for m when m < #newList do (       
            for n to #newList - 1 do (
                m' := (newList#m)*i;
                n' := newList#n;
                m' = (m' + n') % d;
                if (not isZero(m')) and (not any(trashList, t -> (m' == t))) then (
                    result := seedminimal(m', newList);
                    if (result == 1) then (
                        newList = replace(n, m', newList);
                        m = m - 1;
                    )
                    else if (result == 2) then newList = newList | {m'}
                    else trashList = trashList | {m'};
                );
            );
        );
    );
    -->-- Then, we add the pure powers to the list --<--
    for i from 0 to (numgens R - 1) do (
        newList = newList | {for k to numgens R - 1 list (if i == k then d else 0)};
    );
    polyList := {};
    -->-- Then, we turn each of the exponent vectors into their polynomials in the Ring --<--
    for i in newList do (
        n := 1;
        for j to #i - 1 do (n = n * (((gens R)_j)^(i_j)));
        polyList = polyList | {n};
    );

    return sort polyList;
)


