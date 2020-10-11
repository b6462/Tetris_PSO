local vmax = 5 --速度最大值
local pos_edge_max = 100
local c1,c2 = 2,2 --学习因子
local pos = {{},{}} --位置
local vel = {{},{}} --速度
local dim = {-47.612702270687,67.109541046541,-33.117974415048,-99.28384,-35.157173005567,-26.872396765039,-8.2723599725071,-6.0399332153073}
local dim_bef = {-45,34,-32,-93,-79,-34,0,0}
--local dim_bef = {-45,34,-32,-93,-79,-34,0,0}
local dim_num = #dim --每个粒子的维度数
local pbest = {{},{}} --personal best 个体最优值
local gbest = {} --global best 全域最优值
local recurr = 1

function PSO_process(list,side)
  local value = 0
  local i
  if side == 1 then
    for i = 1,#list do
      value = value + list[i]*pos[side][i] --学习
      --value = value + list[i]*dim[i] --验证
    end
    return value
  elseif side == 2 then
    for i = 1,#list do
      value = value + list[i]*pos[side][i] --学习
      --value = value + list[i]*dim_bef[i] --验证
    end
    return value
  end
end


local function PSO_eval(side,lose) --对particle在list中对应各维度值进行综合评估，获取对应粒子适应度/评估值
  local time = math.floor(ALL_endtime-ALL_starttime)/60
  local result = (LPM[side]/time) + math.abs(send_num[side]) - math.abs(recv_num[side]) +(side ~= lose and 10 or 0)
  return result
end

function PSO_init()
  local i
	for i = 1, dim_num do --设置各维度初始值
	    local start_vel1 = math.random(-vmax,vmax)
	    local start_vel2 = math.random(-vmax,vmax)
	    vel[1][i] = start_vel1 --预置双方各维初始速度为随机值
	    vel[2][i] = start_vel2
      
	end
  pos[1] = clone(dim, true)
  pos[2] = clone(dim_bef, true)
end

function PSO_recurr(lose) --循环更新各粒子位置
	local i,j,k
  if recurr == 1 then --第一次初始化pbest,gbest
    PSO_init()
    local value = {0,0}
    for j = 1,2 do
      value[j] = PSO_eval(j,lose) --返回各个维度适应度/“位置”
      if value[j] then --更新个体最优
        pbest[j] = clone(pos[j],true) --储存全部pos为个体最优值
        table.insert(pbest[j], 1, value[j]) --在开头储存适应度
      end
    end
    gbest = clone(pos[value[1]>value[2] and 1 or 2],true)
    table.insert(gbest, 1, value[value[1]>value[2] and 1 or 2])
    recurr = recurr + 1
    --更新全域最优
  end
  
  if recurr>1 then
    local value = {0,0}
    for j = 1,2 do
      value[j] = PSO_eval(j,lose) --返回适应度/“位置”
      --print("under j=" .. j .." PSO_eval=" .. value[j] .. "\npbest=" .. pbest[j][1])
      if value[j] > pbest[j][1] then --更新个体最优
        pbest[j] = clone(pos[j],true) --储存全部pos为个体最优值
        table.insert(pbest[j], 1, value[j]) --在开头储存适应度
      end
    end
    if value[1]>=value[2] and value[1] > gbest[1] then
      gbest = clone(pos[1],true)
      table.insert(gbest, 1, value[1])
    elseif value[2]>value[1] and value[2] > gbest[1] then
      gbest = clone(pos[2],true)
      table.insert(gbest, 1, value[2])
    end
    if true then
      writeFile('data/PSO_output.txt',os.date("%H:%M:%S\ncur gbest: (" .. table.concat(gbest,",")) .. ")\n\n")
      writeFile('data/PSO_output.txt',"pos[1]: (" .. table.concat(pos[1],",") .. ")\n")
      writeFile('data/PSO_output.txt',"vel[1]: (" .. table.concat(vel[1],",") .. ")\n")
      writeFile('data/PSO_output.txt',"p_best[1]: (" .. table.concat(pbest[1],",") .. ")\n\n")
      writeFile('data/PSO_output.txt',"pos[2]: (" .. table.concat(pos[2],",") .. ")\n")
      writeFile('data/PSO_output.txt',"vel[2]: (" .. table.concat(vel[2],",") .. ")\n")
      writeFile('data/PSO_output.txt',"p_best[2]: (" .. table.concat(pbest[2],",") .. ")\n\n")
      writeFile('data/PSO_output.txt',"value: (" .. table.concat(value,",") .. ")\n\n\n")
    end
  
    print("cur gbest:" .. table.concat(gbest,","))
    --print("cur pos[1]:" .. table.concat(pos[1], ","))
    --print("cur pbest[1]:" .. table.concat(pbest[1], ","))
    --print("cur pos[2]:" .. table.concat(pos[2], ","))
    --print("cur pbest[2]:" .. table.concat(pbest[2], ","))
		local w = 0.4--初始惯性权值
		for j = 1,2 do
			for k = 1,dim_num do
				vel[j][k] = w*vel[j][k]+c1*math.random(0,1)*(pbest[j][k+1]-pos[j][k])+c2*math.random(0,1)*(gbest[k+1]-pos[j][k])
        vel[j][k] = math.abs(vel[j][k])<=vmax and vel[j][k] or math.random(-vmax,vmax) --限速
				pos[j][k] = pos[j][k]+vel[j][k] --更新位置
				pos[j][k] = (pos[j][k]>pos_edge_max and pos_edge_max) or (pos[j][k]<-pos_edge_max and -pos_edge_max) or pos[j][k] --限制范围
			end
		end
    
    recurr = recurr + 1
    --更新全域最优
  end


end



function PSO_clear()
  
end


