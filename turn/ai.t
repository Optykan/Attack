% Alliance in the AI class means "allied with the AI"
var noGo : array 1 .. 25 of int := init (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
var noGoNext := 1

proc resetNoGo
    for i : 1 .. 25
	noGo (i) := 0
    end for
    noGoNext := 1

end resetNoGo

function isIn (a : int, arr : array 1 .. * of int) : int

    % a simple function to see if x is in y
    for i : 1 .. upper (arr)
	if a = arr(i) then
	    result i
	end if
    end for
    result 0
end isIn

function aiPath : array 1 .. 2 of int
    var path : array 1 .. 2 of int := init (0, 0)
    var from := 0
    var next := 1

    % temporarily store the id of the player's capital (this is the target)
    const playerCapital := getCapital (1)

    var alliedCounter := 0

    % check to see how many regions are allied with the AI
    % two loops to check how many are connected
    % then the second to see which ones are connected
    % we have doubled execution time because flexible arrays aren't allowed
    for i : 1 .. 25
	if getAlliance (i) = 2 then
	    alliedCounter += 1
	end if
    end for

    %declare the array of how many regions are allied

    var alliedRegions : array 1 .. alliedCounter of int

    for i : 1 .. 25
	if getAlliance (i) = 2 then
	    alliedRegions (next) := i
	    next += 1
	end if
    end for

    % assert that they're all allied
    for i : 1 .. upper (alliedRegions)
	assert (getAlliance (alliedRegions (i))) = 2
    end for

    % now we have an array containing all the allied regions
    % check to see all of the connections the player's capital has
    % if the player's capital is connected to one of the enemy regions then
    % ATTTAAACKKKK!
    % otherwise the ai will pick a region at random

    next := 1
    var fromCounter := 0
    var connectedCapital := false

    % do two loops here - one to check for the number of surrounding regions
    % and another to populate the resulting array with the surrounding region ID
    % we do this because flexible arrays are not allowed
    for i : 1 .. 25
	if connected (playerCapital, i) then
	    fromCounter += 1
	end if
    end for

    %populate the array we just created with the surrounding regions
    var connectedRegions : array 1 .. fromCounter of int

    for i : 1 .. 25
	% if the region we're looking at is connected to the player's capital...
	if connected (i, playerCapital) then
	    % make sure that we are allied
	    if getAlliance (i) = 2 then
		% if the region we're looking at is:
		% 1) connected to the capital and
		% 2) is allied with the AI then
		% ATTAAAACK!
		connectedCapital := true
		path (1) := i
		assert getAlliance (path (1)) = 2
		path (2) := playerCapital

		% result the region that is connected to the capital
		result path
	    end if

	    % and the region we're looking at is not allied with the enemy then
	    % continue populating the array of connections to the player capital
	    connectedRegions (next) := i
	    next += 1
	end if
    end for

    % at this points
    % the ai has no regions that are connected to the player's capital


    % now the AI will look for territories that are connected to the player's capital
    % if the ai owns a region connected to one of the adjacent regions to the capital
    % then take over that region

    var locIn : int

    for i : 1 .. upper (alliedRegions)
	% for as many allied regions as we have, test to see if they are adjacent to a region adjacent
	% to the player's capital

	path (1) := alliedRegions (i)
	assert getAlliance (path (1)) = 2

	for j : 1 .. upper (connectedRegions)
	    if connected (alliedRegions (i), connectedRegions (j)) and isIn (i, noGo) = 0 then
		% if the allied region we're testing is connected to an adjacent region
		% then go there

		path (2) := connectedRegions (j)
		result path
	    end if
	end for
    end for

    % if the code has continued to execute until this point
    % that is, the AI has no regions that are adjacent to the capital
    % nor does the ai have any regions taht are adjacent to a region adjacent to the capital

    % randomly pick a starting region, and randomly pick the ending region

    path (1) := alliedRegions (Rand.Int (1, upper (alliedRegions)))
    assert getAlliance (path (1)) = 2
    
    % randomly select a region from the ones we have
    % coding in the sea regions
    % then randomly select a region connected to that region
    for i:1..25
	if connected(path(1), i) and isIn(i, noGo)=0 and i not = path(1) then
	    path(2):=i
	    result path
	end if
    end for

    % if we got here then something went horribly wrong
    assert getAlliance (path (1)) = 2
    put toName (path (1))
    if path (2) = 0 then
	for i : 1 .. 5
	    put noGo (i)
	end for
    end if
    assert path (2) not= 0
    result path

end aiPath

function aiMove : boolean

    % the master AI move  function
    % get the from
    var path : array 1 .. 2 of int
    loop
	path := aiPath
	exit when path (1) not= path (2)
    end loop
    assert connected (path (1), path (2))
    assert getAlliance (path (1)) = 2

    var toMoveUnits : array 1 .. 4 of int := getAllUnits (2, path (1))
    var totalUnits := 0
    % get all the units we have from a region

    var destUnits : array 1 .. 4 of int := getAllUnits (getAlliance (path (2)), path (2))
    var totalDest := 0
    % get all the units the enemy region has

    for i : 1 .. 4
	totalUnits += toMoveUnits (i)
	totalDest += destUnits (i)
    end for

    % only move half the units and it should be ok
    for i : 1 .. 4
	toMoveUnits (i) := floor (toMoveUnits (i) * 0.5)
    end for

    if path (2) > 20 and getAlliance (path (2)) not= 1 then
	removeUnits (2, path (1), 0, 0, toMoveUnits (3), 0)
	addUnits (2, path (2), 0, 0, toMoveUnits (3), 0)
	for i : 1 .. 4
	    if i = 3 then
	    else
		toMoveUnits (i) := 0
	    end if
	end for
	move (path (1), path (2), toMoveUnits)
	resetNoGo
	result true
    end if
    if totalDest * 0.8 < totalUnits or getAlliance (path (2)) not= 1 or path (2) = getCapital (1) then
	% if the target is neutral, or the target has 125% more units then
	% it is within acceptable limits to take the chance of attacking

	% or if the target is the player's capital then disregard safety
	removeUnits (2, path (1), toMoveUnits (1), toMoveUnits (2), toMoveUnits (3), toMoveUnits (4))
	addUnits (2, path (2), toMoveUnits (1), toMoveUnits (2), toMoveUnits (3), toMoveUnits (4))
	move (path (1), path (2), toMoveUnits)
	resetNoGo
	result true
	% this function returns true on success and false on failure
	% returning false means try running this again
    else
	var debugTest := path (2)
	noGo (noGoNext) := debugTest
	noGoNext += 1
	result false
    end if

end aiMove

% ai needs to hook the
% proc move (from, dest : int, toMoveUnits : array 1 .. 4 of int)
% in move.t to move
% move procedure should handle negotiations and hostilities
% THIS FILE MUST HANDLE UNIT TRANSFERS
% no need to validate what the AI picks - it's stupid but not that stupid
