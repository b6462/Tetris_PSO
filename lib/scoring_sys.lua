local BTB_counter = {0,0}
local combo_counter = {0,0}

function getCombo(side)
  return combo_counter[side]
end

score_value = {{0,0},{0,0}} --{left{score,send\recv},right{score,send\recv}}

local debug_cut = 0
local debug_score = {0,0,0,0}

local game_level = 1 --决定gravity与scoring



local combo = { --combo增值 counter 0~12~
  0,0,1,2,4,6,9,12,16,20,24,29,34
  }

local score = {
  100, --1-single
  300, --2-double
  500, --3-triple
  800, --4-tetris
  100, --5-mini_T-spin
  200, --6-mini_T-spin_single
  400, --7-T-spin
  800, --8-T-spin_single
  1200,--9-T-spin_double
  1600,--10-T-spin_triple
  2000,--11-Perfect_clear
  0.5, --12-BTB
  100 --13-combo
  }


local elim = { --己方receiving的削减数，负向溢出值为反击数
  0, --1-single
  1, --2-double
  2, --3-triple
  4, --4-tetris
  0, --5-mini_T-spin
  0, --6-mini_T-spin_single
  0, --7-T-spin
  2, --8-TSS
  4, --9-TSD
  6, --10-TST
  10,--11-PC
  1, --12-BTB
  1  --13-combo
  }



function score_plt(side, s_num) --方位 消行类型
  debug_cut = debug_cut + 1
  debug_score[debug_cut] = s_num
  score_value[side][1] = score_value[side][1] + score[s_num]*game_level*(1+score[12]*BTB_counter[side]*game_level) + score[13]*combo[((combo_counter[side]<=12 and combo_counter[side]) or 12)+1]
  score_value[side][2] = score_value[side][2] - elim[s_num]*game_level - elim[12]*BTB_counter[side] - elim[13]*combo[((combo_counter[side]<=12 and combo_counter[side]) or 12)+1]*game_level
end
function scoring(side, num) 
  
  local l_num = 0
  l_num = num --消行量计数器
  local i,j = 0
  
  local PC_counter = 0 --全消counter
  for i = 1,width do
    for j = 1,height - l_num do
      if maps[side][1] == false then 
        PC_counter = PC_counter + 1 
      end
    end
  end
  
  
  if l_num == 0 and mino[side][1] ~= 2 then --因为T-spin不消行也算分
    combo_counter[side] = 0 --连击计数器
    
  elseif PC_counter == width*(height-l_num) then --11-PerfectClear (+BTB +combo +special)
    score_plt(side,11) --score要在counter更新之前
    BTB_counter[side] = BTB_counter[side] + 1
    combo_counter[side] = combo_counter[side] +1
    
    
  elseif mino[side][1] == 2 then --possible T_spin
    local pos = {}
    local dir = 0
    pos = clone(cur_mino[side][2],true)
    dir = mino[side][2]
    local sides = {false,false,false,false} --ABCD
    local i = 0
    for i = 1,4 do
      local x = pos[1]+2*math.floor(((i-1)%3+1)/2)
      local y = pos[2]+2*math.floor(i/3)
      sides[i] = maps[side][1][x][y] or map_edge[side][x][y] --1234:x->0220 y->0022
      --print("orig_pos:" .. pos[1],pos[2] .. " ser_pos:" .. x,y .. " get" .. ((sides[i] and 1) or 0))
    end
    --print("A:[" .. ((sides[1] and 1) or 0) .. "] B:[" .. ((sides[2] and 1) or 0) .. "] C:[" .. ((sides[3] and 1) or 0) .. "] D:[" .. ((sides[4] and 1) or 0) .. "]")
    --print("dir:" .. dir)
    sides = moveLeft(sides, dir-1)
    --print("A:[" .. ((sides[1] and 1) or 0) .. "] B:[" .. ((sides[2] and 1) or 0) .. "] C:[" .. ((sides[3] and 1) or 0) .. "] D:[" .. ((sides[4] and 1) or 0) .. "]")
    
    
    if sides[1] and sides[2] and (sides[3] or sides[4]) and rotateIsLast then --(A and B + (C or D)) T-spin(+BTB +combo +special) _FLAWED
      --print("T-spin")
      if l_num == 0 then --TS
        score_plt(side,7)
      elseif l_num == 1 then --TSS
        BTB_counter[side] = BTB_counter[side] + 1
        combo_counter[side] = combo_counter[side] + 1
        score_plt(side,8)
      elseif l_num == 2 then --TSD
        BTB_counter[side] = BTB_counter[side] + 1
        combo_counter[side] = combo_counter[side] + 1
        score_plt(side,9)
      elseif l_num == 3 then --TST
        BTB_counter[side] = BTB_counter[side] + 1
        combo_counter[side] = combo_counter[side] + 1
        score_plt(side,10)
      end
    
    
    elseif sides[3] and sides[4] and (sides[1] or sides[2]) and rotateIsLast then --C and D + (A or B) mini_T-spin (+BTB +combo)
      --print("mini_T-spin")
      if l_num == 0 then --MTS
        score_plt(side,5)
      elseif l_num == 1 then --MTSS
        score_plt(side,6)
        BTB_counter[side] = BTB_counter[side] + 1
        combo_counter[side] = combo_counter[side] + 1
      end
    elseif num == 0 then--l_num==0且无T-spin
      combo_counter[side] = 0
    else 
      score_plt(side,l_num)
      BTB_counter[side] = 0
      combo_counter[side] = combo_counter[side] + 1 
    end
    
  elseif l_num == 4 then --possible Tetris (+BTB +combo +special)
    score_plt(side,4)
    BTB_counter[side] = BTB_counter[side] + 1
    combo_counter[side] = combo_counter[side] + 1    
  elseif l_num ~= 0 then --normal elimination (+combo -BTB)
    score_plt(side,l_num)
    BTB_counter[side] = 0
    combo_counter[side] = combo_counter[side] + 1    
  end
  rotateIsLast = false
end

function scoring_init()
  BTB_counter = {0,0}
  combo_counter = {0,0}
  score_value = {{0,0},{0,0}} --{left{score,send\recv},right{score,send\recv}}
  debug_cut = 0
  debug_score = {0,0,0,0}

end

function draw_score(side)
  love.graphics.setFont(font_big)
  love.graphics.print("score:" .. score_value[side][1] .. "\nsend/recv:" .. score_value[side][2], 150*env+(side-1)*700*env, 970*env, 0, 1,1)
  love.graphics.setFont(font_small)
end

function draw_score_debug20200827(side)
  love.graphics.print("scoring: " .. table.concat(debug_score), 10,10)
  love.graphics.print("combo:" .. combo_counter[side] .. "\nBTB:" .. BTB_counter[side], 10, 100)
  love.graphics.print("score:" .. score_value[side][1] .. "\nsend/recv:" .. score_value[side][2], 150*env+(side-1)*700*env, 970*env)
  --love.graphics.print("combo_score:" .. score[13] .. "\nBTB_rate:" .. score[12], 10,550)
end

