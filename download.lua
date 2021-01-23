local args = {...}
local iUrl = args[1]
local flName = args[2]

if iUrl == nil then print("Enter a URL.") return end
if flName == nil then print("Enter a file name.") return end

local function HasHttps(url)
    return url:sub(1,8) == "https://" or url:sub(1,7) == "http://"
end

local function FormatURL(url)
    if not HasHttps(url) then return "https://" .. url end
    return url
end

local function GetDomain(url)
    return url:match("//[%a%d]+"):sub(3)
end

local function GetTopDomain(url)
    return url:match("%.[%a%d]+"):sub(2)
end

local function DownloadUrl(url, fileName)
    local request, message, response = http.get(url)
    if request == nil then
        print("Failed to download " .. url .. ", error message: " .. message) 
        return false 
    end
    local path = shell.dir() .. "/" .. fileName
    if fs.exists(path) then
        print("There is a pre-existing program by that name. Overwrite? Y/N")
        local input = read():lower()
        if input == "n" then error() end
    end
    
    local fileText = request.readAll()
    local file = fs.open(path, "w")
    file.write(fileText)
    file.close()

    print("Wrote file " .. fileName .. " @ " .. path)

    return true
end

local function Pastebin(url, fileName)
    if url:find("raw") ~= nil then DownloadUrl(url, fileName) return false end

    local _, topEnd = url:find("%.[%a%d]+")
    local finUrl = url:sub(1, topEnd) .. "/raw" .. url:sub(topEnd + 1)

    return DownloadUrl(finUrl, fileName)
end

local function Main()
    local url = FormatURL(iUrl)
    local domain = GetDomain(url)
    local domainTop = GetTopDomain(url)    

    if domain == "pastebin" then Pastebin(url, flName) return end
    DownloadUrl(url, flName)
end

Main()

    

    

   
