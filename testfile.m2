load "seedGenExpansion.m2";
needsPackage("InvariantRing")

gapeit = method();
gapeit(ZZ) := (p) -> (
    boop = true;
    H = {};
    while (boop) do (
        n = random(10) + 3;
        m = random(n-3) + 2;
        W = random((ZZ)^m,(ZZ)^n);
        
        for w in entries W do (
            h = {};
            for v in w do (
                h = h | {v % p};
            );
            H = H | {h};
        );
        H = matrix H;

        if (rank H == m) then (
            boop = false;
        );
    );
    return H
)

soundit = method();
soundit(ZZ) := (n) -> (
    p = random(n);
    while (not isPrime p) do (p = random(n));
    return p;
)

eifulltower = method();
eifulltower(ZZ) := (x) -> (
    p = soundit(100);
    W = gapeit(p);
    R = QQ[a_1..a_(numColumns W)];
    D = diagonalAction(W,for x to numRows W - 1 list p,R);
    for x in genseeds(diagonalAction(W,p, R)) do (print (isInvariant (x,D)););
    return genseeds(diagonalAction(W,p, R));

)