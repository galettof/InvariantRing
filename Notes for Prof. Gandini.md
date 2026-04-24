Apologies for my late start on this. I've been attempting to get everything done but it's been quite the challenge. Here is my work that I've done so far. 
### Nov 13th, 1:46 PM
First to start off, I am going to attempt to rewrite each algorithm in Macaulay2 and compare how this rewrite compares with the implementation. If things are off, then I either know my understanding of the algorithm is incorrect, or the initial implementation of the algorithm is incorrect. 

This rewrite will attempt to:
- Avoid repeats of invariants in the output
- Utilize a "single exponent list" to determine if we don't need to add a pure power
- Hopefully optimize the algorithm
- Use clearer variable names

Now, I will begin rewriting the genseeds algorithm. 

## Rewriting Genseeds
Our Genseeds output has three inputs:
- $R$, the ring we are acting on
- $W$ the full rank $n\times m$ weight matrix representing the group action $(n\ge m)$. 
- $Z$, the dimension of the $p$-group
*Note that this will be represented as one DiagonalAction object, D*
And one output:
- $L$ - A list of the seed invariants in exponent-vector form. 

Thus, we begin rewriting the algorithm.`genseeds(D) -> L`
#### Steps of the Genseeds Algorithm
1. First, we establish our function definition.
```
genseeds := D -> (

)
```
2. Next, we turn`D` into each of our inputs, and find our m & n
```
W := D.weights_1;
R := ring D
Z := (D.cyclicFactors)#0

m := numRows W; n := numColumns W; 
```
3. Next, we find our non-zero determinant submatrix:
```
	nonZeroSM := matrix{{0}};           	
	colList = {};                       	
	for i to (n - m - 1) do (             
		candidateSM := submatrix(W, toList(i .. i+m));
		if (determinant candidateSM != 0) then (
			nonZeroSM = candidateSM;    
			colList = toList(0 .. i-1) | toList(i+m .. n-m-1);
			break;                      
		)
	);
```
4. If we run into an issue finding a non-zero determinent, we print an error message
```
if (nonZeroSM == matrix{{0}}) then (
	error ("Non-zero submatrix of this weight matrix could not be found.\n");
	return {};
);
```
5. Now, here we find the plucker determinant from our matrix:
```
seedList := {};
for v in colList do (
	seedInvariant       := {}; 
	seedMatrix      := nonZeroSM | W_v;
	signFlip        := 1;
	for i to n do (
		plückerMatrix   := submatrix(seedMatrix, toList(0 .. i -1) | toList (i + 1 .. m));
		e               := for j from 0 to n-1 list (if j == i then 1 else 0);   
		seedInvariant   = seedInvariant | {signFlip * determinant(plückerMatrix) * e}; 
		signFlip        = signFlip * -1;
	);
	seedList = seedList | {sum seedInvariant}
);
```
Although the above lines are a little messy, they do the trick. 
At the end of this, the seeds stored in `seedList` are our generating seeds. 

#### Now here comes the hard part: seed expansion. 
### Rewriting Seed Expansion
I'm going to need you to check the theory on this, because I'm not sure whether what I'm doing is working, and it's too hard for my brain to take, but I tried my best. 

We have three primary lists to keep track of here:
```
seedList - holds all our seeds
trashList - gives us a way to check against bunk seeds we don't need anymore
purePowers - holds the lowest instance of a pure power we were able to find
```
Now i'm a little skeptical of the purePower method we talked about. Correct me if I'm wrong, but let's say I have a pure powers:
$$x^5$$
and we're in$\mod 6$. 
Thus, although we have some pure powers here, you can't put $x^5$ to any power to get $x^6$? But then I'm also thinking that if we reduce $(x^5)^2=x^{10}\to x^4$ . And then $(x^4)^2=x^8\to x^2$, which does mod out $x^6$. Maybe I just answered by own question, as the expansion algorithm should eventually get us to $x^2$ there. 

Anyways, we will have a total of three `for` loops here. 
```
for s when s < #seedList
	for k to #seedList - 1
		for p from 1 to (Z-1)
```
Now, the first loop with `s` will get all of our seed invariants in the list
Then the second loop with `k` will allow us to mash our seeds together
The third loop is what power we take the seeds to (Up to Z-1).

Then, we define a `startingSeed` (which matches with the `s` loop).
Next, we define a `candidateSeed` to start taking powers of. 
We take powers via the following formulas:
```
candidateSeed := (seedList#k) * p; -- Put our seed to the power of p.
candidateSeed = (startingSeed + candidateSeed) % Z;
```
This preps our candidateSeed for being checked for minimality. 

Then , we run our `candidateSeed` through the following for loop:
```
if (not all(candidateSeed, i -> i == 0) and not any(trashList, t -> (candidateSeed == t)))
```
The first part just says "If `candidateSeed` is non-zero". 
The second part says "If `candidateSeed` is not already in the `trashList`"

Great. Now we can start testing for minimality and reduce it in *fancy* ways. 
Yet the next two lines may be confusing:
```
minimality := seedminimal(seedList, candidateSeed, 0);
result := minimality#0;
```
`seedminimal` is a function that checks whether our `candidateSeed` is truly minimal or not. 
Here's a quick rundown of the inputs and outputs of `seedminimal`.

#### seedminimal
**Inputs**:
- `Seeds`: List -> A list of all the seeds that are currently minimal
- `candidate`: List -> An exponent vector representing our `candidateSeed`
- `startingIndex`: ZZ -> The index at which we want to start iterating through our Seeds list (the importance of this will be understood later)
**Outputs**:
The output of `seedminimal`, although just a List, can be broken down into two components:
- Indexes: {0, 1} -> *The information outputs*
- Indexes: {2, gens R} -> *The seed outputs*

Because of the way we are checking for minimality, we can run into four possible scenarios:
1. The `candidateSeed` is minimal! (Hooray)
2. The `candidateSeed` is not minimal! (Not Hooray!)
3. The `candidateSeed` makes one of our original seeds not minimal! (Woa, crazy)
4. The `candidateSeed` can help us reduce one of our original seeds into smaller exponents. (This is the theory I'm not sure that I can do, but it's implemented right now)

Now, because of each of these possibilities, we need a way to let our original function know what it needs to do. In scenarios 1, 3, & 4, we need to change our original `seedList` in different ways. Thus, we have four different ways to structure our outputs, given the **Information Outputs** and **Seed Outputs** specified above. Here's how the outputs work:

1. {-1, 0, `candidateSeed`} : Our `candidateSeed` is minimal, and properly reduced, so we can append it to the end of `seedList`
2. {-2, 0}                             : Our candidate seed is not minimal, so we do nothing to `seedList`
3. {-3, index}‡                    : One of our original seeds is no longer minimal given our `candidateSeed`, so we must remove it at the index specified in `seedList.
4. {-4, index, `newSeed`}‡ : We were able to reduce one of our original seeds in `seedList` with our `candidateSeed`, so that seed must be updated in the original `seedList`

‡: However, note that in scenarios 3 & 4, we still have not checked if our `candidateSeed` is fully minimal against all the other seeds. Additionally, it may have the potential to reduce other seeds in `seedList`. Thus, if we run into scenario 3 & 4, we must call `seedminimal` again at the index specified. 

Thus, this is why we have three inputs for seedMinimal:
```
seedMinimal := (Seeds, candidate, startingIndex)
```
This allows us to start at the index so we don't need to go through the entirety of `seedList`

### Back to the main function
So, now that we have a way to check for minimality and dynamically update seeds as they are minimized, we can now understand what the fuck is happening deep into these `for` loops.

Let us move back to our code again:
```
minimality := seedMinimal(seedList, candidateSeed, 0);
result := minimality#0;
```
So, now that you have read about `seedMinimal`, you should hopefully understand that `minimality` will store both the **information outputs** in indexes 0 and 1, and the **seed** in the remaining indexes. 

Thus, it follows that `result` tells us whether we are in scenario 1, 2, 3, or 4. 

Now we move on:
```
while (result == -3 or result == -4) do
```
Remember that with scenarios 3 or 4,  there's something not-minimal with our seeds in `seedList`, so we must update them.
```
while (result == -3 or result == -4) do
	editIndex := minimality#2;
```
The `editIndex` tells us which seed is the problem seed. 

Now, consider scenario 3, where the seed is not minimal:
```
if (result == -3) then (
	seedList = take(seedList, editIndex) | drop(seedList, editIndex+1);
)
```
This just removes it from the list. 

Now with scenario 4, things get a little more complicated.
This will require a little exposition with the `drop` function. `drop` has two inputs:
- L -> A List
- n -> ZZ
Drop takes this list L, and removes the first $n$ elements of that list. So with the list:
$$L=\{0,3,3,3,2,1\}$$
`L= drop(L,3)` gives us:
$$L = \{3,2,1\}$$

Now, let's get to the code:
```
else if (result == -4) then ( 
	newSeed := drop(minimality, 2);
	seedList = replace(editIndex, newSeed, seedList); 
	if (count(newSeed, e -> e != 0) == 1) then (  
		powerIndex = position(newSeed, e -> e != 0);
		purePowers = replace(powerIndex, newSeed#powerIndex, purePowers);
	);
);
```
`newSeed := drop(minimality, 2);` -> This just gives us the **seed output** portion from `seedMinimal`.

then, the next line: `seedList = replace(editIndex, newSeed, seedList); ` just replaces the non-minimal seed with the new one. Now here's where it gets weird. 

If you remember our conversation over the phone, we planned on making a power list and checking it whenever we added a seed, and that's what we're doing. Essentially, what these lines are saying:
```
MACAULAY2:
if (count(newSeed, e -> e != 0) == 1) then (  
		powerIndex = position(newSeed, e -> e != 0);
		purePowers = replace(powerIndex, newSeed#powerIndex, purePowers);
);
pseudocode:
if (There is a pure power in this seed) then 
	find the index it is pure power of.
	now update our purePowers with the index specified at powerIndex
	
```

great i hope you're still holding on. 

if you remember within this while loop, we've said:
```
while (result == 3 or 4)
	if result is 3
		remove that seed from seedList
	if result is 4
		update the seed with the minimized version
		check for pure powers and add to the list if it is a pure power
```

Now, at the end of this while loop, we must say yet again:
```
minimality := seedMinimal(seedList, candidateSeed, 0);
result := minimality#0;
```
This lets us to keep checking to see if our `candidateSeed` truly is minimal, cause we still haven't done that.

#### Exiting the while loop
Now that we've exited the while loop, we have the following code:
```
if (result == -1) then (	 
	newCandSeed := drop(minimality, 2);
	if (count(newCandSeed, e -> e != 0) == 1) then (  
		powerIndex = position(newCandSeed, e -> e != 0);
		purePowers = replace(powerIndex, newCandSeed#powerIndex, purePowers);
	);
	seedList = seedList | newCandSeed;
);
```
This essentially performs the **exact same processes as Scenario 4**, except we append our `candidateSeed` to the end of `seedList` rather than replacing an existing seed. 

Then, finally we have the line:
```
trashList = trashList | {candidateSeed};
```
Which just adds the seed to the trashList so we can check against it later. 

### Boiler-Plate code at the end of the function

This code adds the pure powers if they are minimal (checking against PurePowers)
```
for i from 0 to (#ringVars - 1) do (
	if (Z % (purePowers#i) != 0 ) then (
		seedList = seedList | {for k to (#ringVars - 1) list (if i == k then d else 0)};
	);
);
```

This code converts our exponent vectors into `PolynomialRing` elements:
```
polyList := {};
for i in seedList do (
	n := 1;
	for j to #i - 1 do (n = n * (((gens R)#j)^(i#j)));
	polyList = polyList | {n};
);

```

And then we're done:
```
return polyList;
```

## Caveats
I have not had the time to test this code yet, so that will hopefully come tomorrow/over the weekend maybe maybe not i don't know.

Timestamp: Start 1:46:21 PM - End 4:35:45 PM