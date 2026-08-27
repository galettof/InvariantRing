permMat = method()

-- permutation from one-line notation
permMat Array := Matrix => p -> (
    n := max p;
    if #p =!= n or set (1..n) =!= set p then (
        error "permutationMatrix: Expected an array of positive integers
        representing a permutation."
        );
    -- shuffle columns of identity matrix
    (id_(ZZ^n))_(apply(toList p,i->i-1))
    )

-- convert single cycle to one-line notation
cycleToOneLine := (n,c) -> (
    new Array from for i from 1 to n list (
        pos := position(c, x -> x == i);
        if pos =!= null then (
            c_( (pos+1) % #c)
            )
        else i
        )
    )

-- multiply permutations in one-line notation
multiplyOneLine := L -> fold(L, (P,Q) -> P_(toList apply(Q, i -> i-1)))

permMat (ZZ,List) := Matrix => (n,L) -> (
    if n <= 0 then error "permutationMatrix: Expected a positive integer.";
    if #L == 0 then error "permutationMatrix: Expected a nonempty list.";
    if any(L, c -> not instance(c,Array)) then (
        error "permutationMatrix: Expected a list of arrays."
        );
    if any(L, c -> #(set c) =!= #c or not isSubset(c, toList(1..n))) then (
        error ("permutationMatrix: Expected cycles to be arrays of distinct integers 
            between 1 and " | toString(n) | "."
            );
        );
    -- convert cycles to one-line notation
    C := apply(L, c -> cycleToOneLine(n,c));
    -- multiply cycles in one-line notation
    p := multiplyOneLine C;
    -- return matrix from one-line notation
    (id_(ZZ^n))_(apply(toList p,i->i-1))
    )


-- testing
needsPackage "Permutations"
n = 100
-- check old and new code give same matrix
all(for i to 100 list (
        p := apply(select(cycleDecomposition randomPermutation(n), c -> #c != 1),
            c -> new Array from c);
        permMat (n,p) == permutationMatrix (n,p)
        )
    )
-- compare timings
p = apply(select(cycleDecomposition randomPermutation(n), c -> #c != 1), c -> new Array from c);
elapsedTime permMat (n,p);
elapsedTime permutationMatrix (n,p);
