function b = belief_update_local_policy(o,b,a,mdp,agent)
%%   b = belief_update_local_policy(o,b,a,mdp,agent)
%
%   Pr(s'|b,a_local,o_local) 
%
%Inputs------------------------------------------------------------
%o:             local observation number
%b:             belief probability vector
%               length(b) should be global state space size
%a:             local action number
%P:             State transition probability
%O:             Observation probability matrix
%agent:         number of the agent this update applies to
%               (default = 1)
%
%Outputs-----------------------------------------------------------
%b:             updated belief probability vector
%
%   See also
%   BELIEF_UPDATE_LOCAL,BELIEF_UPDATE_GLOBAL,BELIEF_UPDATE_SANSACTION.

%% Notes:
% no reasoning is done about the policy execution of others
%dependent on belief_update_local
%dependent on singlact.m

%% Load variables from mdp problem
O=mdp.O;	P=mdp.P;

%% Update Belief
bb=zeros(1,length(b));
for j=1:length(b)   % iterate over future states
	bb(j) = proo(o,mdp,agent)*(squeeze(O(:,j,:))' * ...
		((praa(mdp,a,b,agent)).*(b*squeeze(P(:,j,:))))');	
end
b=bb/sum(bb);
end

function pr=proo(o_local,mdp,agent)
%=Pr(o_local|O_global)
%% load mdp.variables
ob=mdp.ob;	ag=mdp.ag;

%% calculate p(o|O)
pr=singlobs(1:ob^ag,ob,ag,agent)==o_local;
end


