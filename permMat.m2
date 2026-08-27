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
