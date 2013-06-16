function state = globstate(singlstate,st,ag)

%   state = globstate(singlstate,st,ag)
%
%converts an array of single agent states to the
%corresponding global action
%
%Inputs------------------------------------------------------------
%singlstate:      	array of single states per agent
%st:                number of possible states per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%state:             global action corresponding to the single agent
%                   set of actions
%
%   See also: SINGLSTATE.

%% Notes:
% Copied from globact and slightly altered 
% NOT TESTED!
%dependent on singlstate.m
%% check inputs
if isa(singlstate,'char');
    state = ':';
else
%% calc
    state=1;
    singlstate = singlstate-1;
    for i = 1:length(singlstate)
        state = state+singlstate(i)*st^(ag-i);
    end
end
end