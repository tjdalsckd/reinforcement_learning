clear;
close all;
%% 상태 정의 
%       0  1  2  3  
%       4  5  6  7
%       8  9  10 11
%       12 13 14 0

% s =0 은 종단 상태.
global matrix_size
matrix_size = 6

S = [1:1:matrix_size*matrix_size-2 , 0];

%% 행동 정의
up = 1;
down = 2;
right = 3;
left = 4;
A = [up down right left] % up down right left
%% policy 정의
% 모두 같은 값을 갖는다 = 랜덤으로 4개중 하나를 선택한다.
p = [0.25 0.25 0.25 0.25];
% 각 상태에 대한 4개의 값을 갖는 policy table을 만든다.
policy = repmat(p,matrix_size*matrix_size,1);

%% 가치 함수 초기화
% v는 현재 상태의 가치함수
v = zeros(matrix_size*matrix_size,1);
% V는 다음 상태의 가치함수
V = zeros(matrix_size*matrix_size,1);
% 할인율
gamma = 1;


% 시행횟수 k
k=0
disp("----------------------------k : "+string(k)+"----------------------------")
disp("vk : ")
disp(reshape(v,matrix_size,matrix_size))
disp("vk+1 : ")
disp(reshape(V,matrix_size,matrix_size))

%%  POLICY EVALUATION
while 1
    delta_V = 0
    % 시행횟수 k==1에서는 현재 가치함수를 임의의 값으로 초기화 (단, 종단상태에서의 값은 0으로)
    if k==1
        v=-ones(matrix_size*matrix_size,1);
        %종단 상태에서의 가치함수 값
        v(1)=0;
        v(end)=0;
    end
    % 모든 상태 S에 대해서 loop
    for s = S
        % s==0 인 경우는 종단상태이므로 가치함수를 계산하지 않음.
        if s==0
            continue
        end
        % 가치함수는 (보상 + 할인율*이전 가치함수(다음상태)) 의 평균값이다.
        % value라는 임시 변수를 이용해 모두 더해서 평균을 구한다.        
        value = 0;
        for a = A
            next_s = next_state(s,a); % 행동 a 후의 s의 다음 상태 next_s
            r = get_reward(s,a); % 보상
            % 다음 가치함수의 값 = 다음 가치함수의 값 + 정책*(보상 + 할인율*이전 가치함수(다음상태))
            value=value+policy(s,a)*(r+gamma*v(next_s+1));
        end
        V(s+1) = round(value,2);
%         disp(string(s)+":"+string(V(s+1)))
        if delta_V>abs(v(s+1)-V(s+1))
            delta_V = delta_V;
        else
            delta_V = abs(v(s+1)-V(s+1));
        end
    end
    

    disp("----------------------------k : "+string(k)+"----------------------------")
    disp("vk : ")
    disp(reshape(v,matrix_size,matrix_size))
    disp("vk+1 : ")
    disp(reshape(V,matrix_size,matrix_size))
    v = V;
    if delta_V < 0.1
        break;
    end
end
%%  POLICY IMPROVEMENT
new_policy = policy;
while 1
    stable_policy = true;
    for s =S
        if s==0
            continue;
        end
        prev_action = get_action(policy(s+1,:));
        new_policy_temp=zeros(size(policy,2),1);
        q_s_a = [];
        for a = A
                next_s = next_state(s,a); % 행동 a 후의 s의 다음 상태 next_s
                r = get_reward(s,a); % 보상
                q_s_a = [q_s_a,r+gamma*v(next_s+1)]; % 행동 가치 함수를 찾는다.
        end
        % 헹동 가치 함수 중 가장 큰 값의 인덱스를 구한다.
        a_list=argmax(q_s_a);
        % policy를 수정한다. 여기서는 단순히 큰 값들의 개수로 확률을 만들었다.
        for j=1:1:length(a_list)
            new_policy_temp(a_list(j)) = 1/length(a_list);
        end
        new_action=get_action(new_policy_temp');
        new_policy(s+1,:)=new_policy_temp;
        % 새로운 policy가 stable인지 아닌지 판단한다.
        if new_action-prev_action <0.0001
            stable_policy = true;
            policy = new_policy;
        else
             stable_policy = false;
        end
    end
    if stable_policy ==true
        break;
    end
end
%% DRAW
draw_policy(policy);


%% functions 
function next_s =next_state(s,a)
%       0  1  2  3  
%       4  5  6  7
%       8  9  10 11
%       12 13 14 0
global matrix_size
    up = 1;
    down = 2;
    right = 3;
    left = 4;
    
    %% 행동에 따른 다음 상태 정의
    
    if a ==up 
        if sum(s==[1:1:matrix_size-1])>=1
            next_s = s;        
        else
            next_s = s-4;
        end
        if s==matrix_size
            next_s  = 0;
        end
    elseif a==down
        if sum(s==[linspace((matrix_size*matrix_size-2),(matrix_size*matrix_size-matrix_size),matrix_size-1)])>=1
            next_s = s;       
        else
            next_s = s+4;
        end
        if s==matrix_size*(matrix_size-1)-1
            next_s  = 0;
        end
    elseif a==right 
        if sum(s==[matrix_size-1:matrix_size:matrix_size*(matrix_size-1)])>=1
            next_s = s;       
        else
            next_s = s+1;
        end
        if s==matrix_size*(matrix_size)-2
            next_s  = 0;
        end
    elseif a==left 
        if sum(s==[matrix_size:matrix_size:matrix_size*(matrix_size-1)])>=1
            next_s = s;       
        else
            next_s = s-1;
        end
        if s==1
            next_s  = 0;
        end
    end
 
end

function index_list=argmax(temp)
    index_list = [];
    prev_value = 0;
    for j = 1:1:length(temp)
        [value,ind]=max(temp);

        if j>1
            if prev_value ~= value
                break;
            end
        end
        index_list(end+1) = ind+j-1;
        temp(ind)=[];
        prev_value = value;
    end
end

function a= get_action(policy)
    p= round(policy(1,:)*2000);
    pp = [ones(p(1),1);2*ones(p(2),1);3*ones(p(3),1);4*ones(p(4),1)];
    pp = pp(randperm(length(pp)));
    a = pp(1);
end

function r =get_reward(s,a)
    r = -1;
end


function p =get_policy(policy,s,a)
    p = 0.25;
end
function draw_policy(policy)
global matrix_size
    for i =0:2:matrix_size*2
        plot([0 matrix_size*2],[i i],'k-');
        plot([i i],[0 matrix_size*2],'k-');
        hold on;
    end
    X = repmat(1:1:matrix_size,1,matrix_size);
    Y = repelem(1:1:matrix_size,1,matrix_size);

    for i = 1:1:length(X)
            x = (X(i))*2-1;
            y = (matrix_size-Y(i))*2+1;
            if sum(i==[1,matrix_size*matrix_size])>=1
                text(x,y,string(0));
            else
                plot([x  x],[y,y+policy(i,1)],"r-","LineWidth",3); % up
                plot([x  x],[y,y-policy(i,2)],"r-","LineWidth",3); % down
                plot([x  x+policy(i,3)],[y,y],"r-","LineWidth",3); % right
                plot([x  x-policy(i,4)],[y,y],"r-","LineWidth",3); % left
                text(x,y,string(i-1));
            end
    end
    daspect([1,1,1]);
end

