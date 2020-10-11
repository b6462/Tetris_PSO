

function garbageGen(tgtSide, num)
  
  local gen_pos = 0
  local x,y
  local mid_map = clone(maps[tgtSide][1], true)
  
  if cur_distance <=0 then 
    cur_mino[tgtSide][2][2] = cur_mino[tgtSide][2][2] - num
  end
  
  clear_map(maps[tgtSide][1])
  clear_map(maps[tgtSide][2])
  
  for x = 1,width do
    mid_map[x] = moveUp(mid_map[x], num)
  end
  
  for y = height-edge-num+1, height do
    local n = love.math.random()
    gen_pos = math.floor((width - 2*edge)*n) + 1 + edge
    for x = 1,width do
      mid_map[x][y] = true
      if x == gen_pos then
        mid_map[x][y] = false
      end
    end
  end
  maps[tgtSide][1] = clone(mid_map, true)
  
end


function exchange()
  local starttime = os.clock();
  
  if score_value[1][2]>0 then
    garbageGen(1, score_value[1][2])
    recv_num[1] = recv_num[1] + score_value[1][2]
    score_value[1][2] = 0
  end
  if score_value[2][2]>0 then
    garbageGen(2, score_value[2][2])
    recv_num[2] = recv_num[2] + score_value[2][2]
    score_value[2][2] = 0
  end
  
  local temp = {0,0}
  if score_value[1][2]<0 then
    temp[1] = score_value[1][2]
    send_num[1] = send_num[1] + score_value[1][2]
    score_value[1][2] = 0
  end
  if score_value[2][2]<0 then
    temp[2] = score_value[2][2]
    send_num[2] = send_num[2] + score_value[2][2]
    score_value[2][2] = 0
  end
  
  score_value[1][2] = (-1)*temp[2]
  score_value[2][2] = (-1)*temp[1]
  local endtime = os.clock();
  local temp_timer_debug = {"func:exchange d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

