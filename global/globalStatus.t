% stores what units both teams have
% infantry: 1, tanks:2 , air: 3, naval: 4
% formatted as:   team   id    units
var units : array 0 .. 2, 1 .. 25, 1 .. 4 of int

% initial reserve
var reserve : array 1 .. 2, 1 .. 4 of int := init (0, 0, 0, 5, 0, 0, 0, 5)

% stores which regions are connected
var connections : array 1 .. 25, 1 .. 25 of int

% stores the alliances of the regions
% 0 = neutral, 1 = player, 2+ = enemy
var alliances : array 1 .. 25 of int


% stores the country names mapped to their IDs
% country names can be changed in locale.txt
var countryNames : array 1 .. 25 of string

% stores the capital city selection
var capitals : array 1 .. 2 of int := init (0,0)

% stores the game time
var gameTime : int := 0

% stores how the world views the player
% a lower number is better, and a higher number is worse
% this is used in negotiations to calculate probability through equation
% probability = 100 * (- (6) ** (-0.05 * (ep - ((globalView / 4) - 5)))) + 100
% where ep is economic points given

var globalView : int := 10

var economicPoints : int := 0

% preferences
var showInstructions : boolean
var prefMusic : string

%open the log file
var logFile : int
var errFile : int

% is it inspection time?
% 0 is unset, 1 is continue, 2 is exit
var inspectTurn : int := 0

% who won?
% true if player, false if AI
var winner : boolean

% proedure to initalize EP

proc initPref
    var stream : int
    open : stream, "init/pref.ini", get
    get : stream, showInstructions
    get:stream, prefMusic
    close : stream
end initPref
proc initEP
    for i : 1 .. 4
	economicPoints += Rand.Int (1, 4)
    end for
end initEP

proc initLogs
    open : logFile, "logs/log.txt", put
end initLogs

proc initErr
    open : errFile, "logs/error.txt", put
end initErr
