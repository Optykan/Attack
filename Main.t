import GUI
include "init/init.t"

% temporary variables for calculations

var st : string := ""
var it : int := 0
var it2 : int := 0
var tselect : array 1 .. 2 of int

initPref
loop
    initialize
    fork setupMusic

    % check preferences file to see if they want to view the instructions
    if showInstructions then
	% instructions is in global/globalWin.t"
	% opens the instructions ONCE per launch
	% if the user pressed N to never view again then save that in the preferences
	% otherwise if they pressed Q don't show the instructions for the rest of the session
	openInstructions
    end if

    %------ BEGIN INIT ------%
    % start the game timer
    fork updateTime

    turn (0)
    %select capital
    loop
	instruct ("Select your capital.")
	loop
	    it := waitCountry
	    exit when it > 0 and it < 21

	    %otherwise invalid selection, flash the circle red
	    fork errorCircle (it)
	    instruct ("Selection is not a country.")
	end loop

	%confirm selection of capital
	st := "Confirm selection of " + toName (it) + " as your capital (Y/N): "
	selectCircle (it)
	exit when confirm (st)
	deselectCircle (it)
    end loop

    %output capital city setting
    deselectCircle (it)
    setCapital (it, 1)
    st := "Selected " + toName (getCapital (1)) + " as capital."
    info (st)
    setUnits (1, it, 16, 6, 2, 0)

    % allow user to select an adjacent region

    loop
	instruct ("Select one adjacent region to form an alliance. ")
	loop
	    it := waitCountry
	    exit when connected (it, getCapital (1)) and it not= getCapital (1)

	    fork errorCircle (it)
	    instruct ("Regions are not connected.")
	end loop

	selectCircle (it)
	st := "Confirm selection of " + toName (it) + " (Y/N): "
	exit when confirm (st)
	deselectCircle (it)

    end loop

    %transfer units to ally team, set as ally
    transferUnits (0, 1, it)
    setAlly (it, 1)
    ipt (it)

    % generate the AI's capital
    loop
	it2 := Rand.Int (1, 20)
	% make sure it is not connected to any of the allied capitals
	if not connected (getCapital (1), it2) and it2 not= getCapital (1) and not connected (it, it2) and it2 not= it and it2 not= 1 and it2 not= 2 and it2 not= 8 and it2 not= 19 then
	    % if it is not connected then set it
	    setCapital (it2, 2)
	    %give Ai default units
	    setUnits (2, it2, 16, 6, 2, 0)
	    exit
	end if
    end loop

    % put the country name of enemy selection
    st := "Enemy selected " + toName (getCapital (2)) + " as capital."
    info (st)

    %start the music before continuing on to main game loop
    if prefMusic = "action" then
	fork actionMusic
    elsif prefMusic = "ambient" then
	fork ambientMusic
    end if

    %------ END INIT ------%

    %MASTER TURN LOOP
    loop
	%user inspect turn

	turn (1)
	instruct ("Inspect turn begin. Select any region to continue.")
	tselect (1) := 0
	tselect (2) := 0

	loop
	    inspect
	    loop
		exit when GUI.ProcessEvent or inspectTurn not= 0
	    end loop
	    exit when inspectTurn = 2
	    inspectTurn := 0
	end loop
	inspectTurn := 0

	%declare movement turn
	turn (2)

	%Allow user to make a move
	% this is handled by waitSelect() in clickHandler.t
	% store the movement in this temporary array
	tselect := waitSelect ()

	% get the number of units user wishes to transfer
	turn (3)
	%fork actionMusic
	% move from and to the selected region
	loop
	    exit when moveUnits (1, tselect (1), tselect (2))
	end loop

	if noUnits (1) then
	    % the player ran out of units and thus lost
	    turn (6)
	    exit
	elsif noUnits (2) then
	    % the AI ran out of units (this shouldn't happen) and lost
	    turn (5)
	    exit
	elsif getAlliance (getCapital (2)) = 1 then
	    % player won
	    turn (5)
	    exit
	elsif getAlliance (getCapital (1)) = 2 then
	    % player lost
	    turn (6)
	    exit
	end if


	% AI moves
	turn (4)
	loop
	    exit when aiMove
	end loop

	if getAlliance (getCapital (2)) = 1 then
	    % player won
	    winner := true
	    turn (5)
	    exit
	elsif getAlliance (getCapital (1)) = 2 then
	    % player lost
	    winner := false
	    turn (6)
	    exit
	end if
    end loop


    % end game screen here
    if winner then
	if not openGameOver (toName (getCapital (1)), toName (getCapital (2)), getTime) then
	    exit
	end if
    else
	if not openGameOver (toName (getCapital (2)), toName (getCapital (1)), getTime) then
	    exit
	end if
    end if
    closeAll
end loop

%game is over
closeAll
stopMusic

