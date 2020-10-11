local lag_timer = 0
timer_debug_list = {"start\n"}

function lag_reset()
  lag_timer = 0
  timer_debug_list = {"start\n"}
end


function writeFile(fileName,content)
    local f = assert(io.open(fileName,'a+'))
    f:write(content)
    f:close()
end

function lag_check(dt) --检查延迟并输出各项间隔时间到文本
  if dt then
    lag_timer = dt
    writeFile('data/lag_output.txt',os.date("%H:%M:%S\nlag_timer:"..lag_timer.."\n" .. table.concat(timer_debug_list) .. "\n"))
  end
  
  lag_reset()
end

function draw_lag()
  love.graphics.print("LAG:" .. lag_timer, 10,200)
end

function timer()
  local starttime = os.clock();
  local endtime = os.clock();
  local temp_timer_debug = {"func:draw_map d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

