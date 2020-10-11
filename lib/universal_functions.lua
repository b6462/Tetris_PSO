function clone(object, deep) --克隆table并返回其克隆
    local copy = {}
    for k, v in pairs(object) do
        if deep and type(v) == "table" then
             v = clone(v, deep)
        end
        copy[k] = v
    end
    return setmetatable(copy, getmetatable(object))
end

function moveUp(table, n)
    if type(table) ~= "table" then return end
    if #table == 0 then return end
 
    local temp = {false}
    for i = 1, #table do
        temp[i-n] = table[i] --1 
    end
    return temp
end

function moveLeft(table, n) --数组横移 用于T-spin四向ABCD定位
    if type(table) ~= "table" then return end
    if #table == 0 then return end
 
    local temp = {0,0,0,0}
    for i = 1, #table do
        temp[(n-1+i) % #table + 1] = table[i] --1 
    end
    return temp
end

function release(resource) --释放table等待collectgarbage函数回收
  if type(resource) == “table” then
    for k,v in pairs do
      if type(v) == “table” then
        release(v)
      else
        resource[k] = nil
      end
    end
  else
    resource = nil     
  end
end

local function AI_s_1()
  if erodedPieceCellsMetric ~= 0 then
    print("mino:" .. mino)
    print("before")
    for j = 15,height do
      local temp_horz = {}
        for i = 1,width do
          if map[i][j] == true then
            temp_horz[i] = '■'
          else
            temp_horz[i] = '□'
          end                
        end
      print(table.concat(temp_horz))
    end
    print("\nafter")
    for j = 15,height do
      local temp_horz = {}
        for i = 1,width do
          if temp_merge[i][j] == true then
            temp_horz[i] = '■'
          else
            temp_horz[i] = '□'
          end                
        end
      print(table.concat(temp_horz))
    end
    print("landingHeight = " .. landingHeight)
    print("ePCM:" .. erodedPieceCellsMetric .. "\ndis_line:" .. dis_line .. "\ndis_mino:" .. dis_mino) 
    print("\n\n")
  end
end
