function state = singlstate(globstate,st,ag)

%   state = singlstate(globstate,st,ag)
%
%convert the global state to all agents' local state assuming homogeneity
%of the agents
%
%Inputs------------------------------------------------------------
%globstate:         state number [1,state space]
%st:                number of possible states per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%state:             vector of states per agent
%
%   see also: GLOBSTATE.

globstate = globstate-1;
base = dec2base(globstate,st,ag);
for i=1:length(base)
    singlstate(i) = str2double(base(i));
end
state = singlstate+1;
end