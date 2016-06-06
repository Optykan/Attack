var stopped:=false

fcn getTime : string
    var hours := intstr (round (gameTime / 3600) mod 24)
    if strint (hours) < 10 then
	hours := "0" + hours
    end if
    var minutes := intstr (round (gameTime / 60) mod 60)
    if strint (minutes) < 10 then
	minutes := "0" + minutes
    end if
    var seconds := intstr (gameTime mod 60)
    if strint (seconds) < 10 then
	seconds := "0" + seconds
    end if
    var output := hours + ":" + minutes + ":" + seconds
    result output
end getTime

process updateTime
    Window.Select (turnWin)
    stopped:=false
    loop
	gameTime += 1
	delay (1000)
	locate(1,1)
	put "                                                                  "..
	put getTime
	exit when stopped
    end loop
end updateTime

proc resetTime
    gameTime := 0
    stopped:=true
end resetTime

