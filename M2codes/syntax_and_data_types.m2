-- This file is an introduction to basic Macaulay2 syntax and data types

-- Macaulay2 supports standard mathematical and algebraic types.
-- Let's explore common types and how to work with them.


-- Integers (ZZ)
a = 5
b = -3
a + b
a^2

-- Rational numbers (QQ)
q = 3/4
q * 2

-- RR the class of all real numbers includes floating numbers with default precision of 53
r0 = 1.234
r1 = 3.14 * 2

-- toRR convert to high-precision real number
r2 = toRR_100 2

-- CC the class of all complex numbers
c0 = 1/(1+ii)
c1 = .5-.5*ii

-- toCC convert to high-precision complex number
c1 = toCC_30 .5-.5*ii

-- Other types of numbers in M2
InfiniteNumber
InexactNumber
IndeterminateNumber
Constant

-- Strings
str = "Macaulay2 is cool!"
str | " Really." -- Concatenation
ascii str -- converts to list of ascii values

-- Lists: Lists in Macaulay2 consist of elements of any type.
L = {1, 2, 3}
L#0         -- Indexing (0-based)
L#2
apply(L, x -> x^2) -- Applying a operation to all elements of the list
scan(L, i -> print(i^2)) -- -- Iterating with scan

-- Sequences: A sequence is an ordered collection of things
S = (1, "a", 3/2)
class S -- get the class of the object
S#2 

-- The operator ZZ : Thing creates a sequence by replicating an element a given number of times.
10:"M2"

-- Hashtables
H = new HashTable from {a => 1, b => 2}
H#a
H#b = H#b + 1
peek H -- This function (peek) is used during debugging Macaulay2 programs to examine the internal structure of objects.

-- Operators full documentation: https://macaulay2.com/doc/Macaulay2/share/doc/Macaulay2/Macaulay2Doc/html/_operators.html
-- = -- assignment
-- := -- assignment of method or new local variable
-- <- -- assignment with left side evaluated
-- < -- less than
-- <= -- less than or equal
-- > -- greater than
-- >= -- greater than or equal
-- ? -- comparison operator


-- Loops (while)
i := 0 -- local variable assignment
while i < 3 do (
    print("i is " | toString i);
    i = i + 1;
)
-- (for)
for i from 1 to 3 do (
          print "The value of i is : ";
          print i
          )

-- Conditional Execution
(-4 .. 4) / 
          (i -> if i < 0 then "neg" 
               else if i == 0 then "zer" 
               else "pos")

-- Ring elements and symbolic algebra
R = QQ[x,y,z]
f = x^2 + y*z
diff(x, f)   -- Partial derivative

-- Creating matrices
M = matrix {{1,2},{3,4}}
transpose M
det M

-- Ideals and algebraic structures
I = ideal(x^2 - y, y^2 - z)
dim I
gens I -- Use generators or its abbreviation gens to get the generators of an ideal I


-- Go to this documentation website for comprehensive documentation of Macaulay2: 
-- https://macaulay2.com/doc/Macaulay2/share/doc/Macaulay2/Macaulay2Doc/html/___The_sp__Macaulay2_splanguage.html