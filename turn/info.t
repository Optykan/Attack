%include "global/globalWin.t"
%include "countryMap.t"
%include via main

var hlines : int := 3
var plines : int := 5

var hostileText : array 1 .. hlines of string
var peacefulText : array 1 .. plines of string
var turnList : array 0 .. 6 of string := init ("Setup", "Inspect", "Move", "Action", "AI", "Victory", "Defeat")
var turnColors : array 0 .. 6 of int := init (black, brightblue, brightgreen, brightred, black, brightgreen, brightred)

% loads the text to say when a region changes alliance
proc getText
    var file : int
    var t : string
    open : file, "init/changeAlliance.txt", get
    for i : 1 .. hlines
	get : file, skip
	exit when eof (file)
	get : file, hostileText (i) : *
    end for
    for i : 1 .. plines
	get : file, skip
	exit when eof (file)
	get : file, peacefulText (i) : *
    end for
end getText

% procedure for outputting to the scren
proc info (output : string)
    Window.Select (infoWin)
    var infoTemp := "[" + getTime + "] "
    color (green)
    put infoTemp ..
    color (black)
    put output

    put : logFile, infoTemp + output
end info

% cchanges the window status of turn
proc turn (tid : int)
    Window.Select (turnWin)
    var text : int := Font.New ("Verdana:60")
    cls
    Font.Draw (turnList (tid), 20, 100, text, turnColors (tid))
    Font.Free (text)
end turn

% procedure to output help
proc instruct (output : string)
    Window.Select (infoWin)
    color (brightblue)
    put "[HELP] " ..
    color (black)
    put output
end instruct

% asks the user for a confirm string
fcn confirm (output : string) : boolean
    Window.Select (infoWin)
    Window.SetActive (infoWin)
    var a : string
    color (brightred)
    put "[CONFIRM] " ..
    color (black)
    put output ..
    Input.Flush
    get a
    a:=Str.Upper(a)
    if index(a, "Y") >0 then
	result true
    end if
    result false
end confirm

%clears the info window
% note: dont use this
proc infoClear
    Window.Select (infoWin)
    put repeat ("\n", 15)
end infoClear

% procedure to put text when it is a sea takeover
proc seaTakeover (id : int)
    var infotemp := toName (id) + " taken by " + getAllianceName (id) + "."
    info (infotemp)
end seaTakeover

% put text when hostile takover
proc iHostileTakeover (id : int)
    if id > 0 and id < 26 then
	if id > 20 then
	    seaTakeover (id)
	else
	    var infotemp := toName (id) + " " + hostileText (Rand.Int (1, hlines)) + " " + getAllianceName (id) + "."
	    info (infotemp)
	end if
    end if
end iHostileTakeover

% puts text when peaceful takeover (negotiation)
proc iPeacefulTakeover (id : int)
    if id > 0 and id < 26 then
	if id > 20 then
	    seaTakeover (id)
	else
	    var infotemp := toName (id) + " " + peacefulText (Rand.Int (1, plines)) + " " + getAllianceName (id) + "."
	    info (infotemp)
	end if
    end if
end iPeacefulTakeover

proc ipt (id : int)
    iPeacefulTakeover (id)
end ipt

proc iht (id : int)
    iHostileTakeover (id)
end iht
