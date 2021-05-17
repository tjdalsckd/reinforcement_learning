classdef ValueFunction
    properties
        num_of_groups
        group_size
        params
        END_STATES
    end
    methods
        function obj = ValueFunction(num_of_groups,N_STATES,END_STATES)
            obj.num_of_groups = num_of_groups;
            obj.group_size = floor(N_STATES / num_of_groups);
            obj.params = zeros(num_of_groups,1)
            obj.END_STATES = END_STATES
        end
        function val = value(obj,state)
            if sum(state==obj.END_STATES)>0
                val=0;
            elseif sum(state==obj.END_STATES)==0
                 group_index = floor((state)/(obj.group_size+obj.group_size*0.1))+1;
                val = obj.params(group_index);
            end
           
        end
        function update(obj,delta,state)
            group_index = floor((state)/(obj.group_size+obj.group_size*0.1))+1;
            obj.params(group_index)=obj.params(group_index)+delta;
        end        
    end
end

