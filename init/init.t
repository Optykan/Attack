include "../global/globalMusic.t"
include "../global/globalStatus.t"
include "../global/globalWin.t"
include "../global/gameTime.t"

include "../map/mapRegions.t"
include "../map/countryLookup.t"

include "../turn/info.t"
include "../turn/clickHandler.t"
include "../turn/inspect.t"
include "../turn/move.t"
include "../turn/ai.t"

proc initialize
    resetTime
    %load from file
    loadLocale
    loadConnections
    loadAlliances
    loadUnits
    loadImages
    getText

    %load EP
    initEP

    %init log handler
    initLogs
    initErr

    %window handler
    openAll

    %graphics
    initStatus
end initialize



