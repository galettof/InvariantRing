permMat = method()

-- permutation from one-line notation
permMat Array := Matrix => p -> (
    n := max p;
    if #p =!= n or set (1..n) =!= set p then (
        error "permutationMatrix: Expected an array of positive integers
        representing a permutation."
        );
    matrix table(n,n, (i,j) -> if p#j - 1 == i then 1 else 0)
    )
