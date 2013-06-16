function b = belief_update_global_action(o_local,b,a_global,mdp,agent)
%%   b = belief_update_global_action(o,b,a,mdp,agent)
%
%   Pr(s'|b,a_global,o_local) 
%
%Inputs------------------------------------------------------------
%o:             local observation number
%b:             belief probability vector
%               length(b) should be global state space size
%a:             global action number
%P:             State transition probability
%O:             Observation probability matrix
%agent:         number of the agent this update applies to
%               (default = 1)
%
%Outputs-----------------------------------------------------------
%b:             updated belief probability vector
%
%   See also
%   BELIEF_UPDATE_GLOBAL,BELIEF_UPDATE_LOCAL_ACTION,BELIEF_UPDATE_SANSACTION.

%% Notes:
% no reasoning is done about the policy execution of others
%dependent on singlobs.m

%% check inputs
if nargin<5;    agent=1;    end;
if size(o_local)>1; error('observation o_local should be single digit'); end;

%% Load values from mdp
P=mdp.P;		O=mdp.O;

%% Update belief
bb=zeros(1,length(b));  %pre-allocate for speed
bb =(proo(o_local,mdp,agent)*(squeeze(O(a_global,:,:))')).*(b*squeeze(P(:,:,a_global)));
b=bb/sum(bb);
end

function pr=proo(o_local,mdp,agent)
%=Pr(o_local|O_global)
%% load mdp.variables
ob=mdp.ob;	ag=mdp.ag;

%% calculate p(o|O)
pr=singlobs(1:ob^ag,ob,ag,agent)==o_local;
end

