
global POSSIBLE_ACTION 
global  ACTION
global REWARD
global TRANSITION_PROB
global WIDTH
global HEIGHT

POSSIBLE_ACTION = [0,1,2,3] %left right up down
ACTION = [[-1,0];[1,0];[0,-1];[0,1]]
REWARD = []
TRANSITION_PROB = 1
WIDTH = 5;
HEIGHT = 5;

disp("time : 0 ")

circle_position = [2,2]
triangle_position = [1,2;2,1]
box_position = [0,0]

for t = 0:1:10

    input("time : "+ string(t+1)+"")
    draw_all(circle_position,triangle_position,box_position)
end
    