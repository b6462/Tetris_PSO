local mino_pos = {0,0} --返回用坐标
mino = {{0,0},{0,0}} --{mino_L{块类,方向},mino_R{块类,方向}}
SOF = 1 --start_of_facing


require "lib/7bag_sys"

--竖列为一小组，横行竖列为一块组
--{0,1,0,0},{0,1,0,0},{0,1,0,0},{0,1,0,0}

--0 0 0 0
--1 1 1 1
--0 0 0 0
--0 0 0 0

TetroI = {
  {{0,1,0,0},{0,1,0,0},{0,1,0,0},{0,1,0,0}}, --north
  {{0,0,0,0},{0,0,0,0},{1,1,1,1},{0,0,0,0}}, --east
  {{0,0,1,0},{0,0,1,0},{0,0,1,0},{0,0,1,0}}, --south
  {{0,0,0,0},{1,1,1,1},{0,0,0,0},{0,0,0,0}}}  --west
TetroT = {
  {{0,6,0,0},{6,6,0,0},{0,6,0,0},{0,0,0,0}},
  {{0,0,0,0},{6,6,6,0},{0,6,0,0},{0,0,0,0}},
  {{0,6,0,0},{0,6,6,0},{0,6,0,0},{0,0,0,0}},
  {{0,6,0,0},{6,6,6,0},{0,0,0,0},{0,0,0,0}}}
TetroJ = {
  {{2,2,0,0},{0,2,0,0},{0,2,0,0},{0,0,0,0}},
  {{0,0,0,0},{2,2,2,0},{2,0,0,0},{0,0,0,0}},
  {{0,2,0,0},{0,2,0,0},{0,2,2,0},{0,0,0,0}},
  {{0,0,2,0},{2,2,2,0},{0,0,0,0},{0,0,0,0}}}
TetroL = {
  {{0,3,0,0},{0,3,0,0},{3,3,0,0},{0,0,0,0}},
  {{0,0,0,0},{3,3,3,0},{0,0,3,0},{0,0,0,0}},
  {{0,3,3,0},{0,3,0,0},{0,3,0,0},{0,0,0,0}},
  {{3,0,0,0},{3,3,3,0},{0,0,0,0},{0,0,0,0}}}
TetroO = {
  {{4,4,0,0},{4,4,0,0},{0,0,0,0},{0,0,0,0}},
  {{4,4,0,0},{4,4,0,0},{0,0,0,0},{0,0,0,0}},
  {{4,4,0,0},{4,4,0,0},{0,0,0,0},{0,0,0,0}},
  {{4,4,0,0},{4,4,0,0},{0,0,0,0},{0,0,0,0}}}
TetroS = {
  {{0,5,0,0},{5,5,0,0},{5,0,0,0},{0,0,0,0}},
  {{0,0,0,0},{5,5,0,0},{0,5,5,0},{0,0,0,0}},
  {{0,0,5,0},{0,5,5,0},{0,5,0,0},{0,0,0,0}},
  {{5,5,0,0},{0,5,5,0},{0,0,0,0},{0,0,0,0}}}
TetroZ = {
  {{7,0,0,0},{7,7,0,0},{0,7,0,0},{0,0,0,0}},
  {{0,0,0,0},{0,7,7,0},{7,7,0,0},{0,0,0,0}},
  {{0,7,0,0},{0,7,7,0},{0,0,7,0},{0,0,0,0}},
  {{0,7,7,0},{7,7,0,0},{0,0,0,0},{0,0,0,0}}}

TrtroDebug = {
  {{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}, --north
  {{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}, --east
  {{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}, --south
  {{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}}

local tetro_pack = {TetroI, TetroT, TetroJ, TetroL, TetroO, TetroS, TetroZ, TrtroDebug}
function mino_init()
  mino_pos = {0,0}
  mino = {{0,0},{0,0}}
  SOF = 1
end

function pick_mino_next(num)
  return tetro_pack[num][SOF]
end

function get_cur_mino(side)
  local temp = tetro_pack[mino[side][1]][mino[side][2]]
  return temp
end

function AI_pick_mino(num, dir)
  local temp_mino = {{1,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
  temp_mino = tetro_pack[num][dir]
  return temp_mino
end


function pick_mino(side) --获取新块注册到本地mino_L组，储存块编号和当前方向，返回形态数组
  mino[side][1] = bag_pick(side) --从bag中获取块编号
  mino[side][2] = SOF --初始方向
  local mino_rec = clone(tetro_pack[mino[side][1]][mino[side][2]], true)
  return mino_rec
end

function rotate_mino(side,dir) --旋转本地mino[side]记录并返回旋转后形态数组
  local temp = mino[side][2]-1+2*dir
  if temp == 0 then mino[side][2] = 4
  elseif temp == 5 then mino[side][2] = 1
  else mino[side][2] = temp --1~4循环
  end
  
  local mino_rec = tetro_pack[mino[side][1]][mino[side][2]]
  --str_rot_mino_L_back = mino_rec --debug
  return mino_rec
end



function req_kicklist(side,dir) --获取mino编号和当前方向与旋转方向，返回5points的kicklist
  local kick_list = {}
  kick_list = kick_check(mino[side][1], mino[side][2], dir) 
  --2020年8月24日 21点35分 此处mino[1][2]的方向 经过之前rotate_mino_L函数 已经变成了转向后的方向 所以会发生嵌入墙壁的问题 因为判断所用的根本是错的
  --通过在main.lua中rotate后直接反向rotate保持方向修正了问题
  --出现新问题 上下边会发生跳跃和嵌入
  return kick_list
end


function col_check(static_map, active_map)
  for x = -2,width+2 do
		for y = -4,height do
      if static_map[x][y] == true and active_map[x][y] == true then
        collide_counter = collide_counter + 1
        return true
      end
		end
	end
  return false --碰撞检测结果
end

function draw_mino_status()
  love.graphics.print(
      "\nmino_L type" .. mino[1][1] ..
      "\nmino_L dir" .. mino[1][2] ..
      "\ngame_status" .. game_status_main[1]
      , 20, 200)
end

