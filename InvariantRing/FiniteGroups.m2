-*
   Copyright 2020, Luigi Ferraro, Federico Galetto,
   Francesca Gandini, Hang Huang, Matthew Mastroeni, Xianglong Ni.

   You may redistribute this file under the terms of the GNU General Public
   License as published by the Free Software Foundation, either version 2 of
   the License, or any later version.
*-

FiniteGroupAction = new Type of GroupAction

finiteAction = method()

finiteAction (List, PolynomialRing) := FiniteGroupAction => (G, R) -> (
    if not isField coefficientRing R then (
	error "finiteAction: Expected the second argument to be a polynomial ring over a field."
	);
    if any (G, g -> not instance(g, Matrix) or numRows g =!= numColumns g) then (
	error "finiteAction: Expected the first argument to be a list of square matrices."
	);
    if (numRows first G) =!= dim R then (error "finiteAction: Expected the number of rows of each matrix to equal the number of variables in the polynomial ring."); 
    try (
	gensG := apply(G, g -> sub(g, coefficientRing R))
	)
    else (
	error "finiteAction: Expected a list of matrices over the coefficient field of the polynomial ring."
	);
    new FiniteGroupAction from {
	cache => new CacheTable,
	(symbol ring) => R, 
	(symbol generators) => gensG,
	(symbol numgens) => #(gensG),
	}
    )

finiteAction (Matrix, PolynomialRing) := FiniteGroupAction => (g, R) -> finiteAction({g}, R)



--net of FiniteGroupAction object
net FiniteGroupAction := G -> (net G.ring)|" <- "|
    horizontalJoin( {"<"} | mingle(apply(G.generators,net),toList(G.numgens-1:", ")) | {">"})

--tex of FiniteGroupAction object
texMath FiniteGroupAction := G -> (texMath G.ring) |"\\curvearrowleft" |
    "\\left\\langle" |
    (concatenate mingle(apply(G.generators,texMath),toList(G.numgens-1:", "))) |
    "\\right\\rangle"

    
generators FiniteGroupAction := opts -> G -> G.generators

numgens FiniteGroupAction := ZZ => G -> G.numgens


-------------------------------------------

isAbelian = method(Options => true)

isAbelian FiniteGroupAction := { } >> opts -> (cacheValue (symbol isAbelian)) (
    G -> runHooks((isAbelian, FiniteGroupAction), G) )


addHook((isAbelian, FiniteGroupAction), G -> (
	X := G.generators;
    	n := #X;
    	if n == 1 then true 
    	else all(n - 1, i -> all(n - 1 - i, j -> (X#j)*(X#(n - 1 - i)) == (X#(n - 1 - i))*(X#j) ) )
	))
  
  

generateGroup = method(Options => true)

generateGroup FiniteGroupAction := {} >> opts -> (cacheValue (symbol generateGroup)) (G -> runHooks((generateGroup, FiniteGroupAction), G) )

addHook((generateGroup, FiniteGroupAction), G -> (
    m := numgens G;
    n := dim G;
    K := coefficientRing ring G;
    X := gens G;
    
    S := new MutableHashTable from apply(m, i -> 
	i => new MutableHashTable from {id_(K^n) => X#i}
	);
    
    A := new MutableHashTable from {id_(K^n) => {{}}}|apply(m, i -> X#i => {{i}});
    
    toUpdate := X;
    
    local h; local a;
    while #toUpdate > 0 do(
	h = first toUpdate;
	a = first A#h;
	
	scan(m, i -> (
		g := h*(X#i);
		a' := a|{i};
		S#i#h = g;
		if A#?g then (
		    A#g = (A#g)|{a'}
		    )
		else (
		    A#g = {a'};
		    toUpdate = toUpdate|{g}
		    )
		)
	    );
	
	toUpdate = drop(toUpdate, 1);
	);
    A = hashTable pairs A;
    S = hashTable apply(keys S, i -> i => hashTable pairs S#i);
    (S, A)
    )) 


-------------------------------------------

schreierGraph = method(Options => true)

schreierGraph FiniteGroupAction := {} >> opts -> (cacheValue (symbol schreierGraph)) (G -> runHooks((schreierGraph, FiniteGroupAction), G) )

addHook((schreierGraph, FiniteGroupAction),  G -> (generateGroup G)_0 )    
   

-------------------------------------------

group = method(Options => true)

group FiniteGroupAction := { } >> opts -> (cacheValue (symbol group)) (G -> runHooks((group, FiniteGroupAction), G) )

addHook((group, FiniteGroupAction), G -> keys first schreierGraph G )


-------------------------------------------

words = method(Options => true)

words FiniteGroupAction := { } >> opts -> (cacheValue (symbol words)) (G -> runHooks((words, FiniteGroupAction), G) )

addHook((words, FiniteGroupAction), G -> applyValues((generateGroup G)_1, val -> first val) )


-------------------------------------------

relations FiniteGroupAction := { } >> opts -> (cacheValue (symbol relations)) (
    G -> runHooks((relations, FiniteGroupAction), G) )

addHook((relations, FiniteGroupAction), G -> (
    relators := values last generateGroup G;
    W := apply(relators, r -> first r);
    relators = flatten apply(#W, i -> apply(drop(relators#i, 1), a -> {W#i,a} ) );
    relators = apply(relators, r -> (
	    w1 := first r;
	    w2 := last r;
	    j := 0;
	    while (j < #w1 and w1#j == w2#j) do j = j + 1;
	    {drop(w1, j), drop(w2, j)}
	    )
	);
    unique relators 
    )) 


-------------------------------------------

permutationMatrix = method(Options => {EntryMode => "one-line"})

permutationMatrix Array := Matrix => opts -> p -> (
    if opts.EntryMode == "cycle" then permutationMatrix(max p, p)
    else (
    	n := max p;
    	if #p =!= n or set (1..n) =!= set p then (
	    error "permutationMatrix: Expected a sequence of positive integers
	    representing a permutation."
	    );
    	matrix apply(n, i -> apply(n, j -> if p#j - 1 == i then 1 else 0) )
	)
    )

permutationMatrix (ZZ, Array) := Matrix => opts -> (n, c) -> (
    if n <= 0 then error "permutationMatrix: Expected a positive integer.";
    if #c == 0 then error "permutationMatrix: Expected a nonempty array,";
    if #(set c) =!= #c or not isSubset(set c, set(1..n)) then (
	error "permutationMatrix: Expected an array of distinct integers 
	between 1 and the first input."
	 );
     permutationMatrix new Array from apply(n, i ->
	 if (set c)#?(i + 1) then (
	     k := position(c, j -> j == i + 1);
	     if k == #c - 1 then c#0 else c#(k + 1)
	     )
	 else i + 1
	 )
     )

permutationMatrix (ZZ, List) := Matrix => opts -> (n, p) -> product apply(p, c -> permutationMatrix(n, c) )

permutationMatrix List := Matrix => opts -> p -> permutationMatrix(max (p/max), p)
	     

-- Permutation action is finite group action whose generators are permutations in one-line notation.

PermutationAction = new Type of FiniteGroupAction

-- helper to recover one line notation from a permutation matrix:
oneLineFromMatrix = M -> apply(entries transpose M, col -> (position(col, e -> e == 1)) + 1)

permutationAction = method(Options => {Variable => "x", EntryMode => "one-line"})

permutationAction (List, PolynomialRing) := PermutationAction => opts -> (P,R) -> (
	if not isField coefficientRing R then ( --check if field
	    error "permutationAction: Expected a polynomial ring over a field."
	);
        n := numgens R;
	P = apply(P, p -> (
		if opts.EntryMode == "cycle" then (
			oneLineFromMatrix permutationMatrix(n, p) -- p is a list of cycles
		)
		else (
			if not instance(p, List) or sort p =!= toList(1..#p) then (
				error "permutationAction: expected permutations of {1,...,k}, for some k, in one-line notation."
			);
			if #p > n then (
				error "permutationAction: expected permutations of {1,...,n} with n less than the number of variables."	
			);
			p | toList(#p+1..n) -- Extend the permutation to the number of variables.
		)
		));
	K := coefficientRing R;
	new PermutationAction from {
		cache => new CacheTable,
		(symbol ring) => R,
		-- Turn list into array then turn into matrices over K
		(symbol generators) => apply(P, p -> sub(permutationMatrix new Array from p, K)),
		(symbol numgens) => #P,
		(symbol permutations) => P
		}
)

-- constructor overload with no ring given, default to QQ[x_1..x_n]

permutationAction (List) := PermutationAction => opts -> P -> (
	n := max apply(P, p -> #p);
	x := getSymbol opts.Variable;
	R := QQ(monoid[x_1..x_n]);
	permutationAction(P, R)
)

--net of PermutationAction object showing permutations not matrices
net PermutationAction := A -> (net A.ring)|" <- "|
	horizontalJoin( {"<"} | mingle(apply(A.permutations, net), toList(A.numgens-1:", ")) | {">"})

--tex of net of PermutationAction object

texMath PermutationAction := A -> (texMath A.ring) |"\\curvearrowleft" |
	"\\left\\langle" |
	(concatenate mingle(apply(A.permutations, texMath), toList(A.numgens-1:","))) |
	"\\right\\rangle"

-- find all special exponents, namely sorted ascending with first entry 0 and no jumps larger than 1
-- FG: caching uses a lot of memory and does not speed this up much
specialExponents = n -> (
	L := {{0}}; -- list of exponent vectors
	for i from 2 to n do (
		-- either add 1 or repeat last entry, flatten removes the nesting
		L = flatten apply(L, v ->  {v | {last v}, v | {last v + 1}}
	)
	);
	L
)

-- find the orbit of a vector v
-- we do this by applying the generators to v and all new vectors until we get everything
orbitExponents = (A, v) -> (
	P := A.permutations; -- get permutations
	seen := new MutableHashTable from {v => true}; -- "found set": hash table gives quick membership checks
	toUpdate := {v}; -- vectors found but we still need to apply generators to
	local h;
	while #toUpdate > 0 do (
		h = first toUpdate;
		toUpdate = drop(toUpdate, 1); -- drop h from toUpdate
		scan(P, p -> (
			w := apply(p, i -> h#(i-1)); -- apply the action
			if not seen#?w then (
				seen#w = true;
				toUpdate = toUpdate | {w}
			)
		));
	);
	keys seen -- return the vectors in the hashtable
)

-- exported methods

specialMonomials = method()
--returns all special monomials in the ring
specialMonomials PermutationAction := List => A -> (
	R := ring A;
	flatten apply(specialExponents numgens R, v -> 
		if sum v == 0 then {} -- this would give 1 	
		else apply(unique permutations v, i -> R_i)
	)
)

orbitSum = method()

orbitSum (RingElement, PermutationAction) := RingElement => (r, A) -> (
	R := ring A;
	if not instance(r, R) then error "orbitSum: Expected an element of the ring being acted on.";
	if #(terms r) =!= 1 then error "orbitSum: Expected a monomial.";
        -- the orbit sum construction ignores coefficients
	sum(orbitExponents(A, flatten exponents r), i-> R_i)
) 





