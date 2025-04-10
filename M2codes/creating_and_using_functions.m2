-- This file is an introduction to creating functions in Macaulay2

-- The operator -> is used to make new functions. On its left we provide the names of the parameters to the function, 
-- and to the right we provide the body of the function, an expression involving those parameters whose value is to be 
-- computed when the function is applied. Let's illustrate this by making a function for squaring numbers and calling it sq.

-- You can press "Alt/Option + enter" to run individual line of a .m2 file
sq = i -> i^2
sq(1+1)

-- When the function is evaluated, the argument is evaluated and assigned temporarily as the value of the parameter i. 
-- In the example above, i was assigned the value 2, and then the body of the function was evaluated, yielding 4.


-- Here is how we make a function with more than one argument.
tm = (i,j) -> i*j
tm(1+1,3)

-- Functions can be used without assigning them to variables. 
-- This can be usefull when you don't need to use it in different places but want to try multiple inputs for evaluation
(i -> i^2) 7
(i -> i^2) 5

-- Another way to make new functions is to compose two old ones with the operator @@.
-- Be mindful of the order in which the functions are applied. 
-- @@ evaluates the functions in right to left order
multiplyThenSquare = sq @@ tm 
multiplyThenSquare(2,3)

-- Code that implements composition of functions is easy to write, because functions can create new functions and return them. 
-- We illustrate this by writing a function called comp that will compose three functions, similar way the operator @@ did above.
comp = (f1,f2,f3) -> (x,y) -> f1(f2(f3(x,y)))
multiplySquareSquare = comp(sq,sq,tm)
multiplySquareSquare(1,2)

-- It is easy to write a function with a variable number of arguments. Define the function with just one parameter, 
-- with no parentheses around it. If the function is called with several arguments, the value of the single parameter 
-- will be a sequence containing the several arguments; if the function is called with one argument, the value of 
-- the parameter will be that single argument. Use := operator to create local variables. Once created new values can 
-- be assigned to it with expressions like X = Z. You can use both {} and () to return multiple values.
productAll = x -> (
    productall := 1;
    if (class x === Sequence) then (
        productall = 1;
        scan(x, i -> productall = productall*i)
    )
    else (
        productall = x;
    );
    (class x,  productall)
)
productAll(2)
productAll(4,2)
productAll(1,2,3)

-- making new functions with optional arguments for a linear equation (default slope =1, intercept = 0).
-- We use the >> operator to attach the default values to our function, coded in a special way
-- The optional inputs can be inserted in any order, and may even occur before the required inputs. 
-- If more than one optional input with the same option name are given, then the value accompanying 
-- the right-most one is the value provided to the function.
linearEquation = {Slope => 1, Intercept => 0} >> args -> x -> x * args.Slope + args.Intercept
linearEquation(3)
linearEquation(Slope => .5, 3, Intercept => 1)
linearEquation(3,Slope => 13)

-- Use options to discover the optional arguments accepted by a function.
options linearEquation
options gb


-- Coming Soon: Use of Hooks in Macaulay2
