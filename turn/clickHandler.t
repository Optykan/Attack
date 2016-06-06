%include "mapRegions.t"
%include "global/globalWin.t"
%include "buttonStatus.t"
%These should be included in the main program

fcn waitCountry : int
    Window.Select (mapWin)
    var mx, my, button, temp : int
    loop
	loop
	    Mouse.Where (mx, my, button)
	    exit when button = 1
	end loop
	loop
	    Mouse.Where (mx, my, button)
	    exit when button = 0
	end loop
	temp := clickRegion (mx, my)
	if temp > 0 and temp < 26 then
	    result temp
	end if
    end loop
end waitCountry

fcn waitFinal : int
    var mx, my, button, temp : int
    loop
	loop
	    Mouse.Where (mx, my, button)
	    exit when button = 1
	end loop
	loop
	    Mouse.Where (mx, my, button)
	    exit when button = 0
	end loop
	temp := clickRegion (mx, my)
	if temp > 0 and temp < 26 then
	    result temp
	end if
    end loop
end waitFinal

fcn waitConfirm : boolean
    %change active window to confirm/reset window
    %get confirm

end waitConfirm

fcn waitSelect () : array 1 .. 2 of int
    var tmp := "Select an allied region, then an adjacent region."
    instruct (tmp)

    Window.Select (mapWin)
    var select : array 1 .. 2 of int := init (0, 0)
    loop
	loop
	    select (1) := waitCountry
	    exit when isAlly (select (1))
	    fork errorCircle (select (1))
	    tmp := toName (select (1)) + " is not an ally."
	    instruct (tmp)
	    Window.Select (mapWin)
	end loop
	tmp := "Selected " + toName (select (1)) + "."
	instruct (tmp)
	moveCircle1 (select (1))

	loop
	    select (2) := waitFinal
	    exit when connected (select (1), select (2)) and select (1) not= select (2)
	    if select (1) = select (2) then
		instruct ("Select a region that is not currently selected.")
	    else
		fork errorCircle (select (2))
		instruct ("Regions not connected.")
	    end if
	    Window.Select (mapWin)
	end loop

	moveCircle2 (select (2))
	tmp := "Confirm move from " + toName (select (1)) + " to " + toName (select (2)) + " (Y/N):"
	exit when confirm (tmp)
	deselectCircle (select (1))
	deselectCircle (select (2))

	select (1) := 0
	select (2) := 0

    end loop
    deselectCircle (select (1))
    deselectCircle (select (2))
    result select
end waitSelect
