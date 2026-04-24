restart
load "InvariantRing.m2"
P = {2,3,5,7,11,13,17,19, 23, 29, 31, 37}
p = (random(P))_0
R = QQ[x_1..x_3]
W = matrix{{1,0,1},{0,1,1}}
L = {p,p}
T = diagonalAction(W,L,R)

elapsedTime invariants(T, Strategy => "DerksenGandini")
elapsedTime invariants T

-- Dr.G second methods appears faster and is now the default strategy
-- replaced seedGenExpansion.m2 and integrated in the invariants.m2 file





