-- MADE BY ELPERSON
local db = require("lapis.db") -- 1209600 seconds = 15 days
local function clearDB()
    local res = db.select("crstamp FROM sessions")
    for i,v in pairs(res) do
        if os.time() - v.crstamp >= 2592000 then -- 2592000 seconds = 30 days
            print("Sesssion inactive for 30 days or longer... Deleting")
            db.delete("sessions", {crstamp = v.crstamp})
        end
    end
end

if ngx.worker.id() == 0 then
    --print('Syncing files with image table')
    
    ngx.timer.at(0, function()
        
        ngx.thread.spawn(function()
            while true do
            clearDB()
            local sel = db.select("imgurl, lastvisited FROM images")
            for i,v in pairs(sel) do
                if v.lastvisited - os.time() >= 1209600 then
                    assert(os.remove("/srv/lapis/html/files/"..v.imgurl))
                    local res = db.delete("images", "imgurl = ?", v.imgurl)
                end
            end
            ngx.sleep(1209600)
          end
        end)
        ngx.thread.spawn(function ()
            while true do
                db.update("users", {
                    quota = 0
                })
                ngx.sleep(3600)
            end
        end)
        
    end)

end
