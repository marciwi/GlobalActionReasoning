%% Lib notes
% Might want to get rid of belief_update_sansaction...

%% Variables -----------------------------------------------------------
%-mdp(struct) should contain:
%   P(SxSxA)			:state transition function (SxS'xA)
%   R(SxS'xA) or R(SxA)	:reward function
%   O(AxS'xO)			:observation function

%   discount			:reward discount factor
%   values				:defines wether 'cost' or 'reward' is used
%   states				:# of states in global problem
%   observations		:build up of observations in global problem
%   actions				:build up of actions in the global problem
%   start				:initial state distribution
%   agents				:build up of agents in the system

%   ob					:# of observations per agent
%   st					:# of states per agent
%   ac					:# of actions per agent
%   ag					:# of agents
%   singlact			:build up of single agent actions

%-h             horizon length
%-policy        global policy (solved centrally)
%-singlpol      single agent policy derived from global version

%% Make quick pomdp from existing stuff to analyse
%stuff from pomdpSoftware-0.1
%addpath('pomdpSoftware-0.1/generic')
%addpath('pomdpSoftware-0.1/problems/hallway2')
%S = sampleBeliefs(10);
%runvi(S)
%global vi
%global backupStats
%global problem
%Rew=sampleRewards(backupStats.V{100});

%% Test slot
b=ones(1,4)/4;	b1=b;	b2=b;
%% test case
o=1; a=3;
%somehow there's a diference in outcome between the two here...
%don't know why yet
%the 2nd update is considerably faster though
tic;	b1=belief_update_local_policy(o,b1,a,mdp,2)
toc
tic;	b2=belief_update_local_policy_testalteration(o,b2,a,mdp,2)
toc
