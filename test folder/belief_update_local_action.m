function b = belief_update_local_action(o,b,a,mdp,agent)
%%   b = belief_update_local_action(o,b,a,mdp,agent)
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

%% Load values from mdp
ac=mdp.ac;		ag=mdp.ag;	
O=mdp.O;		P=mdp.P;

%% Update Belief
bb=zeros(length(b),ac^ag);
for j=1:length(b)   % iterate over future states
	bb(j)=proo(o,mdp,agent)*(squeeze(O(:,j,:))'*(praa(a,j,mdp,agent).*(b*squeeze(P(:,j,:))))');	
end
b=bb/sum(bb);
end

function pr=praa(a_local,nxt_state,mdp,agent)
%P(A|a_local,s')
%P(A|a_local)
%% load mdp.variables
ac=mdp.ac;	ag=mdp.ag;

%% calculate P(A|a)
pr=singlact(1:ac^ag,ac,ag,agent)==a_local;
pr=pr/sum(pr);
end

function pr=proo(o_local,mdp,agent)
% Pr(o_local|O_global,s',A)
%=Pr(o_local|O_global)
%% load mdp.variables
ob=mdp.ob;	ag=mdp.ag;

%% calculate p(o|O)
pr=singlobs(1:ob^ag,ob,ag,agent)==o_local;
%pr=pr/sum(pr);
end


