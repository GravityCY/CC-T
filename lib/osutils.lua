local osUtils = {}

function osUtils.DisableTerminate()
    function os.pullEvent()
        return os.pullEventRaw()
    end
end

function osUtils.EnableTerminate()
    function os.pullEvent( _sFilter )
        local event, p1, p2, p3, p4, p5 = os.pullEventRaw( _sFilter )
        if event == "terminate" then
            print("Terminated")
            error()
        end
        return event, p1, p2, p3, p4, p5
    end
end

return osUtils