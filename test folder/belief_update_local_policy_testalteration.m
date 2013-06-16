function b = belief_update_local_policy_testalteration(o,b,a,mdp,agent)
% b = belief_update_local_policy(o,b,a,mdp,agent)
%
%   Pr(s'|b,a_local,o_local) based on global policy 
%

%% Notes:
%this is meant to improve on the calculation times of the update
%currently ~1.6sec.....worked! way faster!!

%% check inputs
if nargin<5;    agent=1;    end;
if size(o)>1; error('observation o should be single digit'); end;

%% Load values from mdp
P=mdp.P;

%% Update belief
bb=zeros(1,length(b));  %pre-allocate for speed
%O=(AxS'xO)
%P=(SxS'xA)
%1:	P(s'|s,A) = P					ps
%2:	P(A,|s,a) = f(policy,P(a|A))	pa
%3: b(s)							b(s)
%4: P(O|o,A,s') = f(O,P(o|O))		po
% iteration = sum_s[sum_A[1*2*3*sum_O[4]]]
for j=1:length(b)		%iterate over future states	
	%best outcome! 
	bb(j) = sum(sum(squeeze(P(:,j,:))*pra(a,mdp,agent)*b'*pro(o,j,mdp,agent)));
	
	%corrected outcome
	%bb(j) = sum(sum(squeeze(P(:,j,:)).*pra(a,mdp,agent)'.*(b'*pro(o,j,mdp,agent))));
end
b=bb/sum(bb);
end

function pr = pro(o_local,nxt_state,mdp,agent)
%% Notes
%   Pr(O|o,A,s') 
%	=P(O|s',A)*P(o|O)/sum_O[P(O|s',A)*P(o|O)]
%	O=(AxS'xO)
%% load from mdp struct
ob=mdp.ob;	% number of local observations per agent
ag=mdp.ag;	% number of agents
ac=mdp.ac;	% number of local actions per agent
O=mdp.O;
%% calculate
pr=zeros(1,ac^ag);
for i=1:ac^ag		%iterate over global actions
	obs=(squeeze(O(i,nxt_state,:)));
	for j=1:length(obs)	%iterate over global observations
	pr(i)=pr(i)+double(singlobs(j,ob,ag,agent)==o_local)*obs(j);
	end
end
end

function pr = pra(a_local,mdp,agent)
%	Pr(A|a,s)
%	P(A|s)*P(a|A)/sum_A[P(A|s)*P(a|A)]
%% load from mdp struct
ac=mdp.ac; % number of local actions per agent
ag=mdp.ag; % number of agents
states=mdp.nrStates;
actions=mdp.nrActions;
policy=mdp.global_policy;
%% calculate
pr=zeros(actions,states);

for i=1:actions
	pr(i,:)=(policy'==i)*double((singlact(i,ac,ag,agent)==a_local));
end

end