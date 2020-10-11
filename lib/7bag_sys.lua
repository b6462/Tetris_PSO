local bag_size = 7
local bag_counter = {0,0} --{counter_1, counter2}
local rnd_bag = {{{},{}},{{},{}}} --{{rnd_bag_L_1, rnd_bag_L_2},{rnd_bag_R_1, rnd_bag_R_2}}
local nextMap = {{},{}}
local depth = 4 --预见深度
local temp_mino = {{{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}},{{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}}
local hold_bag = {0,0}

------debug------
local debug_true_check = 0
local debug_pick_trail = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local debug_bag_trail = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local trial_counter = 0
local pick_counter = 1

function bag_init()
  bag_size = 7
  bag_counter = {0,0} --{counter_1, counter2}
  rnd_bag = {{{},{}},{{},{}}} --{{rnd_bag_L_1, rnd_bag_L_2},{rnd_bag_R_1, rnd_bag_R_2}}
  nextMap = {{},{}}
  depth = 4 --预见深度
  temp_mino = {{{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}},{{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}}
  hold_bag = {0,0}
end


function shuffle(t)
    if type(t)~="table" then
        return
    end
    local tab={}
    local index=1
    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

function refresh_bag(LR, OT) --left/sight one/two
  rnd_bag[LR][OT] = {1,2,3,4,5,6,7}
  rnd_bag[LR][OT] = shuffle(rnd_bag[LR][OT])
  
  local d = 0
  for d = 1,7 do
    debug_bag_trail[trial_counter + d] = rnd_bag[LR][OT][d] --debug
  end
  trial_counter = trial_counter + 7
end


function bag_pick(side) --side: 1:left 2:right
  local t = bag_counter[side]
  if t == 0 then
    refresh_bag(side, 1)
    refresh_bag(side, 2)
  elseif t == bag_size then
    refresh_bag(side, 1)
  elseif t == bag_size*2 then
    refresh_bag(side, 2)
  end
  t = (t)%(2*bag_size) + 1
  bag_counter[side] = t
  
  
  return rnd_bag[side][math.floor(t/(bag_size+1))+1][(t-1)%bag_size+1]
end

function setupNextMap(side)
	for x = 1,4 do
    nextMap[side][x] = {}
		for y = 1, 5*depth do
      nextMap[side][x][y] = false
    end
	end
end

function update_next(side)
  local starttime = os.clock();
  for x = 1,4 do
    for y = 1, 5*depth do
      nextMap[side][x][y] = false
      local cur_dep = math.floor((y-1)/5)+1 -- 1~depth
      local dep_counter = bag_counter[side] + cur_dep --1+1 ~ 14+depth
      local t = (dep_counter-1)%(bag_size*2)+1 --化约dep_counter到1~14以内
      temp_mino[side] = pick_mino_next(rnd_bag[side][math.floor(t/(bag_size+1))+1][(t-1)%7+1]) --[side][d_c: 1~7 && 15~ :1 | 8~14 :2][d_c: 1~7:1~7 | 8~14:1~7]
      if y == 1 and x == 1 then
        pick_counter = pick_counter + 1
        --debug_pick_trail[pick_counter] = rnd_bag[side][math.floor(t/(bag_size+1))+1][(t-1)%7+1]
      end
      
      if temp_mino[side][x][y%5] ~=0 and y%5 ~= 0 then
        nextMap[side][x][y] = true
        --debug_true_check = debug_true_check + 1
      end
      love.graphics.print("cur_dep:" .. cur_dep .. "\ndep_counter:" .. dep_counter, 300, 100) --debug
    end
  end
  local endtime = os.clock();
  local temp_timer_debug = {"func:update_next d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end
function draw_next(side)
  love.graphics.setColor(156/255,226/255,255/255,1)
  if side == 1 and game_status_main[1] == 4 then 
    love.graphics.setColor(78/255,113/255,125/255,1)
  elseif side == 2 and game_status_main[1] ~=4 then 
    love.graphics.setColor(78/255,113/255,125/255,1)
  end
  local size = 40 * env
  for x = 1,4 do
    for y = 1, 5*depth do
      local how = nextMap[side][x][y] and "fill" or "line" --false compare
      if nextMap[side][x][y] == true then
        love.graphics.rectangle(how, x*size+(-60+680*side)*env, y*size+400*env, size-2, size-2, 5, 5)
      end
    end
  end
end




function AI_get_next(side, amount) --用于AI获取预见块
  local dep_counter = bag_counter[side] + amount --1+1 ~ 14+depth
  local t = (dep_counter-1)%(bag_size*2)+1 --化约dep_counter到1~14以内
  local AI_mino = {}
  AI_mino = rnd_bag[side][math.floor(t/(bag_size+1))+1][(t-1)%7+1]
  return AI_mino
end

function hold(side)
  if hold_bag[side] == 0 then
    hold_bag[side] = mino[side][1]
    clear_map(maps[side][2])
    cur_mino[side][1] = pick_mino(side) --获取新块
    cur_mino[side][2] = {6,edge} --设定初始位置
    game_status_main[side] = 2 --进入下落状态
    update_next(side) --更新预见方块列表
    hold_checker[side] = 1
  else
    local temp = mino[side][1]
    mino[side][1] = hold_bag[side]
    mino[side][2] = SOF
    cur_mino[side][1] = pick_mino_next(hold_bag[side])
    hold_bag[side] = temp
    cur_mino[side][2] = {6,edge} --设定初始位置
    hold_checker[side] = 1
  end
end


function draw_hold(side)
  love.graphics.setColor(156/255,226/255,255/255,1)
  local x, y
  local size = 40 * env
  local temp = {}
  if side == 1 and game_status_main[1] == 4 then love.graphics.setColor(78/255,113/255,125/255,1)
  elseif side == 2 and game_status_main[1] ~=4 then love.graphics.setColor(78/255,113/255,125/255,1)
  end
  
  if hold_bag[side] ~= 0 then 
    temp = pick_mino_next(hold_bag[side])
    for x = 1, 4 do
      for y = 1, 4 do 
        if temp[x][y] ~= 0 then        
          love.graphics.rectangle("fill", x*size+(-60+680*side)*env, y*size+100*env, size-2, size-2, 5, 5)
        end
      end
    end
  end
end

function draw_bag_debug_20200825()
  love.graphics.print("bag_1: " .. table.concat(rnd_bag[1][1]), 10, 150)
  love.graphics.print("bag_2: " .. table.concat(rnd_bag[1][2]), 10, 170)
  love.graphics.print("bag_counter:" .. bag_counter[1], 10, 180)
  love.graphics.print("true_check: " .. debug_true_check, 10, 190)
  love.graphics.print("debug_trail_1: " .. table.concat(debug_bag_trail), 200, 1)
  love.graphics.print("debug_trail_2: " .. table.concat(debug_pick_trail), 200, 11)
  
end






