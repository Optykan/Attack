var isMusicPlaying := false

process setupMusic
    if isMusicPlaying then
	Music.PlayFileStop
    end if
    isMusicPlaying := true
    loop
	exit when not isMusicPlaying
	Music.PlayFile ("music/setup.mp3")
    end loop
    Music.PlayFileStop
    isMusicPlaying := false
end setupMusic

process ambientMusic
    if isMusicPlaying then
	Music.PlayFileStop
    end if
    isMusicPlaying := true
    loop
	exit when not isMusicPlaying
	Music.PlayFile ("music/ambient1.mp3")
	Music.PlayFile ("music/ambient2.mp3")
	Music.PlayFile ("music/ambient3.mp3")
    end loop
    Music.PlayFileStop
    isMusicPlaying := false
end ambientMusic

process actionMusic
    if isMusicPlaying then
	Music.PlayFileStop
    end if
    isMusicPlaying := true
    loop
	exit when not isMusicPlaying
	Music.PlayFile ("music/action1.mp3")
	Music.PlayFile ("music/action2.mp3")
	Music.PlayFile ("music/action3.mp3")
    end loop
    Music.PlayFileStop
    isMusicPlaying := false
end actionMusic

proc stopMusic
    Music.PlayFileStop
    isMusicPlaying := false
end stopMusic

