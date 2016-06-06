var imageMap : array 1 .. 25 of string

proc loadImages
    var file : int
    open : file, "init/images.txt", get
    for i : 1 .. 25
	get : file, skip
	exit when eof (file)
	get : file, imageMap (i)
    end for
end loadImages

fcn countryName (id:int):string
    result imageMap(id)
end countryName

fcn countryImage (id : int) : string
    var url := "images/" + imageMap (id) + ".jpg"
    result url
end countryImage

proc continueInspect
    Window.Select(inspectWin)

    locate(33, 1) 
    color(brightgreen)
    put "Waiting for select..."
    color(black)
    inspectTurn:=1
end continueInspect

proc endInspect
    Window.Select(inspectWin)

    locate(33, 1) 
    color(brightred)
    put "Inspection turn ended."
    color(black)
    inspectTurn:=2
end endInspect

proc inspect
    var inspectTemp := 0
    var inspectIndent := ""

    inspectTemp := waitCountry
    Window.Select (inspectWin)
    cls
    locate(15, 1)
    put inspectIndent, "--------- INFO ---------"
    put inspectIndent, "Name     : ", toName (inspectTemp)
    put inspectIndent, "Alliance : ", inspectAlliance (inspectTemp)
    put inspectIndent, "Country  : ", countryName(inspectTemp)
    put "\n--------- UNITS ---------"
    put inspectIndent, "Infantry : ", getUnits (getAlliance (inspectTemp), inspectTemp, 1)
    put inspectIndent, "Tanks    : ", getUnits (getAlliance (inspectTemp), inspectTemp, 2)
    put inspectIndent, "Air      : ", getUnits (getAlliance (inspectTemp), inspectTemp, 3)
    put inspectIndent, "Naval    : ", getUnits (getAlliance (inspectTemp), inspectTemp, 4)
    var flag : int := Pic.FileNew (countryImage (inspectTemp))
    Pic.Draw (flag, 0,maxy-210, picCopy)
    Pic.Free(flag)
    
    locate(27, 1)
    put inspectIndent, "--------- GLOBAL STATUS ---------"
    put inspectIndent, "Allied Regions  : ", getTotalAlliance(1)
    put inspectIndent, "Enemy Regions   : ", getTotalAlliance(2)
    put inspectIndent, "Neutral Regions : ", getTotalAlliance(0)

    var endInspectButton : int := GUI.CreateButton (20, 20, 0, "End Inspect", endInspect)
    var continueInspectButton : int := GUI.CreateButton (200, 20, 0, "Inspect Another Region", continueInspect)
end inspect
