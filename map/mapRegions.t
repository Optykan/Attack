%include "global/globalWin.t"
%include via main
fcn getCapital (team : int) : int
    if team = 0 then
	result 0
    end if
    result capitals (team)
end getCapital

var circleLoc : array 1 .. 25, 1 .. 2 of int := init (128, 533,
    166, 440,
    200, 331,
    218, 260,
    92, 184,
    166, 139,
    292, 354,
    446, 590,
    422, 447,
    372, 348,
    333, 283,
    426, 230,
    520, 307,
    634, 530,
    628, 437,
    700, 339,
    648, 236,
    574, 172,
    736, 143,
    747, 499,
    62, 292,
    247, 523,
    370, 67,
    484, 526,
    741, 236)

proc moveCircle1 (id : int)
    Window.Select (mapWin)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, brightgreen)
end moveCircle1

proc moveCircle2 (id : int)
    Window.Select (mapWin)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, brightgreen)
end moveCircle2

proc selectCircle (id : int)
    Window.Select (mapWin)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, 11)
end selectCircle

proc deselectCircle (id : int)
    Window.Select (mapWin)
    if getCapital (1) = id or getCapital (2) = id then
	Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, 100)
    else
	Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, black)
    end if
end deselectCircle

process errorCircle (id : int)
    Window.Select (mapWin)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, brightred)
    delay (200)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, black)
    delay (100)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, brightred)
    delay (200)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, black)
end errorCircle

proc updateStatus (id, side : int, capital : boolean)
    Window.Select (mapWin)
    var col : int := gray
    var outline : int := black
    if side = 1 then
	col := brightgreen
    elsif side = 2 then
	col := brightred
    end if

    if capital then
	outline := 100
    end if
    Draw.FillOval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, col)
    Draw.Oval (circleLoc (id, 1), circleLoc (id, 2), 8, 8, outline)
end updateStatus

fcn clickRegion (x, y : int) : int
    if x <= 145 and x >= 85 and y >= 549 and y <= 569 then
	result 1
    elsif x <= 206 and x >= 130 and y >= 450 and y <= 474 then
	result 2
    elsif x <= 245 and x >= 156 and y >= 337 and y <= 369 then
	result 3
    elsif x <= 278 and x >= 182 and y >= 267 and y <= 294 then
	result 4
    elsif x <= 147 and x >= 48 and y >= 186 and y <= 227 then
	result 5
    elsif x <= 160 and x >= 85 and y >= 116 and y <= 135 then
	result 6
    elsif x <= 330 and x >= 270 and y >= 365 and y <= 387 then
	result 7
    elsif x <= 481 and x >= 420 and y >= 604 and y <= 623 then
	result 8
    elsif x <= 498 and x >= 372 and y >= 454 and y <= 495 then
	result 9
    elsif x <= 410 and x >= 346 and y >= 362 and y <= 398 then
	result 10
    elsif x <= 393 and x >= 315 and y >= 293 and y <= 318 then
	result 11
    elsif x <= 429 and x >= 386 and y >= 242 and y <= 262 then
	result 12
    elsif x <= 587 and x >= 458 and y >= 278 and y <= 377 then
	result 13
    elsif x <= 682 and x >= 596 and y >= 536 and y <= 565 then
	result 14
    elsif x <= 688 and x >= 563 and y >= 434 and y <= 483 then
	result 15
    elsif x <= 788 and x >= 631 and y >= 332 and y <= 374 then
	result 16
    elsif x <= 682 and x >= 612 and y >= 246 and y <= 271 then
	result 17
    elsif x <= 594 and x >= 546 and y >= 183 and y <= 206 then
	result 18
    elsif x <= 797 and x >= 682 and y >= 145 and y <= 184 then
	result 19
    elsif x <= 794 and x >= 708 and y >= 484 and y <= 540 then
	result 20
    elsif x <= 118 and x >= 8 and y >= 293 and y <= 357 then
	result 21
    elsif x <= 312 and x >= 200 and y >= 523 and y <= 562 then
	result 22
    elsif x <= 516 and x >= 262 and y >= 69 and y <= 123 then
	result 23
    elsif x <= 558 and x >= 489 and y >= 532 and y <= 552 then
	result 24
    elsif x <= 794 and x >= 715 and y >= 245 and y <= 271 then
	result 25
    else
	result 0
    end if
end clickRegion

proc initStatus
    for i : 1 .. 25
	updateStatus (i, 0, false)
    end for
end initStatus
