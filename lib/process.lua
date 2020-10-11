local dif_rows = {0,0,0,0} --采用数组储存一次消行中可能的四处消行位置 因为消行上下不一定连续


local function cleaning(side, rows)
  local t = 1
  for t = 1,4 do
    if rows[t] ~= 0 then
      LPM[side] = LPM[side]+1
      local r = rows[t]
      local x = 0
      for x = 1+edge, width-edge do
        maps[side][1][x][r] = false
        maps[side][2][x][r] = false
        local y = 0
        for y = r-1, 1+edge, -1 do --似乎lua不能自动倒数 加上-1来确定差值方向
          if maps[side][1][x][y] == true then
            maps[side][1][x][y+1] = true
            maps[side][1][x][y] = false
          elseif maps[side][2][x][y] == true then
            maps[side][2][x][y+1] = true
            maps[side][2][x][y] = false
          end
        end        
      end
    end
  end
end

function D_value_map(side) --获取动态图与静态图之间的差和部分 判断是否符合SRS特殊判定 增改计数器
  local starttime = os.clock()
  dif_rows = {0,0,0,0}
  local counter = 0 --再rows[]中定位消行坐标
  for i = 1+edge, height-edge do --按行搜索 所以先高后宽
    local row_counter = 0
    for j = 1+edge, width-edge do
      if maps[side][1][j][i] == true or maps[side][2][j][i] == true then
        row_counter = row_counter + 1
      end
    end
    --print("row counter:" .. row_counter .. "\n")
    if row_counter == width - 2*edge then --说明满行可消 2*edge因为要考虑左边墙厚度
      counter = counter + 1
      dif_rows[counter] = i
    end
  end
  --print("dif_rows:(" .. dif_rows[1] .. "," .. dif_rows[2] .. "," .. dif_rows[3] .. "," .. dif_rows[4] .. ")")
  local l_num = 0
  for i = 1,4 do
    if dif_rows[i] ~= 0 then
      l_num = l_num + 1
    end
  end
  
  scoring(side, l_num) --根据当前值计算SRS系统赋分
  cleaning(side, dif_rows) --消行清理动态图与静态图
  
  local endtime = os.clock()
  local temp_timer_debug = {"func:D_value_map d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function Draw_process_debug()
  
end




