var mapWin, inspectWin, infoWin, turnWin, instructWin, loadingWin, gameOverWin : int

proc closeInstructions
    Window.Close (instructWin)
end closeInstructions

proc writeToLine (linenum : int)
    View.Set ("offscreenonly")
    var instructions : int
    var line : string
    open : instructions, "init/instructions.txt", get
    Window.Select (instructWin)
    cls
    for i : 1 .. linenum
	get : instructions, line : *
    end for
    for i : linenum .. maxrow - 5
	exit when eof (instructions)
	get : instructions, line : *
	put line
    end for
    View.Update
end writeToLine

proc openInstructions

    var totalLines := 100
    var instructions : array 1 .. totalLines of string
    var chars : array char of boolean

    var startLine := 1
    var endLine := 1

    var showQuit := false

    var stream : int
    instructWin := Window.Open ("position:top;left,graphics:max;max, title: Instructions, nobuttonbar")

    open : stream, "init/instructions.txt", get

    for i : 1 .. totalLines
	get : stream, instructions (i) : *
	%assert(not eof(stream))
    end for
    close : stream

    for i : 1 .. maxrow - 5
	endLine += 1
	if index (instructions (i), "#") not= 0 then
	    color (55)
	elsif index (instructions (i), "NOTE:") not= 0 then
	    color (41)
	else
	    color (black)
	end if
	put instructions (i)
    end for

    loop
	locate (maxrow - 1, 1)
	color (blue)
	put "Use the left/right arrow keys to navigate."
	color (black)
	Input.Flush
	Input.Pause
	Input.KeyDown (chars)

	if chars ('Q') or chars ('q') and showQuit then
	    Window.Close (instructWin)
	    showInstructions := false
	    exit
	elsif chars ('N') or chars ('n') and showQuit then
	    var prefStream : int
	    open : prefStream, "init/pref.ini", put
	    put : prefStream, false
	    close : prefStream
	    showInstructions := false
	    Window.Close (instructWin)
	    exit
	elsif chars (KEY_RIGHT_ARROW) and endLine < totalLines then
	    cls
	    startLine += 1
	    endLine += 1
	    for i : startLine .. endLine
		if index (instructions (i), "#") not= 0 then
		    color (55)
		elsif index (instructions (i), "NOTE:") not= 0 then
		    color (41)
		else
		    color (black)
		end if
		put instructions (i)
	    end for
	    if endLine = totalLines - 1 or showQuit then
		showQuit := true
		locate (maxrow - 2, 1)
		color (brightred)
		put "Press 'Q' to close, or 'N' to close and never show again."
		color (black)
	    end if
	elsif chars (KEY_LEFT_ARROW) and startLine > 1 then
	    cls
	    startLine -= 1
	    endLine -= 1
	    for i : startLine .. endLine
		if index (instructions (i), "#") not= 0 then
		    color (55)
		elsif index (instructions (i), "NOTE:") not= 0 then
		    color (41)
		else
		    color (black)
		end if
		put instructions (i)
	    end for
	    if showQuit then
		locate (maxrow - 2, 1)
		color (brightred)
		put "Press 'Q' to close, or 'N' to close and never show again."
		color (black)
	    end if
	end if
    end loop


end openInstructions

proc openMap
    mapWin := Window.Open ("position:top;left,graphics:800;632, title: Map, nobuttonbar")
    Window.Select (mapWin)
    var background : int := Pic.FileNew ("images/europe.bmp")
    Pic.Draw (background, 0, 0, 0)
end openMap

proc openInspect
    inspectWin := Window.Open ("position:top;right, graphics:440;632, title:Inspection Menu, nobuttonbar")
    Window.Select (inspectWin)
    color (brightgreen)
    put "READY"
    color (black)
    Window.Select (mapWin)
end openInspect

proc openTurn
    turnWin := Window.Open ("position:bottom;right, graphics: 440; 275, title: Turn Information, nobuttonbar")
end openTurn

proc openInfo
    %infoWin := Window.Open ("position:bottom;left, text:16;98, title:Info, cursor, nobuttonbar")
    infoWin := Window.Open ("position:bottom;left, graphics:800;275, title:Info, cursor, nobuttonbar")
end openInfo

proc openAll
    openMap
    openInspect
    openTurn
    openInfo
end openAll

fcn openGameOver (winner, loser, gameT : string) : boolean
    gameOverWin := Window.Open ("position:middle;middle,graphics: 500;200, title: Game Over!, nobuttonbar")
    Window.Select (gameOverWin)
    put "-----===== GAME OVER =====-----"
    put "At [", gameT, "] ", winner, " has claimed victory!"
    put ""
    put "Press any key to play again, or 'Q' to quit."
    Input.Flush
    var keyPressed : string (1)

    getch (keyPressed)
    if keyPressed = 'Q' or keyPressed = 'q' then
	Window.Close (gameOverWin)
	result false
    end if
    Window.Close (gameOverWin)
    result true

end openGameOver

proc closeAll
    Window.Close (mapWin)
    Window.Close (inspectWin)
    Window.Close (turnWin)
    Window.Close (infoWin)
end closeAll
