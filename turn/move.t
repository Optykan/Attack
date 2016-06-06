
% returns if any team has no units
% returns 0 if both have units
% 1 if the player has none
% and 2 if the AI has none
fcn noUnits(team:int) : boolean
    var hasUnits := false
    for i : 1 .. 25
	if getAlliance (i) = team then
	    for j : 1 .. 4
		if getUnits(team, i, j) > 0 then
		    result false
		end if
	    end for
	end if
    end for
    result true
end noUnits

% returns the percentage chance of accepting an EP offer
fcn chance (ep : int) : real
    var chanceNum := 100 * (-2 ** (-0.2 * (ep - (globalView / 4)))) + 100
    if chanceNum < 0 then
	result 0
    end if
    result chanceNum
end chance

fcn aiChance : boolean
    %the ai can only have a maximum of ~90% chance
    % returns if the regions has accepted the AI offer
    var aiChanceRNG := Rand.Int (1, 35)
    var aiChanceEqu := 100 - (2 ** (-0.1 * (aiChanceRNG - 66.44)))
    if aiChanceRNG < aiChanceEqu then
	result true
    end if
    result false
end aiChance

fcn offer (ep : int) : boolean
    var weight : int

    % a high globalView is bad
    % a low global view is good
    % ep > 20 guarantees a victory
    % reject second add 3 to globalView

    if ep >= globalView then
	% 60% chance to lower the global view by 2
	% 10% chance to lower it by 3
	% 100% chance to lower it by at least 1
	var a := Rand.Int (1, 10)
	if a > 4 then
	    globalView -= 2
	elsif a = 2 then
	    globalView -= 3
	else
	    globalView -= 1
	end if
	if globalView < 1 then
	    globalView := 1
	end if
	result true
    end if

    var p := chance (ep)
    % generates probability based on a logarithmic function that cuts off
    % probability decreases the higher the globalView
    % below values based on a globalView of 20, x% @ ep
    % 83% @ 20
    % 74% @ 15
    % 60% @ 10
    % 42% @ 6
    % 36% @ 5
    %  8% @ 1

    %generate rand from 1-100, if  rand < p then success
    var r := Rand.Int (1, 100)

    % 60% change to lower globalview by 1
    % 10% chance to lower globalview by 2
    if r < p then
	var a := Rand.Int (1, 10)
	if a > 4 then
	    globalView -= 1
	elsif a = 2 then
	    globalView -= 2
	end if
	if globalView < 1 then
	    globalView := 1
	end if

	result true
    end if
    result false
end offer

fcn battleChance : int
    %this function should return the unit ID that is to be eliminated
    var battleChanceRNG := Rand.Int (1, 6)
    if battleChanceRNG = 1 or battleChanceRNG = 2 then
	result 1
    elsif battleChanceRNG = 3 then
	result 2
    elsif battleChanceRNG = 4 then
	result 3
    elsif battleChanceRNG = 5 or battleChanceRNG = 6 then
	result 4
    end if
    assert (battleChanceRNG not= 0)
end battleChance

% returns true when one team's array is zero
fcn isZero (checkArray : array 1 .. 4 of int) : boolean

    if checkArray (1) + checkArray (2) + checkArray (3) + checkArray (4) = 0 then
	result true
    end if
    result false
end isZero

proc displayResults (chkFrom : array 1 .. 4 of int, chkDest : array 1 .. 4 of int, allyUnits : array 1 .. 4 of int, destUnits : array 1 .. 4 of int, from, dest : int)
    Window.Select (inspectWin)
    cls
    color (black)
    put toName (from) + " is attacking ", toName (dest)
    put "--------- RESULTS ---------"
    put toName (from), " losses:"
    put "Infantry: " ..
    color (brightred)
    put "-", chkFrom (1) ..
    color (black)
    put " ", allyUnits (1), " remain."
    put "Tanks   : " ..
    color (brightred)
    put "-", chkFrom (2) ..
    color (black)
    put " ", allyUnits (2), " remain."
    put "Air     : " ..
    color (brightred)
    put "-", chkFrom (3) ..
    color (black)
    put " ", allyUnits (3), " remain."
    put "Naval   : " ..
    color (brightred)
    put "-", chkFrom (4) ..
    color (black)
    put " ", allyUnits (4), " remain."
    put "\n"
    put toName (dest), " losses:"
    put "Infantry: " ..
    color (brightred)
    put "-", chkDest (1) ..
    color (black)
    put " ", destUnits (1), " remain."
    put "Tanks   : " ..
    color (brightred)
    put "-", chkDest (2) ..
    color (black)
    put " ", destUnits (2), " remain."
    put "Air     : " ..
    color (brightred)
    put "-", chkDest (3) ..
    color (black)
    put " ", destUnits (3), " remain."
    put "Naval   : " ..
    color (brightred)
    put "-", chkDest (4) ..
    color (black)
    put " ", destUnits (4), " remain."
    Input.Flush

end displayResults

% PROCESSES ALL BATTLE STUFF
fcn battleComputer (from, dest : int) : boolean
    var allyUnits : array 1 .. 4 of int := getAllUnits (getAlliance (from), dest)
    var destUnits := getAllUnits (getAlliance (dest), dest)

    var relative : string := toName (from)
    var relativeEnemy : string := toName (dest)


    %ally and enemy is RELATIVE to the current turn (if it is the AI turn, then ally is set to enemy)
    var eliminated : int

    var battleComputerString := ""

    var destCheck : array 1 .. 4 of int
    var allyCheck : array 1 .. 4 of int

    var allyRollCounter : int
    var enemyRollCounter : int

    loop

	%reset in case of loop
	for i : 1 .. 4
	    destCheck (i) := 0
	    allyCheck (i) := 0
	end for

	allyRollCounter := 0
	enemyRollCounter := 0

	%exit here in case someone is invading a region with 0 units
	exit when isZero (allyUnits) or isZero (destUnits)

	%calculate allied rolls
	for i : 1 .. 4
	    if i = 2 and allyUnits (2) > 0 then
		allyRollCounter += 2 * allyUnits (2)
	    else
		allyRollCounter += allyUnits (i)
	    end if
	end for

	%calculate enemy rolls
	for i : 1 .. 4
	    if i = 2 and destUnits (2) > 0 then
		enemyRollCounter += 2 * destUnits (2)
	    else
		enemyRollCounter += destUnits (i)
	    end if
	end for

	%loop through allied rolls
	for i : 1 .. allyRollCounter
	    eliminated := battleChance
	    if destUnits (eliminated) > 0 then
		destUnits (eliminated) -= 1
		destCheck (eliminated) += 1
	    end if
	end for

	%loop through enemy rolls
	for i : 1 .. enemyRollCounter
	    eliminated := battleChance
	    if allyUnits (eliminated) > 0 then
		allyUnits (eliminated) -= 1
		allyCheck (eliminated) += 1
	    end if
	end for

	%check all the totals of allied eliminated
	for i : 1 .. 4
	    eliminated := allyCheck (i)
	    if eliminated > 0 then
		battleComputerString := relativeEnemy + " destroyed " + intstr (eliminated) + " " + getUnitName (i) + " units."
		info (battleComputerString)
	    end if
	end for

	%check all the totals of enemy eliminated
	for i : 1 .. 4
	    eliminated := destCheck (i)
	    if eliminated > 0 then
		battleComputerString := relative + " destroyed " + intstr (eliminated) + " " + getUnitName (i) + " units."
		info (battleComputerString)
	    end if
	end for

	if getAlliance (from) = 1 or (getAlliance (from) = 2 and getAlliance (dest) = 1) then
	    Window.Select (inspectWin)
	    color (brightred)
	    locate (maxrow - 5, 1)
	    % display the results and subtract the units
	    displayResults (allyCheck, destCheck, allyUnits, destUnits, from, dest)
	    removeUnits (getAlliance (from), dest, allyCheck (1), allyCheck (2), allyCheck (3), allyCheck (4))
	    removeUnits (getAlliance (dest), dest, destCheck (1), destCheck (2), destCheck (3), destCheck (4))

	    if allyCheck (1) + allyCheck (2) + allyCheck (3) + allyCheck (4) = 0 then
		put "No ", toName (from), " units destroyed"
	    end if
	    if destCheck (1) + destCheck (2) + destCheck (3) + destCheck (4) = 0 then
		put "No ", toName (dest), " units destroyed"
	    end if
	    put "\nPress any key to continue..."
	    color (black)
	    Input.Flush
	    loop
		exit when hasch
	    end loop

	end if

    end loop

    %which team lost all the units

    if isZero (destUnits) then
	if getAlliance (from) = 1 then
	    % if the player defeated the region add a random number of EP to balance
	    var epGained := Rand.Int (1, 10)
	    info ("Gained " + intstr (epGained) + " economic points.")
	    economicPoints += epGained
	end if
	setAlly (dest, getAlliance (from))
	iht (dest)
	% results true on victory
	result true
    else
	%results false on defeat
	result false
    end if

    %program shouldnt get here
    assert (false)
    result true
end battleComputer

% shows battle information on the info window
proc battle (from, dest : int, toMoveUnits : array 1 .. 4 of int)
    var battleAlliance := getAlliance (dest)
    Window.Select (inspectWin)
    cls
    put "--------- TRANSFERRING UNITS ---------"
    put "        Units engaged in battle       "
    put "Source      : ", toName (from)
    put "Destination : ", toName (dest)
    put ""
    put "Infantry    : ", toMoveUnits (1)
    put "Tanks       : ", toMoveUnits (2)
    put "Air         : ", toMoveUnits (3)
    put "Naval       : ", toMoveUnits (4)
    put "\n"

    put "---------  DESTINATION INFO  ---------"
    put "        Units engaged in battle       "
    put "Name     : ", toName (dest)
    put "Alliance : ", inspectAlliance (dest)
    put "Country  : ", countryName (dest)
    put ""
    put "Infantry : ", getUnits (battleAlliance, dest, 1)
    put "Tanks    : ", getUnits (battleAlliance, dest, 2)
    put "Air      : ", getUnits (battleAlliance, dest, 3)
    put "Naval    : ", getUnits (battleAlliance, dest, 4)
    put "\n"
    color (brightred)
    put "---------      ACTION      ---------"
    put "Press any key to continue to battle "
    Input.Flush
    loop
	exit when hasch
    end loop

    color (black)
    if battleComputer (from, dest) then
	Window.Select (inspectWin)
	cls
	color (brightgreen)
	put toName (from), " won the battle."
	color (black)
    else
	Window.Select (inspectWin)
	cls
	color (brightred)
	put toName (dest), " won the battle."
	color (black)
    end if


end battle

% this procedure handles the player negotiation info
proc negotiate (from, dest : int, toMoveUnits : array 1 .. 4 of int)
    var negotiateAttempts := 1
    var negotiateAlliance := getAlliance (dest)
    var negotiateEP := ""
    var negotiateGetch : string (1)
    for i : 1 .. 2
	Window.Select (inspectWin)
	cls
	put "--------- NEGOTIATION INFO ---------"
	put "Economic Points (EP): ", economicPoints
	put "Offering ", floor (economicPoints / 2), " EP : " ..
	put round (chance (floor (economicPoints / 2))), " % success."
	put "\n"
	put "--------- DESTINATION INFO ---------"
	put "Name     : ", toName (dest)
	put "Alliance : ", inspectAlliance (dest)
	put "Country  : ", countryName (dest)
	put ""
	put "Infantry : ", getUnits (negotiateAlliance, dest, 1)
	put "Tanks    : ", getUnits (negotiateAlliance, dest, 2)
	put "Air      : ", getUnits (negotiateAlliance, dest, 3)
	put "Naval    : ", getUnits (negotiateAlliance, dest, 4)
	put "\n"
	color (brightred)
	put "---------      ACTION      ---------"
	color (black)
	put "Enter the amount of EP to offer: " ..
	loop
	    loop
		locate (18, 34)
		put "                                                     " ..
		locate (18, 34)
		get negotiateEP
		%get user input until it's a valid input
		exit when strintok (negotiateEP)
	    end loop
	    exit when strint (negotiateEP) <= economicPoints and strint (negotiateEP) >= 0
	end loop

	if strint (negotiateEP) = 0 then
	    % if user is offering 0 EP assume battle
	    negotiateAttempts := 10
	    exit
	elsif offer (strint (negotiateEP)) then
	    % offer was accepted, subtract offer from total
	    economicPoints -= strint (negotiateEP)
	    Window.Select (inspectWin)
	    put "\n\n"
	    color (brightgreen)
	    put "Offer accepted."
	    color (black)
	    put "Press any key to continue..."
	    Input.Flush
	    loop
		exit when hasch
	    end loop
	    exit
	else
	    %offer was rejected, subtract offer and try again
	    economicPoints -= strint (negotiateEP)
	    negotiateAttempts += 1
	    Window.Select (inspectWin)
	    put "\n\n"
	    color (brightred)
	    put "Offer rejected."
	    color (black)
	    put "Press any key to continue..."
	    Input.Flush
	    loop
		exit when hasch
	    end loop
	end if
    end for

    % negotiation attempts greater than 2 then go to battle
    if negotiateAttempts > 2 then
	Window.Select (inspectWin)
	put "\n\n"
	color (brightred)
	put "Offer rejected."
	color (black)
	put "Press any key to continue to battle..."
	Input.Flush
	loop
	    exit when hasch
	end loop
	var a := Rand.Int (1, 10)
	if a > 6 then
	    globalView += 2
	elsif a = 6 then
	    globalView += 3
	else
	    globalView += 1
	end if
	battle (from, dest, toMoveUnits)
    else
	% otherwise assume exit from sucess
	Window.Select (inspectWin)
	cls
	color (brightgreen)
	put "--------- SUCCESS ---------"
	color (black)
	put "Infantry : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 1)
	color (black)
	put "Tanks    : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 2)
	color (black)
	put "Air      : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 3)
	color (black)
	put "Naval    : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 4)
	color (black)
	transferUnits (0, 1, dest)
	setAlly (dest, 1)
	Window.Select (inspectWin)
	put "\n\n"
	color (brightred)
	put "Inspect turn begin. Select a region to continue."
	color (black)

    end if
end negotiate

% handles the moving from region to region
% calls upon the battle computer or negotiate when required
proc move (from, dest : int, toMoveUnits : array 1 .. 4 of int)
    if dest > 20 and getAlliance (dest) = 0 and getAlliance (from) not= 2 then
	% if the destination is an ocean, and the ocean is neutral, and the player taking is not the ai
	Window.Select (inspectWin)
	cls
	color (brightgreen)
	put "--------- SUCCESS ---------"
	color (black)
	put "Infantry : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 1)
	color (black)
	put "Tanks    : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 2)
	color (black)
	put "Air      : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 3)
	color (black)
	put "Naval    : " ..
	color (brightgreen)
	put "+", getUnits (0, dest, 4)
	color (black)
	transferUnits (0, 1, dest)
	setAlly (dest, 1)
	Window.Select (inspectWin)
	put "\n\n"
	color (brightred)
	put "Inspect turn begin. Select a region to continue."
	color (black)

    elsif getAlliance (from) = 2 then
	%the user that is moving is the AI
	if getAlliance (dest) = 0 then
	    % random chance for the AI to claim the region (close to the user chance, but with no global view)
	    if aiChance then
		% the AI won the chance, claim the region
		% if the target is sea then the ai shouldn't be moving land units anyways
		% if the target is land then the ai shouldnt be moving naval units

		transferUnits (0, 2, dest)
		setAlly (dest, 2)
		ipt (dest)
	    else
		if battleComputer (from, dest) then
		    %computer won the fight
		    %set as ally, display hostile takeover
		    setAlly (dest, 2)
		    iht (dest)

		    %don't handle the else if case because nothing happens if they lose
		end if
	    end if
	elsif getAlliance (dest) = 1 then
	    battle (from, dest, toMoveUnits)

	elsif getAlliance (dest) = 2 then

	    % simply move from region to region
	    % already handled by ai.t

	end if


    elsif getAlliance (dest) = 0 then
	% region is neutral, go to negotiations
	negotiate (from, dest, toMoveUnits)

    elsif getAlliance (dest) = getAlliance (from) then
	%both regions have the same alliance, just move them (handled by parent)
	%do nothing

    elsif getAlliance (dest) not= getAlliance (from) then
	assert getAlliance (dest) not= 0 and getAlliance (from) not= 0
	battle (from, dest, toMoveUnits)
    else
	%hey you're not supposed to be here
	battle (from, dest, toMoveUnits)
    end if
end move

% requests the number of units the player wishes to move
fcn moveInfo (team, from, dest : int) : array 1 .. 4 of int

    var moveInfoTemp : array 1 .. 4 of int
    var moveInfoEnterTemp : string
    Window.Select (inspectWin)
    Window.SetActive (inspectWin)
    cls
    put "---------    FROM  INFO    ---------"
    put "Name     : ", toName (from)
    put "Alliance : ", inspectAlliance (from)
    put "Country  : ", countryName (from)
    put ""
    put "Infantry : ", getUnits (team, from, 1)
    put "Tanks    : ", getUnits (team, from, 2)
    put "Air      : ", getUnits (team, from, 3)
    put "Naval    : ", getUnits (team, from, 4)

    put "\n\n"

    put "--------- DESTINATION INFO ---------"
    put "Name     : ", toName (dest)
    put "Alliance : ", inspectAlliance (dest)
    put "Country  : ", countryName (dest)
    put ""

    var moveInfoCountryTemp := getAlliance (dest)
    put "Infantry : ", getUnits (moveInfoCountryTemp, dest, 1)
    put "Tanks    : ", getUnits (moveInfoCountryTemp, dest, 2)
    put "Air      : ", getUnits (moveInfoCountryTemp, dest, 3)
    put "Naval    : ", getUnits (moveInfoCountryTemp, dest, 4)

    put "\n\n"
    color (brightred)
    put "---------      ACTION      ---------"
    color (black)
    put "   Enter number of units to move.   "
    loop
	locate (27, 1)
	put "Infantry : " ..
	get moveInfoEnterTemp
	if strintok (moveInfoEnterTemp) then
	    moveInfoTemp (1) := strint (moveInfoEnterTemp)
	    exit
	end if
    end loop
    loop
	locate (28, 1)
	put "Tanks    : " ..
	get moveInfoEnterTemp
	if strintok (moveInfoEnterTemp) then
	    moveInfoTemp (2) := strint (moveInfoEnterTemp)
	    exit
	end if
    end loop
    loop
	locate (29, 1)
	put "Air      : " ..
	get moveInfoEnterTemp
	if strintok (moveInfoEnterTemp) then
	    moveInfoTemp (3) := strint (moveInfoEnterTemp)
	    exit
	end if
    end loop
    loop
	locate (30, 1)
	put "Naval    : " ..
	get moveInfoEnterTemp
	if strintok (moveInfoEnterTemp) then
	    moveInfoTemp (4) := strint (moveInfoEnterTemp)
	    exit
	end if
    end loop

    result moveInfoTemp
end moveInfo

% ensures that the player isn't attempting to move a boat onto land
fcn moveUnits (team, from, dest : int) : boolean
    % inf tank air nav
    var moveUnitsTemp : array 1 .. 4 of int := moveInfo (team, from, dest)
    var inf := moveUnitsTemp (1)
    var tank := moveUnitsTemp (2)
    var air := moveUnitsTemp (3)
    var nav := moveUnitsTemp (4)

    % the player is now allowed to move 0 units
    if inf + tank + air + nav = 0 then
	instruct ("Skipped turn due to moving 0 units.")
	result true
    end if
    if nav > 0 and dest < 21 then
	instruct ("Cannot move naval units to land.")
	result false
    end if
    if inf + tank > 0 and dest > 20 then
	% you can move land units to the water provided you have boats
	if getUnits (team, dest, 4) < 1 then
	    instruct ("Cannot move land units to water without naval units.")
	    result false
	end if
    end if
    if inf <= getUnits (team, from, 1) then
	if tank <= getUnits (team, from, 2) then
	    if air <= getUnits (team, from, 3) then
		if nav <= getUnits (team, from, 4) then

		    var moveUnitsTempStr := "Confirm move: " + intstr (inf) + " infantry, " + intstr (tank) + " tanks, " + intstr (air) + " air, and " + intstr (nav) + " naval units (Y/N): "
		    if confirm (moveUnitsTempStr) then
			removeUnits (team, from, inf, tank, air, nav)
			addUnits (team, dest, inf, tank, air, nav)
			move (from, dest, moveUnitsTemp)
			result true
		    else
			result false
		    end if
		else
		    instruct ("Insufficient naval units.")
		    result false
		end if
	    else
		instruct ("Insufficient air units.")
		result false
	    end if
	else
	    instruct ("Insufficient tank units.")
	    result false
	end if
    else
	instruct ("Insufficient infantry units.")
	result false
    end if
    result false
end moveUnits
