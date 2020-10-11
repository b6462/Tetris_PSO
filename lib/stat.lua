--status: 1:pause 2:dropping 3:lock 4:calculate
game_status_main = {3,3}
ALL_starttime = 0
ALL_endtime = 0
collide_counter = 0

LPM = {0,0}
send_num = {0,0}
recv_num = {0,0}

function output_stat()
  local time = math.floor(ALL_endtime-ALL_starttime)/60
  print("side 1:\nLPM:" .. (LPM[1]/time) .. "\nsend:" .. send_num[1] .."\nrecv:" .. recv_num[1])
  print("side 2:\nLPM:" .. (LPM[2]/time) .. "\nsend:" .. send_num[2] .."\nrecv:" .. recv_num[2])
end



function stat_init()
  game_status_main = {3,3}
  collide_counter = 0
  LPM = {0,0}
  send_num = {0,0}
  recv_num = {0,0}
end


-------debug---------
mass_debug = ""


str_kick_list = {}
for i = 1,5 do
  str_kick_list[i] = {0,0}
end
str_cur_kick_list = {{0,0},{0,0},{0,0},{0,0},{0,0}}

str_map_L = {}
str_map_temp = {}
str_map_edge = {}

str_temp_mino = {{0,0},{0,0},{0,0},{0,0},{0,0}}


function draw_debug_20200825()
  love.graphics.print("kicklist/temp", 250,0)
  
  for i = 1,5 do
    love.graphics.print("(" .. str_kick_list[i][1] .. "," .. str_kick_list[i][2] .. ")", 250, 10*i)
    --love.graphics.print("(" .. #str_temp_mino .. ")", 300, 10*i)
    love.graphics.print("(" .. str_temp_mino[i][1] .. "," .. str_temp_mino[i][2] .. ")", 300, 10*i)
    love.graphics.print("(" .. str_cur_kick_list[i][1] .. "," .. str_cur_kick_list[i][2] .. ")", 350, 10*i)
  end
  --love.graphics.print("cur_kicklist\n(" .. table.concat(str_cur_kick_list) .. ")", 350,0)
  
  for i = 1,width do
      for j = 1,height do
        if str_map_temp[i][j] == true then
          love.graphics.print("1", i*10+400, j*10+0)
        else
          love.graphics.print("0", i*10+400, j*10+0)
        end
        if str_map_edge[i][j] == true then
          love.graphics.print("1", i*10+600, j*10+0)
        else
          love.graphics.print("0", i*10+600, j*10+0)
        end
        
        if str_map_edge[i][j] == true and str_map_temp[i][j] == true then
          love.graphics.print("collide", 800,0)
        end
        
      end
  end
  if col_check(str_map_edge, str_map_temp) == false then 
    love.graphics.print("checker says none collid", 800, 10)
  end
  
  
  
    for i = 1,width do
      for j = 1,height do
        if maps[1][2][i][j] == true then
          love.graphics.print("1", i*10+20, j*10+120)
        else
          --love.graphics.print("0", i*10+20, j*10+120)
          end
      end
    end
    
    for i = -2,width+2 do
      for j = -4,height do
        if map_edge[1][i][j] == true then
          love.graphics.print("0", i*10+20, j*10+120)
        else
          love.graphics.print(" ", i*10+20, j*10+120)
          end
      end
    end
    
    if marker == true then love.graphics.print("marker: TRUE", 50, 0)
    else love.graphics.print("marker: FALSE", 50 ,0)
    end
  
end

function draw_debug_general()
  love.graphics.print(
      "\ncur_mino[1] pos_x" .. cur_mino[1][2][1] ..
      "\ncur_mino[1] pos_y" .. cur_mino[1][2][2] ..
      "\ncollide_counter" .. collide_counter
      , 0, 500)
    
    
    for i = 1,4 do
      for j = 1,4 do
        love.graphics.print( cur_mino[1][1][i][j], i*10, j*10+450)
      end
    end
    
    for i = 1,4 do
      for j = 1,4 do
        love.graphics.print(temp_mino[1][1][i][j]
      , i*10+80, j*10+450)
      end
    end
end

