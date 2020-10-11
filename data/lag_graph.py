# -*- coding: utf-8 -*-
"""
Created on Sat Aug 29 19:14:56 2020

@author: b6462
"""



import numpy as np
from matplotlib import pyplot as plt

with open('lag_output.txt') as file_object:
    lines=file_object.readlines()
     
file1 = []
row = []
for line in lines:
    row = line.split(':')
    file1.append(row)
    
x_time = ['0']
time_d = ['0']
    
time1 = ['0']
time2 = ['0']
time3 = ['0']
time4 = ['0']
time5 = ['0']
time6 = ['0']
time7 = ['0']
time8 = ['0']
time9 = ['0']
time10 = ['0']
time11 = ['0']
time12 = ['0']


time = [time1,time2,time3,time4,time5,time6,time7,time8,time9,time10,time11,time12]


def case1(value):
    del(time1[-1])
    time1.append(value)
    return 1
def case2(value):
    del(time2[-1])
    time2.append(value)
    return 2
def case3(value): 
    del(time3[-1])
    time3.append(value)
    return 3
def case4(value): 
    del(time4[-1])
    time4.append(value)
    return 4
def case5(value): 
    del(time5[-1])
    time5.append(value)
    return 5
def case6(value): 
    del(time6[-1])
    time6.append(value)
    return 6
def case7(value): 
    del(time7[-1])
    time7.append(value)
    return 7
def case8(value): 
    del(time8[-1])
    time8.append(value)
    return 8
def case9(value): 
    del(time9[-1])
    time9.append(value)
    return 9
def case10(value):
    del(time10[-1])
    time10.append(value)
    return 10
def case11(value):
    del(time11[-1])
    time11.append(value)
    return 11
def case12(value):
    del(time12[-1])
    time12.append(value)
    return 12

def default(value):
    print('No such case')


switch = {'AI_search d_time': case1, 
          'D_value_map d_time': case2,    
          'update_next d_time': case3, 
          'draw_map d_time': case4,
          'draw_ghost d_time': case5,
          'draw d_time': case6,
          'up_press d_time': case7,
          'down_press d_time': case8,
          'left_press d_time': case9,
          'right_press d_time': case10,
          'exchange d_time': case11,
          'rotate_key d_time': case12
          }

null_num = '0'

for row1 in file1:
    if row1[0] == '15':
        x_time.append(str((int(row1[1])-3)*60 + int(row1[2])))
        for i in range(0,12):
            time[i].append(null_num)
    elif row1[0] == 'lag_timer':
        time_d.append(row1[1])
    elif row1[0] == 'func':
        choice = row1[1]
        temp = switch.get(choice, default)(row1[2])
        
    
int_time=[]
for str_h in x_time:
    a=float(str_h)
    int_time.append(a)
    

int_time1=[]
for str_h in time1:
    a=float(str_h)
    int_time1.append(a)

int_time2=[]
for str_h in time2:
    a=float(str_h)
    int_time2.append(a)

int_time3=[]
for str_h in time3:
    a=float(str_h)
    int_time3.append(a)

int_time4=[]
for str_h in time4:
    a=float(str_h)
    int_time4.append(a)

int_time5=[]
for str_h in time5:
    a=float(str_h)
    int_time5.append(a)

int_time6=[]
for str_h in time6:
    a=float(str_h)
    int_time6.append(a)

int_time7=[]
for str_h in time7:
    a=float(str_h)
    int_time7.append(a)

int_time8=[]
for str_h in time8:
    a=float(str_h)
    int_time8.append(a)

int_time9=[]
for str_h in time9:
    a=float(str_h)
    int_time9.append(a)

int_time10=[]
for str_h in time10:
    a=float(str_h)
    int_time10.append(a)

int_time11=[]
for str_h in time11:
    a=float(str_h)
    int_time11.append(a)

int_time12=[]
for str_h in time12:
    a=float(str_h)
    int_time12.append(a)

    
int_time_d=[]
for str_h in time_d:
    a=float(str_h)
    int_time_d.append(a)
    
    
fig=plt.figure(figsize=(50,20))
ax1=fig.add_subplot(111) # 将画面分割为1行1列选第一个
ax2=fig.add_subplot(111)

ax1.plot(int_time,int_time_d,label='d_time',c="red")
ax1.plot(int_time,int_time1,label='AI_search()',c="blue")
ax1.plot(int_time,int_time2,label='D_value_map()',c="purple")
ax1.plot(int_time,int_time3,label='update_next()',c="pink")
ax1.plot(int_time,int_time4,label='draw_map()',c="orange")
ax1.plot(int_time,int_time5,label='draw_ghost()',c="cyan")
ax1.plot(int_time,int_time6,label='draw()',c="green")
ax1.plot(int_time,int_time7,label='up_press()',c="black")
ax1.plot(int_time,int_time8,label='down_press()',c="navy")
ax1.plot(int_time,int_time9,label='left_press()',c="tan")
ax1.plot(int_time,int_time10,label='right_press()',c="tomato")
ax1.plot(int_time,int_time11,label='exchange()',c="brown")
ax1.plot(int_time,int_time12,label='rotate_key()',c="aqua")
ax1.tick_params(direction='in')#刻度向里
plt.legend(loc='upper left')
plt.show()