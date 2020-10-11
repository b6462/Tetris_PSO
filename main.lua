-------------------------------------------init--------------------------------
dis_width, dis_height = love.window.getDesktopDimensions( display )
env = 0.8 --0.8:PC 0.2:gameshell
cur_mino = {{0,{0,0}},{0,{0,0}}} --{{L_shap_dict,{pos_x,pos_y}},{R_shap_dict,{pos_x,pos_y}}}
temp_mino = {{0,{0,0}},{0,{0,0}}}
hold_checker = {0,0}
AI_moving = {false,false}
local key_CD_marker = 0 --0:onhold 1:cooling
local atr_counter = {0,0,0,0} --四个方向的auto_repeat时间计数器
local atr_time = 0.18 --auto_repeat触发计时器时长(s)
local OTL = false --one time only计数器用于在第一次的时候跳过exchange
local AI_pos = {0,0,0,{}} --AI路径规划中间值
math.randomseed(os.time())

require "lib/mino"
require "lib/kickList"
require "lib/7bag_sys"
require "lib/scoring_sys"
require "lib/generator_sys"
require "lib/stat"
require "lib/keys"
require "lib/maps"
require "lib/process"
require "lib/universal_functions"
require "lib/timer"
require "lib/AI_search"
require "lib/PSO_sys"



-----------------------input-------------------
local function quit()
  love.event.quit()
end
local function restart()
  maps_init()
  bag_init()
  mino_init()
  scoring_init()
  stat_init()
  keys_init()
  setupMap()
  setupNextMap(1)
  setupNextMap(2)
  OTL = false
  
  --------Left---------
  D_value_map(1)
  merge_map(maps[1][2], maps[1][1])
  cur_mino[1][1] = pick_mino(1) --获取新块
  temp_mino[1][1] = cur_mino[1][1]
  cur_mino[1][2] = {6,edge} --设定初始位置
  game_status_main[1] = 2 --进入下落状态
  update_next(1) --更新预见方块列表
  hold_checker[1] = 0
  
  --------Right---------
  D_value_map(2)
  merge_map(maps[2][2], maps[2][1])
  cur_mino[2][1] = pick_mino(2) --获取新块
  temp_mino[2][1] = cur_mino[2][1]
  cur_mino[2][2] = {6,edge} --设定初始位置
  game_status_main[2] = 2 --进入下落状态
  update_next(2) --更新预见方块列表
  hold_checker[2] = 0
end


local switch_keys = {
    z = z_press,
    x = x_press,
    j = hold_press,
    k = hold_press,
    u = z_press,
    i = x_press,
    down = down_press,
    up = up_press,
    left = left_press,
    right = right_press,
    escape = quit,
    lshift = hold_press,
    rshift = hold_press,
    space = restart,
    g = garbage_test
  }

function love.keypressed(key)
  if key_CD_marker == 0 then
    key_press = switch_keys[key] 
    key_CD_marker = 1
  end
  --key_press对应程序必须在update中执行 不然会抢在active_map刷新clear之前触发移动而导致嵌入墙体
end
  
function love.keyreleased(key)
  atr_counter = {0,0,0,0}
end


local function input(side,dt)
  if key_press then
    key_press(side)
    key_press = nil --置空防止持续触发
    key_CD_marker = 0
  end
  
  --这段用于计时按键时长以触发auto_repeat
	if love.keyboard.isDown("return") then
    

  elseif love.keyboard.isDown("down") then
    atr_counter[2] = atr_counter[2] + dt
    if atr_counter[2] >= atr_time then
      down_press(side)
    end
	elseif love.keyboard.isDown("left") then
    atr_counter[3] = atr_counter[3] + dt
    if atr_counter[3] >= atr_time then
      left_press(side)
    end
	elseif love.keyboard.isDown("right") then
    atr_counter[4] = atr_counter[4] + dt
    if atr_counter[4] >= atr_time then
      right_press(side)
    end
  end
end
-----------------------main frame--------------
function love.load()
  font_big = love.graphics.newFont("data/fonts/AdobeGothicStd.otf", 50*env)
  font_small = love.graphics.newFont("data/fonts/AdobeGothicStd.otf", 20*env)
  BG = love.graphics.newImage("data/sprites/BG.png")
	setupMap()
  setupNextMap(1)
  setupNextMap(2)
  

  keys_init()
  --love.window.setMode (dis_width * env, dis_height * env)
  love.window.setMode (1600 * env, 1200 * env)
  PSO_init()
end

function love.update(dt)
  --lag_check(dt) --卡顿记录
  --lag_reset()
  local i = 1
  for i = 1,2 do
    -------main-------
    if game_status_main[i] == 3 then
      D_value_map(i)
      merge_map(maps[i][2], maps[i][1])
      cur_mino[i][1] = pick_mino(i) --获取新块
      temp_mino[i][1] = cur_mino[i][1]
      cur_mino[i][2] = {6,edge} --设定初始位置
      --game_status_main[i] = 2 --进入下落状态
      update_next(i) --更新预见方块列表
      hold_checker[i] = 0
      game_status_main[i] = 4
    end
    if game_status_main[i] == 2 then 
      if i == 1 then --single_player
      --if false then --AI-AI
        ------player_L------
        clear_map(maps[i][2])
        if game_status_main[1] == 2 then
          input(1,dt)
        --elseif game_status_main[2] == 2 then
          --input(2,dt)
        end
        refresh_map(maps[i][2], cur_mino[i][1], cur_mino[i][2])
      elseif i == 2 and game_status_main[1] ~= 2 and game_status_main[2] == 2 then --single_player
      --elseif i == 1 or (game_status_main[3-i] ~= 2 and game_status_main[i] == 2) then --AI-AI
        ------player_R------
        if AI_moving[i] == false then
          --love.timer.sleep(0.05) --AI-AI
          AI_pos = AI_main(i, maps[i][1], mino[i][1], getCombo(i))
          --print("rec_AI_pos:" .. table.concat(AI_pos))
          AI_moving[i] = true
        elseif AI_moving[i] then
         ----------route----------
         routeOrg(AI_pos[4], i)
         clear_map(maps[i][2])
         refresh_map(maps[i][2], cur_mino[i][1], cur_mino[i][2])
         ----------route----------
       end
      elseif game_status_main[1] == 2 and game_status_main[2] == 2 then 
        
      end
    end
  end
  if game_status_main[1] == 4 and game_status_main[2] == 4 then
      exchange()
      AI_pos = {0,0,0,{}}
      AI_moving = {false,false}
    if OTL then
      exchange(1) --数字无意义
      ALL_starttime = os.clock()
      --PSO_recurr() --PSO_study
    else 
      OTL = false
    end
    local lose = end_game()
    if lose > 0 then
      print("winner:" .. 3-lose)
      ALL_endtime = os.clock()
      --output_stat()
      --PSO_recurr(lose) --PSO_study
      --love.timer.sleep(2) --AI-AI
      restart()
      ALL_starttime = os.clock()
    else
      game_status_main = {2,2}
    end
  end
  
  -------bot--------
	
end
function love.draw()
  local starttime = os.clock();
  love.graphics.setColor(156/255,226/255,255/255,1)
  if env == 0.2 then
    love.graphics.draw(BG, 0, 6, 0, env, env)
  elseif env == 0.8 then
    love.graphics.draw(BG, 0, 0, 0, env, env)
  end
    
    drawMap()
    draw_ghost(1)
    draw_next(1)
    draw_hold(1)
    draw_score(1) 
  
    draw_ghost(2)
    draw_next(2)
    draw_hold(2)
    draw_score(2)
  
  --draw_lag()
  love.graphics.setColor(255/255,255/255,255/255,1)
  --draw_debug_AI()
  --draw_mino_status()
  --draw_score_debug20200827(1)
  --draw_score_debug20200827(2)
  --draw_debug_20200825()
  --draw_bag_debug_20200825()
  --draw_debug_general()
  local endtime = os.clock();
  local temp_timer_debug = {"func:draw d_time:" .. (endtime - starttime) .. "\n"}
  table.insert(timer_debug_list,table.concat(temp_timer_debug))
end