%include "global/globalStatus.t"
%include via main

% load locale
proc loadLocale
    var file : int
    var t : string
    open : file, "init/locale.txt", get
    for i : 1 .. 25
	exit when eof (file)
	get : file, t : *
	countryNames (i) := Str.Upper (t)
    end for
    close : file
end loadLocale

% load connected regions
proc loadConnections
    var file : int
    open : file, "init/connections.prn", get
    for i : 1 .. 25
	for j : 1 .. 25
	    get : file, skip
	    exit when eof (file)
	    get : file, connections (i, j)
	end for
    end for
    close : file
end loadConnections

% load default region units
proc loadUnits
    var file : int
    open : file, "init/units.prn", get
    for i : 1 .. 25
	for j : 1 .. 4
	    get : file, skip
	    exit when eof (file)
	    get : file, units (0, i, j)
	end for
    end for
    close : file
    for i : 1 .. 2
	for j : 1 .. 25
	    for k : 1 .. 4
		units (i, j, k) := 0
	    end for
	end for
    end for
end loadUnits

% convert internal ID to name
fcn toName (id : int) : string
    if id > 0 and id < 26 then
	result countryNames (id)
    elsif id = 0 then
	result "NEUTRAL"
    else
	var output := "\n ERROR: \n Traceback: map/countryLookup.t -> toName(" + intstr (id) + ")"
	put : errFile, output
	result output
    end if
end toName

% convert name to internal ID
fcn toID (name : string) : int
    for i : 1 .. 25
	if Str.Upper (name) = countryNames (i) then
	    result i
	end if
    end for
    result 0
end toID

% load all neutral territories
proc loadAlliances
    for i : 1 .. 25
	alliances (i) := 0
    end for
end loadAlliances

% change alliance
proc setAlly (id, team : int)
    alliances (id) := team
    updateStatus (id, team, false)
end setAlly

% set capital region
proc setCapital (id, team : int)
    capitals (team) := id
    setAlly (id, team)
    updateStatus (id, team, true)
end setCapital

%get the alliance of a region
fcn getAlliance (id : int) : int
    if id > 0 and id < 26 then
	result alliances (id)
    end if
    result 0
end getAlliance

% get the number of regions a team owns
fcn getTotalAlliance (team : int) : int
    var getTotalAllianceTemp := 0
    for i : 1 .. 25
	if getAlliance (i) = team then
	    getTotalAllianceTemp += 1
	end if
    end for
    result getTotalAllianceTemp
end getTotalAlliance

% get the name of the alliance assigned to a region (ie : neutral, enemy, ally), relative to player
fcn getAllianceName (id : int) : string
    if id > 0 and id < 26 then
	var a := getAlliance (id)
	if a = 1 or a = 2 then
	    result toName (capitals (getAlliance (id)))
	else
	    result "NEUTRAL"
	end if
    end if
    var output : string := "\nERROR: \n Traceback: map/countryLookup.t -> getAllianceName(" + intstr (id) + ")"
    put : errFile, output
    result output
end getAllianceName

fcn inspectAlliance (id : int) : string
    var a := getAlliance (id)
    if a = 1 then
	result "ALLY"
    elsif a = 2 then
	result "ENEMY"
    else
	result "NEUTRAL"
    end if
    result "NEUTRAL"
end inspectAlliance

% returns the name of the unit from internal id
fcn getUnitName (id : int) : string
    var getUnit : array 1 .. 4 of string := init ("Infantry", "Tank", "Air", "Naval")
    result getUnit (id)
end getUnitName


% returns an array containing the units for a team in that region
fcn getAllUnits (team, id : int) : array 1 .. 4 of int
    var getAllUnitsTemp : array 1 .. 4 of int
    for i : 1 .. 4
	getAllUnitsTemp (i) := units (team, id, i)
    end for
    result getAllUnitsTemp
end getAllUnits

% gets the number of a type of unit by region id
fcn getUnits (team, id, uid : int) : int
    result units (team, id, uid)
end getUnits

% transfers units from a team to another team (from, dest) in that region
proc transferUnits (from, dest, id : int)
    %from alliance
    %dest alliance
    %region id
    for i : 1 .. 4
	units (dest, id, i) += units (from, id, i)
	units (from, id, i) := 0
    end for
end transferUnits

% override the region units
proc setUnits (team, id, inf, tank, air, nav : int)
    units (team, id, 1) := inf
    units (team, id, 2) := tank
    units (team, id, 3) := air
    units (team, id, 4) := nav
end setUnits

% add units to a region
proc addUnits (team, id, inf, tank, air, nav : int)
    units (team, id, 1) += inf
    units (team, id, 2) += tank
    units (team, id, 3) += air
    units (team, id, 4) += nav
end addUnits

% take away units from a region
proc removeUnits (team, id, inf, tank, air, nav : int)
    units (team, id, 1) -= inf
    units (team, id, 2) -= tank
    units (team, id, 3) -= air
    units (team, id, 4) -= nav
end removeUnits

% get units in reserve for a team
fcn getReserve (team : int) : array 1 .. 4 of int
    var getReserveTemp : array 1 .. 4 of int
    for i : 1 .. 4
	getReserveTemp (i) := reserve (team, i)
    end for
    result getReserveTemp
end getReserve

% get number of a type of unit in reserve
fcn getReserveId (team, id : int) : int
    result reserve (team, id)
end getReserveId

% returns if a region is an ally to the player
fcn isAlly (id : int) : boolean
    if alliances (id) = 1 then
	result true
    end if
    result false
end isAlly

% are these regions connected
fcn connected (start, finish : int) : boolean
    if connections (start, finish) = 1 then
	result true
    else
	result false
    end if
end connected
