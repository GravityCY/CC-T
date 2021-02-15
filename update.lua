local libs = {  argutils = "https://www.dropbox.com/s/7jvt7vohzwmm18z/argutils.lua?dl=1",
                    debug = "https://www.dropbox.com/s/op1r2gumn7hnomz/debug.lua?dl=1",
                    hackerman = "https://www.dropbox.com/s/9fb1vwob8xsphpk/hackerman.lua?dl=1",
                    invutils = "https://www.dropbox.com/s/4k5an2ptrnw6xgm/invutils.lua?dl=1",
                    osutils = "https://www.dropbox.com/s/a5fblgal7ds1wld/osutils.lua?dl=1",
                    periphutils = "https://www.dropbox.com/s/38ra86b79hkw9mw/periphutils.lua?dl=1",
                    sides = "https://www.dropbox.com/s/jyyd5tnfmgn9v1v/sides.lua?dl=1",
                    stringutils = "https://www.dropbox.com/s/nx5eiqvuu06z34p/stringutils.lua?dl=1",
                    tableutils = "https://www.dropbox.com/s/4wbyhjpie31f4eg/tableutils.lua?dl=1",
                    termutils = "https://www.dropbox.com/s/p2kpl3nkx54qai9/termutils.lua?dl=1",
                    turtleutils = "https://www.dropbox.com/s/85lsheg2pr6psxf/turtleutils.lua?dl=1",
                }

local programs = {  cfurnace = "https://www.dropbox.com/s/woiylz8hm2077pn/cfurnace.lua?dl=1",
                    countitem = "https://www.dropbox.com/s/l3dl4n8rovh9yzt/countitem.lua?dl=1",
                    craft = "https://www.dropbox.com/s/3yvjq0p6q0jeron/craft.lua?dl=1",
                    download = "https://www.dropbox.com/s/9fsm4u8vq2707zy/download.lua?dl=1",
                    finditem = "https://www.dropbox.com/s/gtzev9se0iy7oo2/finditem.lua?dl=1",
                    furnace = "https://www.dropbox.com/s/tuzodi7hbs10par/furnace.lua?dl=1",
                    getitem = "https://www.dropbox.com/s/ymaxsae5kgedep2/getitem.lua?dl=1",
                    ladderdown = "https://www.dropbox.com/s/2id3h4cihrszzcd/ladderdown.lua?dl=1",
                    listitems = "https://www.dropbox.com/s/1uwwyvrhirellpi/listitems.lua?dl=1",
                    merge = "https://www.dropbox.com/s/0cyr8jexuw3puiz/merge.lua?dl=1",
                    minearea = "https://www.dropbox.com/s/vq35hle76hfapjv/minearea.lua?dl=1",
                    receive = "https://www.dropbox.com/s/r7b97eb3kj2rmon/receive.lua?dl=1",
                    split = "https://www.dropbox.com/s/ekqfrpk0j4aki22/split.lua?dl=1",
                    store = "https://www.dropbox.com/s/b7iwbd1tv5taxra/store.lua?dl=1",
                    stripmine = "https://www.dropbox.com/s/9iwmhpaoerezctn/stripmine.lua?dl=1",
                    stripminenor = "https://www.dropbox.com/s/3wdx0xvwwe57r0i/stripminenor.lua?dl=1",
                    tcraft = "https://www.dropbox.com/s/prrmqpqj3rx4dak/tcraft.lua?dl=1",
                    terminal = "https://www.dropbox.com/s/5mpclhts7oz0w9w/terminal.lua?dl=1",
                    test = "https://www.dropbox.com/s/cy70rm42u6ko8gk/test.lua?dl=1",
                    tradeserver = "https://www.dropbox.com/s/e69fg5a6ujsp1mj/tradeserver.lua?dl=1",
                    tradeviewer = "https://www.dropbox.com/s/4g27vlqe4pvlxum/tradeviewer.lua?dl=1",
                    transmit = "https://www.dropbox.com/s/pm5yzos8ucj978n/transmit.lua?dl=1",
                    update = "https://www.dropbox.com/s/tarir5ynpmkn90j/update.lua?dl=1",
                    vertimine = "https://www.dropbox.com/s/is617c4ujrldo79/vertimine.lua?dl=1"}

local args = {...}

local path = "/lib"

local toDown = nil

if programs[args[1]] ~= nil then path = "/" toDown = programs[args[1]]
elseif libs[args[1]] ~= nil then path = "/lib" toDown = libs[args[1]]
else print("No such program.") error() end

fs.makeDir(path)
local program = http.get(toDown)
if program == nil then print("Error") error() return end
local file = fs.open(path .. "/" .. args[1] .. ".lua", "w")
file.write(program.readAll())
file.close()
program.close()