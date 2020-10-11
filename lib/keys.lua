rotateIsLast = false --用于T_spin判定 锁定前最后一个按键必须是rotate
local movePending = 1 --用于阻止hardDrop发生在移动控制校准刷新前
local mid_map = {{},{}} --储存移动中间碰撞判断图

function keys_init()
  local i,j,k
  for k = 1,2 do
    mid_map[k] = {}
    for i = -2,width+2 do
      mid_map[k][i] = {}
      for j = -4,height do
        mid_map[k][i][j] = false
      end
    end
  end
end

function rotate(dir,side)
  local starttime = os.clock();
  --str_temp_mino = {{0,0},{0,0},{0,0},{0,0},{0,0}}
  --str_kick_list = {{0,0},{0,0},{0,0},{0,0},{0,0}}
  --str_cur_kick_list = {{0,0},{0,0},{0,0},{0,0},{0,0}}
  temp_mino[side][1] = rotate_mino(side,dir) --临时储存旋转后形态数组
  rotate_mino(side,1-dir) --返rotate 先不确定
  local kicklist = {}
  kicklist = req_kicklist(side,dir) --获取kicklis
  marker = false --记录能否旋转
  
  local n = 1
  for n = 1, 5 do
    --temp_mino[2] = cur_mino[side][2] --临时储存kick之后的中心坐标位置
    temp_mino[side][2] = {0,0}
    temp_mino[side][2][1] = cur_mino[side][2][1] + kicklist[n][1] --更新
    temp_mino[side][2][2] = cur_mino[side][2][2] + kicklist[n][2]
    
    --str_temp_mino[n][1] = cur_mino[side][2][1] --debug
    --str_temp_mino[n][2] = cur_mino[side][2][2]
    
    --2020年8月25日 01点35分 debug发现temp_mino位置坐标在累加 而不是在每次刷新后计算 早上再排查
    
    --str_kick_list[n] = kicklist[n] --debug
    --str_temp_mino[n] = temp_mino[2] --debug
    local map_temp = {}
    map_temp = maps[side][2] --临时作为活跃图
    clear_map(map_temp)
    refresh_map(map_temp, temp_mino[side][1], temp_mino[side][2]) --在活跃图中刷新位置
    if col_check(maps[side][1], map_temp) == true or col_check(map_edge[side], map_temp) == true then --检查活跃图与静态图是否冲突
      clear_map(map_temp)
    else
      --str_map_temp = map_temp --debug
      --str_cur_kick_list[n] = kicklist[n] --debug
      cur_mino[side][1] = temp_mino[side][1]
      cur_mino[side][2] = temp_mino[side][2] --无冲则更新本地数据
      rotateIsLast = true --发生旋转 准备T-spin记录
      maps[side][2] = map_temp
      marker = true
      rotate_mino(side,dir)
      break
    end
    release(map_temp)
  end
  
  release(kicklist)
  local endtime = os.clock();
  local temp_timer_debug = {"func:rotate_key d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function z_press(side)
  rotate(0,side)
end
  

function x_press(side)
  rotate(1,side)
end
  


function up_press(side)
  local starttime = os.clock();
  while(col_check(mid_map[side], maps[side][1]) == false and col_check(map_edge[side], mid_map[side]) == false) do
    cur_mino[side][2][2] = cur_mino[side][2][2] + 1
    refresh_map(mid_map[side], cur_mino[side][1], cur_mino[side][2])
  end
  clear_map(mid_map[side])
  cur_mino[side][2][2] = cur_mino[side][2][2] - 1
  game_status_main[side] = 3
  
  local endtime = os.clock();
  local temp_timer_debug = {"func:up_press d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function down_press(side)
  local starttime = os.clock();
  local RTIL = rotateIsLast --如果不移动，则上一个记录依旧保持
  rotateIsLast = false
  cur_mino[side][2][2] = cur_mino[side][2][2] + 1
  refresh_map(mid_map[side], cur_mino[side][1], cur_mino[side][2])
  if col_check(mid_map[side], maps[side][1]) == true or col_check(map_edge[side], mid_map[side]) == true then
    cur_mino[side][2][2] = cur_mino[side][2][2] - 1
    rotateIsLast = RTIL
  end
  clear_map(mid_map[side])
  
  local endtime = os.clock();
  local temp_timer_debug = {"func:down_press d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function left_press(side)
  local starttime = os.clock();
  local RTIL = rotateIsLast
  rotateIsLast = false
  cur_mino[side][2][1] = cur_mino[side][2][1] - 1
  refresh_map(mid_map[side], cur_mino[side][1], cur_mino[side][2])
  if col_check(mid_map[side], maps[side][1]) == true or col_check(map_edge[side], mid_map[side]) == true then
    cur_mino[side][2][1] = cur_mino[side][2][1] + 1
    rotateIsLast = RTIL
  end
  clear_map(mid_map[side])
  
  local endtime = os.clock();
  local temp_timer_debug = {"func:left_press d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function right_press(side)
  local starttime = os.clock();
  local RTIL = rotateIsLast
  rotateIsLast = false
  cur_mino[side][2][1] = cur_mino[side][2][1] + 1
  refresh_map(mid_map[side], cur_mino[side][1], cur_mino[side][2])
  if col_check(mid_map[side], maps[side][1]) == true or col_check(map_edge[side], mid_map[side]) == true then
    cur_mino[side][2][1] = cur_mino[side][2][1] - 1
    rotateIsLast = RTIL
  end
  clear_map(mid_map[side])
  
  local endtime = os.clock();
  local temp_timer_debug = {"func:right_press d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function hold_press(side)
  rotateIsLast = false
  if game_status_main[side] == 2 and hold_checker[side] == 0 then
    hold(side)
  end
end

function garbage_test(side)
  garbageGen(1,3)
  garbageGen(2,3)
end


