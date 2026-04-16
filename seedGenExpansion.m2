-------------------------------------------

-------------------------------------------
--- Elementary Invariants Methods ---------
-------------------------------------------

-->-- Function: seedMinimal --<--
-- Checks if a given candidate is minimal given the list of seeds, starting at the index, "StartingIndex"
-- Returns ({-1} | candidate) if our candidate is minimal.
-- Returns {-2} if our candidate is not minimal.
-- Returns ({-3, index}) if a seed is not minimal so we can remove it
-- Returns ({-4, index} | newSeed) if our candidate helps reduce a seed. 
seedMinimal := (Seeds, candidate, startingIndex) -> (
	i := startingIndex;
	numSeeds := #Seeds;
	print("seed minimal");
	print(candidate);
	print("num seeds");
	print(#Seeds);
	print ("start index");
	print(startingIndex);
	while i < numSeeds do (	-- Iterate through all seeds
		candMinimal := true;	-- We start by assuming our candidate & seed are divisible by each other
		seedIsMinimal := true;

		for k from 0 to #candidate - 1 do (
			if (candidate#k > Seeds#i#k) then (
				candMinimal = false; -- If our candidate ever has a greater power than the seed, its not minimal
			)
			else if (Seeds#i#k > candidate#k) then (
				seedIsMinimal = false; -- If our seed ever has a greater power than the candidate, our candidate is safe (for now)
			);
		);
		if seedIsMinimal then (		-- If our seed is exclusively less than our candidate, we:
			newCandidate := candidate - Seeds#i; -- Reduce our candidate by our seed, as that will still be invariant
			if (newCandidate === candidate) then (
				i = i + 1;				-- No change → move forward to avoid infinite loop
			)
			else (
				candidate = newCandidate;
				if (all (candidate, i -> i == 0)) then return {-2, 0}; -- If the candidate fully reduces, we return -2.
				i = startingIndex;		-- Reduce our index by restarting so we can test candidate again. 
			);
		)
		else if candMinimal then (	-- If our candidate is minimal, we may need to discard our seed instead.
			removalSeed := Seeds#i;
			while (all(removalSeed - candidate, i -> i >= 0) and removalSeed =!= removalSeed - candidate) do (
				removalSeed = removalSeed - candidate;
			);
			if (all (removalSeed, i -> i == 0)) then return {-3, i}; -- If the seed fully reduces, we return -3
			return {-4, i} | removalSeed;						  -- Otherwise, we return -3, the index of the seed, and the updated seed.
		)
		else (
			i = i + 1;	-- Normal case: move forward
		);
	);
	return {-1, 0} | candidate ;
)

-->--elementaryInvariants function--<--
--> INPUT:  D (a diagonalAction)
--> OUTPUT: L (a list of invariants)
genseeds = method()
genseeds(DiagonalAction) := (D) -> (
	---------------------
	-- Seed Generation --
	---------------------

	-->- Grab our variables W, R, Z from D -<--
	W := D.weights_1;
	R := ring D;
	Z := (D.cyclicFactors)#0;

	-->- Find our m and n from the weight matrix -<--
	n := numColumns W; m := numRows W;

	-->- STEP 1 -<--
	-->- Now, we find a n x n submatrix of W with nonzero determinant --<-
	nonZeroSM := matrix{{0}};           -- Start with an empty submatrix (SM stands for submatrix)
	colList = {};                       -- This empty list will track the columns we don't use for the submatrix
	for i from 0 to (n - m - 1) do (                 -- Iterate from 0 to n - m (we don't want our matrix out of bounds)
		candidateSM := submatrix(W, toList(i .. i+m-1));
		if (determinant candidateSM != 0) then (
			nonZeroSM = candidateSM;    -- If candidateSM has nonzero determinant, it is now our nonZero det submatrix
			colList = toList(0 .. i-1) | toList(i+m .. n-m-1); -- Grabs the columns we didn't use. 
			break;                      -- ends the loop
		)
	);

	-->- Return error if this submatrix doesn't exist --<--
	if (nonZeroSM == matrix{{0}}) then (
		error ("Non-zero submatrix of this weight matrix could not be found.\n");
		return {};
	);

	-->- STEP 2 -<--
	seedList := {};		                     	-- Creates a list for the seed invariants in exponent vec form
	for v in colList do (                   	-- Iterates through all columns we didn't use for nonZeroSM
		seedInvariant       := {};              -- Current seed invariant we are calculating
		seedMatrix      := nonZeroSM | matrix(W_v);		-- Matrix we extract the seed invariant from (where W_v is our additional vector)
		signFlip        := 1;
		for i from 0 to m do (                 -- This loops lets us remove one of the columns from the matrix to calculate the plücker
			plückerMatrix   := submatrix(seedMatrix, toList(0 .. i -1) | toList (i + 1 .. m));  -- Find plucker matrix
			e               := for j from 0 to n-1 list (if j == i then 1 else 0);              -- Standard basis vector
			seedInvariant   = seedInvariant | {signFlip * determinant(plückerMatrix) * e};      -- Calculate vector
			signFlip        = signFlip * -1;     -- Flip the sign after each iteration.
		);
		seedList = seedList | {sum seedInvariant} -- Adds the summed seed invariant vec to our list
	);

	-- Now, seedList contains our list of seed Invariants, so we move onto expansion.

	--------------------
	-- Seed Expansion --
	--------------------
	ringVars    := gens R;            -- So we don't need to call "gens" each time we need the variables of the ring
	seedList    = for l in seedList list apply(l, x -> ((x % Z) + Z) % Z); -- Mods our seeds out by Z
	trashList   := {0} | seedList;    -- List to keep track of duplicate invariants
	purePowers := apply(#ringVars, i -> 0);	-- List to keep track of pure powers. 

	--> Starting with seed expansion <--
	-- Note that the "drop" function is used in combination with the seedminimal function in this loop.
	-- This is because seed minimal appends a "result" and "index" value to the begining of a seed.
	-- Thus by saying drop(candidate, 2), we get rid of those information values. 
	for s when s < #seedList do (		-- We use a "when" loop here because size of newList will change
		startingSeed := seedList#s;
		for k to #seedList - 1 do (		-- We can use a static loop here because we won't add any elements in here. 
			for p from 1 to (Z - 1) do (
				candidateSeed := (seedList#k) * p;					-- Put our seed to the power of p.
				candidateSeed = (startingSeed + candidateSeed) % Z;	-- Multiply two seeds & mod out by Z.
				if (not all(candidateSeed, i -> i == 0) and not any(trashList, t -> (candidateSeed == {t}))) then (
					minimality := seedMinimal(seedList, candidateSeed, 0);
					result := minimality#0;
					-- If result = -3 or -4, that means one of our seeds was not minimal given our candidate
					while (result == -3 or result == -4) do (		-- So we must loop to sort out the seeds and get our candidate & seeds minimized
						print(minimality);
						editIndex := minimality#1;					-- minimality#2 holds the index of the seed we need to adjust.
						if (result == -3) then (					-- {-3} -> Our seed is not minimal, so we must remove it.
							seedList = take(seedList, editIndex) | drop(seedList, editIndex+1);
						)
						else if (result == -4) then (				-- {-4} -> We found a reduction for our seed, so we must replace the old one. 
							newSeed := drop(minimality, 2);
							seedList = replace(editIndex, newSeed, seedList); -- Replace our old seed with the new one.
							if (number(newSeed, e -> e != 0) == 1) then ( -- Check if our seed is a pure power of some kind. 
								powerIndex = position(newSeed, e -> e != 0);
								purePowers = replace(powerIndex, newSeed#powerIndex, purePowers);
							);
							
						);
						--> Then we call our seedMinimal function again, this time starting from the editIndex to save time.
						minimality = seedMinimal(seedList, candidateSeed, editIndex+1);
						result = minimality#0;
					);
					
					if (result == -1) then (	-- If our candidate is minimal, we add it to the seed list. 
						newCandSeed := drop(minimality, 2);
						candidateSeed = newCandSeed;
						if (number(newCandSeed, e -> e != 0) == 1) then ( -- check if seed is pure power of some kind
							powerIndex = position(newCandSeed, e -> e != 0);
							if (powerIndex =!= null and powerIndex < #purePowers) then (
								purePowers = replace(powerIndex, newCandSeed#powerIndex, purePowers);
							);
						);
						seedList = append(seedList, newCandSeed);	-- Add our seed to the list. 
					);
					-- If our result is -2, we do nothing because our candidate is bunk.
				);
				trashList = append(trashList, candidateSeed)  -- Always add our candidate to the trashList for efficiency.
			);
		);
	);

	--> Then we add the pure powers to the list, checking if they are minimal via. our purePowers list.
	for i from 0 to (#ringVars - 1) do (
		if (Z % (purePowers#i) != 0 ) then (
			seedList = seedList | {for k to (#ringVars - 1) list (if i == k then Z else 0)};
		);
	);

	-->-- Now, we turn each of the exponent vectors into their polynomials in the ring. --<--
	polyList := {};
	for i in seedList do (
		n := 1;
		for j to #i - 1 do (n = n * (((ringVars)#j)^(i#j)));
		polyList = polyList | {n};
	);
	
	return polyList; -- Return our list
)