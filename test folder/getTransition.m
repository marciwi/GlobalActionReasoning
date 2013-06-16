function [newstate,newobservation,newreward] = getTransition(global_state,global_action,mdp)

% This function is meant to provide en new state, observation and reward
% given the appropriate input variables

%% Notes
%relies on 'gendist' function for discrete random distributions

%% Load variables mdp problem
P=mdp.P;            O=mdp.O;        R=mdp.R;

%% newstate
probabilityDistr = P(global_state,:,global_action); %P(S,S',A)
newstate = gendist(probabilityDistr,1,1);

%% newobservation
probabilityDistr = squeeze(O(global_action,newstate,:)); %O(A,S',O)
newobservation = gendist(probabilityDistr',1,1);

%% newreward
if max(size(size(R)))==3
	newreward = R(global_state,newstate,global_action); %R(S,S',A)
else
	newreward = R(global_state,global_action); %R(S,A)
end