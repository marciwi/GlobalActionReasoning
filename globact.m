function global_action = globact(local_acts,ac,ag)

%   global_action = globact(local_acts,ac,ag)
%
%converts an array of single agent actions to the
%corresponding global action
%
%Inputs------------------------------------------------------------
%local_acts:         	array of single states per agent
%ac:                number of possible actions per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%action:            global action corresponding to the single agent
%                   set of actions
%
%   See also: SINGLACT.
if isa(local_acts,'char')
    action = ':';
else
    action=1;
    local_acts = local_acts-1;
    for i = 1:length(local_acts)
        action = action+local_acts(i)*ac^(ag-i);
    end
end
global_action = action;
end