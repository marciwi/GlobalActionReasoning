function rewards = eval_global(mdp,h,restarts)

% [avg_reward,clc_time] = eval_global(mdp,global_policy,timesteps,restarts)
% Evaluate the utility of a local policy without communication
%
%Inputs------------------------------------------------------------
%-mdp(struct) should contain:
%   P(SxSxA)            :state transition function (SxS'xA)
%   R(SxSxA) or R(SxA)  :reward function
%   O(SxAxO)            :observation function
%
%   discount            :reward discount factor
%   values              :defines wether 'cost' or 'reward' is used
%   states              :# of states in global problem
%   observations        :build up of observations in global problem
%   actions             :build up of actions in the global problem
%   start               :initial state distribution
%   agents              :build up of agents in the system
%
%   ob                  :# of observations per agent
%   st                  :# of states per agent
%   ac                  :# of actions per agent
%   ag                  :# of agents
%   singlact            :build up of single agent actions
%
%-h                 horizon length
%-policy            global policy (solved centrally)
%-global_policy      single agent policy derived from global version
%
%Outputs-----------------------------------------------------------
%-avg_reward        average reward over the number of restarts
%-cpu_time          time used to calculate result
%
%   See also EVAL_LOCAL,EVAL_LOCAL_SMART.

%% Check variables
if nargin<3;    restarts=0; end;

%% Notes

%% Load values from mdp
P=mdp.P;        O=mdp.O;        R=mdp.R;        b0=getStart(mdp);
global_policy = mdp.global_policy;
%help tic    %!!!

%% Initialise variables
rewards=zeros(1,h);			total_rewards=zeros(restarts+1,h);
%% begin sequence 
for starts=1:(restarts+1)
    state = gendist(b0,1,1); %Set/Reset starting state
    belief = b0;             %Set/Reset belief
for step=1:h
%% Simulate a time step
%select action
    global_action = global_policy(state);
% Perform state transition
	[state,o,r] = getTransition(state,global_action,mdp);
% receive reward R(S,S',A)
    rewards(step) = r;
% update belief
    belief = belief_update_global(o,belief,global_action,P,O);

end %timesteps loop
total_rewards(starts,:)=rewards;
end %restarts loop
rewards=total_rewards;
end
