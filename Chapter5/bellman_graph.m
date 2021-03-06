clc;
clear;
close all;

A = 1;
B = 2;
T=0;
S = [A,B];

Action = [[A,A];[A,B];[B,A];[B,B]];
Terminal_Action =[[A,T];[B,T]];
Episodes={[A,3,A,2,B,-4,A,+4,B,-3];...
          [B,-2,A,+3,B,-3]
          };



%% Bellman 
gamma = 1;

V(A)= 0;
V(B)= 0;
Return{A} = [];
Return{B} = [];
Action_Count = [0,0,0,0];
Terminal_Count = [0,0];
Action_Reward{1}=[];
Action_Reward{2}=[];
Action_Reward{3}=[];
Action_Reward{4}=[];
Terminal_Reward{1}=[];
Terminal_Reward{2}=[];

expected_reward = [0,0,0,0,0,0];
transition_prob = [0,0,0,0,0,0];



for i = 1:1:length(Episodes)
    episode = Episodes{i};
    S=episode(1:2:end-1);
    R=episode(2:2:end);
    G = 0;
    str_S="";
    for s=S
        if s==A
            str_S = strcat(str_S," ","A");
        else
            str_S = strcat(str_S," ","B");
        end
    end
    disp("====================EPISODE "+string(i)+", S = "+str_S+", R = "+num2str(R)+"  ======================")
    prev_s = S(1);
    prev_R = R(1);
    for t =2:1:length(S)
        s = S(t);
        r = prev_R;
        ind = 0;
        disp(string(prev_s)+string(s));
        for j=1:1:length(Action)
            if sum([prev_s,s]==Action(j,:))==2
                ind=j;
            end
        end
        Action_Count(ind) = Action_Count(ind) +1; 
        Action_Reward{ind} = [Action_Reward{ind},r];
        
        prev_s = s;
        prev_R = R(t);
        if t ==length(S)
            ind = 0;
            for j=1:1:length(Terminal_Action)
                if sum([prev_s,T]==Terminal_Action(j,:))==2
                    ind=j;
                end
            end
            Terminal_Count(ind)=Terminal_Count(ind)+1;
            Terminal_Reward{ind} = [Terminal_Reward{ind} ,prev_R];
        end
    end   
end
expected_reward(1) = mean(Action_Reward{1});
expected_reward(2) = mean(Action_Reward{2});
expected_reward(3) = mean(Action_Reward{3});
expected_reward(4) = mean(Action_Reward{4});
expected_reward(5) = mean(Terminal_Reward{1});
expected_reward(6) = mean(Terminal_Reward{2});
expected_reward(isnan(expected_reward))=0;

transition_prob(1) = sum(Action_Count(1))/sum([Action_Count(1:2),Terminal_Count(1)]);
transition_prob(2) = sum(Action_Count(2))/sum([Action_Count(1:2),Terminal_Count(1)]);
transition_prob(3) = sum(Action_Count(3))/sum([Action_Count(3:4),Terminal_Count(2)]);
transition_prob(4) = sum(Action_Count(4))/sum([Action_Count(3:4),Terminal_Count(2)]);
transition_prob(5) = sum(Terminal_Count(1))/sum([Action_Count(1:2),Terminal_Count(1)]);
transition_prob(6) = sum(Terminal_Count(2))/sum([Action_Count(3:4),Terminal_Count(2)]);

expected_reward
transition_prob

source_nodes = {'A','A','B','B','A','B'};
target_nodes = {'A','B','A','B','T','T'};
edge_weights = transition_prob;
del_ind =[]
for i = length(edge_weights):-1:1
    if edge_weights(i)==0
        source_nodes(i) = [];
        target_nodes(i) = [];
        edge_weights(i) = [];
    end
end
G = digraph(source_nodes,target_nodes,edge_weights);
h = plot(G,'EdgeLabel',G.Edges.Weight);
h.MarkerSize = 20;
h.NodeColor = [1,0,0];
h.EdgeColor = [0,0,0];
figure

source_nodes = {'A','A','B','B','A','B'};
target_nodes = {'A','B','A','B','T','T'};
edge_weights = expected_reward;
del_ind =[]
for i = length(edge_weights):-1:1
    if edge_weights(i)==0
        source_nodes(i) = [];
        target_nodes(i) = [];
        edge_weights(i) = [];
    end
end
G = digraph(source_nodes,target_nodes,edge_weights);
h = plot(G,'EdgeLabel',G.Edges.Weight);
h.MarkerSize = 20;
h.NodeColor = [1,0,0];
h.EdgeColor = [0,0,0];

V(A) = mean(Return{A});
V(B) = mean(Return{B});

disp("final:    V(A) : "+string(V(A))+"   V(B) : "+string(V(B))) 
