needsPackage("InvariantRing");
load "seedGenExpansion.m2";
load "Invariants.m2";


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
    P = for x to numRows W - 1 list p;
    W = gapeit(p);
    R = QQ[a_1..a_(numColumns W)];
    D = diagonalAction(W,P,R);
    --for x in genseeds(diagonalAction(W,p, R)) do (print (isInvariant (x,D)););
    --print("Invariants method:");
    --print(invariants D);
    print("Elementary Invariants Method");
    print(elementaryInvariants(diagonalAction(W,P, R)));
    return genseeds(diagonalAction(W,P, R));

)