edge = 1
width = 10+2*edge
height = 20+2*edge
cur_distance = {0,0} --目前距离地面距离 用于垃圾行上升时判断是否一起上升

maps = {{{},{}},{{},{}}} --{{{map_L},{map_L_active}},{{map_R},{map_R_active}}}
map_edge = {{},{}}


function setupMap()
	for x = -2,width+2 do --预留给AI搜索的冗余2
		maps[1][1][x] = {} --map_L
    maps[1][2][x] = {} --map_L_active
    maps[2][1][x] = {} --map_R
    maps[2][2][x] = {} --map_R_active
    map_edge[1][x] = {}
    map_edge[2][x] = {}
		for y = -4,height do
      maps[1][1][x][y] = false
      maps[1][2][x][y] = false
      maps[2][1][x][y] = false
      maps[2][2][x][y] = false
      map_edge[1][x][y] = false
      map_edge[2][x][y] = false
      if x <=edge or x >= width-edge+1 or y >= height-edge+1 then 
        map_edge[1][x][y] = true
        map_edge[2][x][y] = true
      end
		end
	end 
  str_map_edge = map_edge[1] --debug
  str_map_temp = maps[1][2] --debug
end

function drawMap()
  local starttime = os.clock();
	love.graphics.setColor(156/255,226/255,255/255,1)
  local size = 40 * env
  for x = 1+edge,width-edge do
    for y = edge,height-edge do --从edge开始因为出生位置在edge外
      love.graphics.setColor(156/255,226/255,255/255,1)
      if game_status_main[1] == 4 then love.graphics.setColor(78/255,113/255,125/255,1) end
      if maps[1][1][x][y] == true then
        love.graphics.rectangle("fill", x*size+120*env, 10+y*size, size-2, size-2, 5*env, 5*env)
      end
      if maps[1][2][x][y] == true then 
        love.graphics.rectangle("fill", x*size+120*env, 10+y*size, size-2, size-2, 5*env, 5*env)
      end
      
      love.graphics.setColor(156/255,226/255,255/255,1)
      if game_status_main[1] ~= 4 then love.graphics.setColor(78/255,113/255,125/255,1) end
      if maps[2][1][x][y] == true then 
        love.graphics.rectangle("fill", x*size+800*env, 10+y*size, size-2, size-2, 5*env, 5*env)
      end
      if maps[2][2][x][y] == true then 
        love.graphics.rectangle("fill", x*size+800*env, 10+y*size, size-2, size-2, 5*env, 5*env)
      end
    end
	end
  love.graphics.setColor(156/255,226/255,255/255,1)
  local endtime = os.clock();
  local temp_timer_debug = {"func:draw_map d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end

function clear_map(map_type)
  for x = 1,width do
		for y = -1,height do
      map_type[x][y] = false
		end
	end
end

function draw_ghost(side)
  local starttime = os.clock();
  love.graphics.setColor(156/255,226/255,255/255,1)
  if side == 1 and game_status_main[1] == 4 then 
    love.graphics.setColor(78/255,113/255,125/255,1)
  elseif side == 2 and game_status_main[1] ~=4 then 
    love.graphics.setColor(78/255,113/255,125/255,1)
  end
  local size = 40 * env
  local counter_lock = false
  local temp_mino = {}
  temp_mino = get_cur_mino(side)
  local x = cur_mino[side][2][1]
  local y = cur_mino[side][2][2]
  local temp_depth = 0
  local i,j,k
  for i = y, height-edge do --整图纵向搜索
    local counter = 0
    if counter_lock == true then
      break
    end
    for j = x, x+3 do --整图限制x横向搜索
      for k = 1, 4 do --temp纵向搜索
        if temp_mino[j-x+1][k] ~= 0 and maps[side][1][j][i+k-1] == false and map_edge[side][j][i+k-1] == false then
          counter = counter+1
        elseif temp_mino[j-x+1][k] ~= 0 and (maps[side][1][j][i+k-1] == true or map_edge[side][j][i+k-1] == true) then
          counter_lock = true
          break
        end
      end
      if counter_lock == true then
        break
      end
    end
    if counter == 4 then
      temp_depth = i
    end
  end
  
  cur_distance = temp_depth - cur_mino[side][2][2] --刷新当前最短距离
  
  for i = x,x+3 do
    for j = temp_depth, temp_depth + 3 do
      if temp_mino[i-x+1][j-temp_depth+1] ~= 0 then
        love.graphics.rectangle("line", i*size+(-560+680*side)*env, 10+(j)*size, size-2, size-2, 5*env, 5*env)
      end
    end
  end
  
  release(temp_mino)
  
  local endtime = os.clock();
  local temp_timer_debug = {"func:draw_ghost d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end


function merge_map(map_src, map_tgt)
  for x = 1,width do
		for y = 1,height do
      if map_src[x][y] == true then
        map_tgt[x][y] = true
      end
    end
	end 
end

function refresh_map(map_type, form, pos) --更新图
  for x = 1,width do
    if x >= pos[1] and x <= pos[1]+3 then
      for y = 1,height do
        if y >= pos[2] and y <= pos[2]+3 then
          if form[x-pos[1]+1][y-pos[2]+1] ~= 0 then
            map_type[x][y] = true
          end
        end
      end
		end
	end 
end

function maps_init()
  maps = {{{},{}},{{},{}}}
  map_edge= {{},{}}
  setupMap()
end

function end_game()
  local i,j,k
  for k = 1,2 do
    for j = -2,1 do
      for i = 1+edge,width-edge do
        if maps[k][1][i][j] then return k end --返回终局方
      end
    end
  end
  return 0
end


