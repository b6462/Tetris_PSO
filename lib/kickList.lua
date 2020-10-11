
--记录kick时tetromino初始方向对应转向方向kick_point的判断次序与尝试位移
--2020年8月24日 21点08分 多次对比嵌入墙内的坐标移动规律后 发现在数组中纵轴是与guideline相反的

k_TetroI = {
  {{0,0},{-2,0},{1,0},{-2,1},{1,-2}}, --north-R
  {{0,0},{-1,0},{2,0},{-1,-2},{2,1}}, --north-L
  {{0,0},{-1,0},{2,0},{-1,-2},{2,1}}, --east-R
  {{0,0},{2,0},{-1,0},{2,-1},{-1,2}}, --east-L
  {{0,0},{2,0},{-1,0},{2,-1},{-1,2}}, --south-R
  {{0,0},{1,0},{-2,0},{1,2},{-2,-1}}, --south-L
  {{0,0},{1,0},{-2,0},{1,2},{-2,-1}}, --west-R
  {{0,0},{-2,0},{1,0},{-2,1},{1,-2}}} --west-L


k_TetroT = {
  {{0,0},{-1,0},{-1,-1},{0,0},{-1,2}}, --north-R -point4=N/U
  {{0,0},{1,0},{1,-1},{0,0},{1,2}}, --north-L -point4=N/U
  {{0,0},{1,0},{1,1},{0,-2},{1,-2}}, --east-R
  {{0,0},{1,0},{1,1},{0,-2},{1,-2}}, --east-L
  {{0,0},{1,0},{0,0},{0,2},{1,2}}, --south-R -point3=N/U
  {{0,0},{-1,0},{0,0},{0,2},{-1,2}}, --south-L -point3=N/U
  {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}}, --west-R
  {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}}} --west-L

k_TetroLJSZ = {
  {{0,0},{-1,0},{-1,-1},{0,2},{-1,2}}, --north-R
  {{0,0},{1,0},{1,-1},{0,2},{1,2}}, --north-L
  {{0,0},{1,0},{1,1},{0,-2},{1,-2}}, --east-R
  {{0,0},{1,0},{1,1},{0,-2},{1,-2}}, --east-L
  {{0,0},{1,0},{1,-1},{0,2},{1,2}}, --south-R
  {{0,0},{-1,0},{-1,1},{0,2},{-1,2}}, --south-L
  {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}}, --west-R
  {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}}} --west-L

k_TetroO = {
  {{0,0},{0,0},{0,0},{0,0},{0,0}}}


local kick_list = {k_TetroI, k_TetroT, k_TetroLJSZ}

--cur_dir: 1-north 2-east 3-south 4-west
--rot_dir: 0_L 1_R

function kick_check(mino_type, cur_dir, rot_dir) --根据当前mino类与所处方向和旋转方向返回尝试point位移序列
  
  local temp = cur_dir*2 - rot_dir
  
  if mino_type == 1 then
    return k_TetroI[temp]
  elseif mino_type == 2 then
    return k_TetroT[temp]
  elseif mino_type == 5 then
    return k_TetroO[1]
  else
    return k_TetroLJSZ[temp]
  end
end


