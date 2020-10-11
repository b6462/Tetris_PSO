local AI_level = 3 --预见深度/决定对估值排序取其前几位
local recurr_depth = 0
local PD_eval_num = {0,0,0,0,0,0}
local mid_maneuver_list = {} --操作栈 0:N\A 1:↑ 2:↓ 3:← 4:→ 5:左转 6:右转 7:hold
local combo_counter = {}
local BTB_counter = {}
local prev_depth = {}
local temp_route_stack = 0

local function findRow(map)
  local i,j,k,l
  l = 0
  local row = {0,0,0,0}
  for i = 1,height-1 do
    k = 0
    for j = 2,11 do
      if map[j][i] == true then
        k = k+1
      end
    end
    if k == 10 then
      l = l+1
      row[l] = i
    end
  end
  
  return row
end


local function cleaning(map, rows)
  local t = 1
  local clean_counter = 0
  for t = 1,4 do
    if rows[t] ~= 0 then
      clean_counter = clean_counter+1
      local r = rows[t]
      local x = 0
      for x = 1+edge, width-edge do
        map[x][r] = false
        local y = 0
        for y = r-1, 1+edge, -1 do
          if map[x][y] == true then
            map[x][y+1] = true
            map[x][y] = false
          end
        end        
      end
    end
  end
  return clean_counter
end

function AI_init()
  recurr_depth = 0
  combo_counter = {}
  BTB_counter = {}
  prev_depth = {}
end


local function evaluate_PD(edge, mino, map, depth, side) --Pierre Dellacherie算法估值模式 版本0.1.1 原初模式 未添加额外参数
  --获取边缘位置坐标 当前mino编号 底层基本地形 返回result.score result.pos{x,y,dir}
  local result = {} --参考因素：对方的send/recv,自己的send/recv,自己的BTB/combo,地形,可能的SRS特殊攻击,当前深度（越深权重越大，因为越前视越有潜力）
  --print("eval get edge:" .. edge[1] .."," .. edge[2] .. "," .. edge[3] .. ")")
  if edge == {0,0,1} or edge == nil then 
    result.score = -200000
    result.pos = {0,0,1}
    return result
  end
  
  local temp_mino = AI_pick_mino(mino, edge[3])
  local temp_merge = clone(map, true)
  refresh_map(temp_merge, temp_mino, {edge[1],edge[2]})
  merge_map(map_edge[2], temp_merge)
  local i,j,k
  
  
  ----------landingHeight----------
  local landingHeight = 0
  local temp_height = edge and (height-1-edge[2]) or 100
  if temp_height == 100 then
    landingHeight = 100
  else
    local t = false
    for j = 1,4 do --depth
      for i = 1,4 do
        if temp_mino[i][j] ~= 0 then 
          temp_height = temp_height - j + 1
          t = true
          break
        end
      end
      if t then break end
    end
  end
  landingHeight = temp_height + 1
  
  ----------landingHeight----------
  
  
  ----------erodedPieceCellsMetric----------
  
  local dis_line = 0 --消行数
  local dis_mino = 0 --mino消行贡献数
  
  for j = 1,4 do --depth
    local line_d = 0
    local mino_d = 0
    for i = 2,11 do --width
      if temp_merge[i][edge[2]+j-1] == true then 
        line_d = line_d+1 
        --print("(" .. i .."," .. (edge[2]+j-1) .. ")")
        end
    end
    
    if line_d == 10 then 
      --print("dis_line y:" .. (edge[2]+j-1))
      dis_line = dis_line + 1
      for k = 1,4 do
        if temp_mino[k][j] ~= 0 then mino_d = mino_d+1 end
      end
      dis_mino = dis_mino + mino_d
    end
  end
  
  local erodedPieceCellsMetric = dis_line*dis_mino
  --此处有debug代码在universal中 代号AI_s_1()
  
  ----------erodedPieceCellsMetric----------
  
  ----------boardRowTransitions----------
  local trans_block = false
  local RT_counter = 0
  for j = 1,height-1 do
    for i = 2,11 do
      if i == 2 then 
        trans_block = temp_merge[i][j]
      else
        if temp_merge[i][j] ~= trans_block then
          RT_counter = RT_counter+1
          trans_block = temp_merge[i][j]
        end
      end
    end
  end
  
  local boardRowTransitions = RT_counter
  
  ----------boardRowTransitions----------
  
  ----------boardColTransitions----------
  
  trans_block = false
  local CT_counter = 0
  for i = 2,11 do
    for j = 1,height-1 do
      if j == 1 then 
        trans_block = temp_merge[i][j]
      else
        if temp_merge[i][j] ~= trans_block then
          CT_counter = CT_counter+1
          trans_block = temp_merge[i][j]
        end
      end
    end
  end
  
  local boardColTransitions = CT_counter
  
  ----------boardColTransitions----------
  
  ----------boardBuriedHoles----------
  
  local BBH_counter = 0
  local BBH_marker = false
  for i = 2,11 do
    BBH_marker = false
    for j = 1,height-1 do
      if temp_merge[i][j] == true then 
        BBH_marker = true
      end
      if temp_merge[i][j] == false and BBH_marker then
        BBH_counter = BBH_counter+1
      end
    end
  end
  
  local boardBuriedHoles = BBH_counter
  
  ----------boardBuriedHoles----------
  
  ----------boardWells----------
  local boardWells = 0
  local BW_counter = 0
  local BW_marker = false
  for i = 2,11 do
    BBH_marker = false
    BW_counter = 0
    for j = 1,height-1 do
      if temp_merge[i][j] == false and temp_merge[i-1][j] and temp_merge[i+1][j] then 
        BW_marker = true
        BW_counter = BW_counter + 1
        boardWells = boardWells + BW_counter
      end
      if temp_merge[i][j] == true then
        BW_marker = false
        BW_counter = 0
      end
    end
  end
  
  
  
  ----------boardWells----------
  
  local cur_height = 0
  for i = 0,height-1 do
    for j = 2,11 do
      if temp_merge[j][i] == true then 
        cur_height = i
        break
      end
    end
    if cur_height ~= 0 then break end
  end
  cur_height = height-cur_height
  
  local disLine = dis_line
  local possibleScore = 0
  local comboNum = combo_counter[depth][1] + ((dis_line>0 and 1) or 0)
  
  
  
  --local value = -45*landingHeight + 34*erodedPieceCellsMetric - 32*boardRowTransitions - 93*boardColTransitions - 79*boardBuriedHoles - 34*boardWells + 20*comboNum
  local list = {landingHeight,erodedPieceCellsMetric,boardRowTransitions,boardColTransitions,boardBuriedHoles,boardWells,comboNum,cur_height}
  local value = PSO_process(list, side)
  result.score = value
  result.pos = edge
  result.detail = {landingHeight, erodedPieceCellsMetric, boardRowTransitions, boardColTransitions, boardBuriedHoles, boardWells}
  return result
end

local function AI_straight_down(map, mino, depth) --和ghost性能相似，将各个方向的mino状态投射到最底层
  --print("mino:" .. mino)
  local i,j,k,l
  local map_top = 0 --获取当前图的最高点,减少遍历次数
  local top_marker = false
  for j = 1, height-edge-1 do
    map_top = map_top + 1
    for i = 2, 11 do
      if map[i][j] == true then
        top_marker = true
        break
      end
    end
    if top_marker == true then break end
  end
  --print("cur_top:" .. map_top)
  
  local mino_dif_l = 0 --区别不同tormino的长宽减少对比次数
  if mino == 1 then mino_dif_l = 4
  elseif mino == 5 then mino_dif_l = 2
  else mino_dif_l = 3 end
  
  
  local temp_pos = {}
  local counter_lock = false --触底marker
  local temp_dir = 1
  for temp_dir = 1,4 do
    for i = 1+edge-(mino_dif_l-2), width-edge-1 do --整图横向搜索 (mino_dif_l-2)是因为他是mino形状数组左边最多空余量，所以要嵌入到edge里才行
      local temp_mino = {}
      temp_mino = AI_pick_mino(mino, temp_dir)
      local counter = 0
      local temp_h = 0
      local temp_h_count = 0
      counter_lock = false
      for j = ((map_top-mino_dif_l)>0 and (map_top-mino_dif_l)) or 1, height-edge do --整图从所得top开始纵向搜索
        temp_h_count = j
        --print("edge_sch:(" .. i .. "," .. j .. "," .. temp_dir .. ")")
        counter = 0
        for k = 1, mino_dif_l do --temp遍历
          for l = 1, mino_dif_l do
            if temp_mino[k][l] ~= 0 and map[i+k-1][j+l-1] == false and map_edge[2][i+k-1][j+l-1] == false then
              counter = counter+1
            elseif temp_mino[k][l] ~= 0 and (map[i+k-1][j+l-1] == true or map_edge[2][i+k-1][j+l-1] == true) then
              counter_lock = true
              break
            end
          end
          if counter_lock == true then break end
        end
        if counter == 4 then temp_h = j end
        if counter_lock == true then break end
      end
      if temp_h ~= 0 then
        if depth == 1 then
          local l = 0
          local d_horz = i-6 --横移量
          table.insert(mid_maneuver_list, (temp_dir==1 and 0) or (temp_dir==3 and 6) or (temp_dir==2 and 6) or (temp_dir==4 and 5)) --录入旋转
          if temp_dir == 3 then table.insert(mid_maneuver_list, 6) end
          for l = 1,(math.abs(d_horz)>0 and math.abs(d_horz) or 1)do
            table.insert(mid_maneuver_list,(d_horz>0 and 4) or (d_horz<0 and 3) or (0))
          end
          for l = 1,(temp_h-1>1 and temp_h or 1)do
            table.insert(mid_maneuver_list,2)
          end
          --print(table.concat(mid_maneuver_list))
          temp_pos[(i-1)*4+temp_dir] = {i,temp_h,temp_dir,mid_maneuver_list} --记录所有可以纵向落入的位置以及其操作栈
          mid_maneuver_list = {}
        else
          temp_pos[(i-1)*4+temp_dir] = {i,temp_h,temp_dir}
        end
        --print("edge_sch:(" .. i .. "," .. temp_h .. "," .. temp_dir .. ") able, temp_pos[" .. ((i-1)*4+temp_dir) .. "]")
        counter = 0
      elseif counter_lock then --说明无法落下
        --print("edge_sch:(" .. i .. "," .. temp_h_count .. "," .. temp_dir .. ") unable, temp_pos[" .. ((i-1)*4+temp_dir) .. "]")
        counter = 0
        temp_pos[(i-1)*4+temp_dir] = {0,0,1}
      end
      
    end
  end
  --上述运算量平均约为4*(width-edge-1-1-edge+(4+2+3*5)/7-2)*h*3^2 = 360*h 其中h为地形高度差
  --生成table：temp_pos大小约为40
  --for i = 1,#temp_pos do --接下来判断每个落下点旋转/左右平移的结果 将结果的(坐标,方向)与已有temp_pos比对 如果不同且贴地则更新到记录中 再次旋转/平移 递归直到全部计算完毕
    
  --end
  return temp_pos
end

local function cmp_list(list, target) --用来比对新位置是否在list中 或者是否高于已有元素位置
  local i
  local marker = true
  for i = 1,#list do
    if list[i] then
      if list[i][1] == target[1] and list[i][3] == target[3] and list[i][2] <= target[2] then 
        marker = false
        break
      end
    end
  end
  return marker
end


local function AI_move_turn(map, mino, list) --在确认所有直降位置之后 左右移动、旋转 与表单做比对直到获得所有可能 最后更新表单
  local i,j,k
  local dif = 0 --区别不同tormino的长宽减少对比次数
  if mino == 1 then dif = 4
  elseif mino == 5 then dif = 2
  else dif = 3 end
  ----------检测左右移动----------
  if true then --选false可关闭
    for k = 1, #list do
      if list[k] then
        local temp_map = clone(map, true)
        merge_map(map_edge[2], temp_map)
        local x,y,dir = list[k][1],list[k][2],list[k][3]
        local temp_mino = AI_pick_mino(mino, dir)
        local marker = false
        local temp_pos = {0,0,0}
        local mov = 0
        for mov = -1,1,2 do
          if cmp_list(list, {x+mov,y,dir}) then --先检查左右移动是否已有
            for i = 1,dif do
              for j = 1,dif do
                if temp_map[x+i-1+mov][y+j-1] and temp_mino[i][j]~=0 then
                  marker = true
                  break
                end
              end
              if marker then break end
            end
            if marker == false then 
              if depth == 1 and list[k][4] then 
                mid_maneuver_list = clone(list[k][4],true)
                table.insert(mid_maneuver_list, 3.5+0.5*mov) --3← 4→
                list[#list+1] = {x+mov,y,dir,mid_maneuver_list}
                --print(table.concat(mid_maneuver_list))
                mid_maneuver_list = {}
              else
                list[#list+1] = {x+mov,y,dir}
              end
            end
          end
        end
      end
    end
  end
  
  ----------检查左右SRS----------
  
  if true then
    for k = 1, #list do
      if list[k] then
        local x,y,dir = list[k][1],list[k][2],list[k][3]
        local temp_pos = {0,0,0}
        local turn = 0
        for turn = 0,1 do          
          local kicklist = {}
          kicklist = kick_check(mino,dir,turn) --获取kicklist
          local marker = false
          local n = 1
          for n = 1, 5 do
            local temp_pos = {x+kicklist[n][1], y+kicklist[n][2]}
            if cmp_list(list, {temp_pos[1],temp_pos[2],(dir-1+turn*2-1)%4+1}) then --先检查SRS是否已有
              local temp_map = clone(map, true)
              local temp_mino = AI_pick_mino(mino,(dir-1+turn*2-1)%4+1)
              for i = 1,dif do
                for j = 1,dif do
                  if temp_map[temp_pos[1]+i-1][temp_pos[2]+j-1] and temp_mino[i][j]~=0 then
                    marker = true
                    break
                  end
                end
                if marker then break end
              end
              if marker == false then
                if depth == 1 and list[k][4] then
                  mid_maneuver_list = clone(list[k][4],true)
                  table.insert(mid_maneuver_list,turn+5)
                  list[#list+1] = {temp_pos[1],temp_pos[2],(dir-1+turn*2-1)%4+1,mid_maneuver_list}
                  --print(table.concat(mid_maneuver_list))
                  mid_maneuver_list = {}
                else                  
                  list[#list+1] = {temp_pos[1],temp_pos[2],(dir-1+turn*2-1)%4+1}
                end                
              end
            end
          end
        end
      end
    end
  end
end


function routeOrg(stack,side) --执行路线
  local key_data = {up_press,down_press,left_press,right_press,z_press,x_press}
  --操作栈 0:N\A 1:↑ 2:↓ 3:← 4:→ 5:左转 6:右转 7:hold
  if temp_route_stack == 0 then
    temp_route_stack = #stack
  end
  temp_route_stack = temp_route_stack-1
  local i = #stack - temp_route_stack
  if stack[i]~=0 then
    local key_press = key_data[stack[i]]
    key_press(side)
  end
  
  if temp_route_stack == 0 then
    up_press(side)
    AI_moving[side] = false
    AI_init()
    game_status_main[i] = 3
  end
  
end

function AI_main(side, map, mino, combo) --Mino取编号 不是table
  recurr_depth = recurr_depth + 1 --当前递归深度
  combo_counter[recurr_depth] = {combo,combo,combo,combo,combo} --设置combo_counter
  --print("enter depth:" .. recurr_depth)
  local sch_map = clone(map, true)
  local edge = {} --{{x,y,r}, {x,y,r} ,{x,y,r}...} --获取边缘可放置坐标table
  edge = clone(AI_straight_down(sch_map, mino, recurr_depth), true)
  if side == 1 then AI_move_turn(sch_map,mino,edge) end --可限定玩家对比算法
  local i = 0
  local score_recurr = {} --记录递归中前AI_level个判断为估值score
  for i = 1, AI_level do
    score_recurr[i] = 0
  end
  local eval_res = {} --储存估值判断的结果score和位置pos
  for i = 1, #edge do
    --print("cur_eval_edge:{" .. edge[1] .. "," .. edge[2] .. "," .. edge[3] .. "}")
    eval_res[i] = evaluate_PD(edge[i], mino, sch_map, recurr_depth, side) --eval_res[i].score = score, eval_res[i].pos = {x,y,dir}
    --print("eval on {" .. edge[i][1] .. "," .. edge[i][2] .. "," .. edge[i][3] .. "} return with socre:" ..eval_res[i].score)
  end
  table.sort(eval_res,function(a,b) return a.score>b.score end ) --排序
  
  if recurr_depth < AI_level then
    
    for i = 1,5 do --取前几名用来递归
      if eval_res[i].pos[3] ~= 0 then
        --print("under depth:" .. recurr_depth .. " eval i:" .. i)
        local recurr_map = clone(sch_map, true) --制作递归基础地形
        local cur_mino = AI_pick_mino(mino, eval_res[i].pos[3])
        refresh_map(recurr_map, cur_mino, {eval_res[i].pos[1],eval_res[i].pos[2]}) --进入下一步
        local dis = cleaning(recurr_map,findRow(recurr_map))
        if dis~=0 then combo_counter[recurr_depth][i] = combo_counter[recurr_depth][i]+1
        else combo_counter[recurr_depth][i] = 0
        end
        local recurr_mino = AI_get_next(side, recurr_depth) --按当前递归深度取对应mino
        score_recurr[i] = AI_main(side, recurr_map, recurr_mino,  combo_counter[recurr_depth][i]) --递归
        --print("score_recurr after: " .. table.concat(score_recurr))
      end
    end
  else
    --print("end at depth:" .. recurr_depth .. " with result:" .. eval_res[1].score)
    recurr_depth = recurr_depth - 1
    return eval_res[1].score --如果递归进行到最后一步 则返回最大值score对应项
  end
  if recurr_depth ~= 1 then
    table.sort(score_recurr,function(a,b) return a>b end ) --如果不是第一层则返回最大值即可
    recurr_depth = recurr_depth - 1
    return score_recurr[1]
  else 
    --print("score_recurr after: " .. table.concat(score_recurr))
    --排序score_recurr 取最大的值对应在eval_res里的pos返回
    for i = 1,AI_level do
      eval_res[i].score = score_recurr[i]
      table.sort(eval_res,function(a,b) return a.score>b.score end ) --如果不是第一层则返回最大值即可
    end
    PD_eval_num = eval_res[1].detail
    return eval_res[1].pos --如果是第一层，则返回score综合最大值的pos{x,y,dir}
  end
  release(sch_map)
  release(edge)
  release(eval_res)
  release(recurr_map)
end

function draw_debug_AI()
  love.graphics.setColor(156/255,226/255,255/255,1)
  love.graphics.print("landingHeight:" .. PD_eval_num[1] .. "\nerodedPieceCellsMetric:" .. PD_eval_num[2] .. "\nboardRowTransitions:" .. PD_eval_num[3] .. "\nboardColTransitions:" .. PD_eval_num[4] .. "\nboardBuriedHoles:" .. PD_eval_num[5] .. "\nboardWells:" .. PD_eval_num[6])
end

