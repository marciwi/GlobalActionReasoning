function b = belief_update_sansaction(o,b,Ppolicy,O)
%%   b = belief_update_sansaction(o,b,Ppolicy,O)
%
%   Pr(s'|o,b) based on an exact adherance to global policy 
%
%Inputs------------------------------------------------------------
%o:             global observation number
%b:             belief probability vector
%               length(b) should be global state space size
%Ppolicy:       State transition probability based on global policy
%O:             Observation probability matrix
%
%Outputs-----------------------------------------------------------
%b:             updated belief probability vector
%
%   See also
%   BELIEF_UPDATE_LOCAL,BELIEF_UPDATE_LOCAL_ACTION,BELIEF_UPDATE_GLOBAL.

%% check inputs
if size(o)>1; error('observation o should be single digit'); end;

%% Update belief
bb=zeros(1,length(b));
for j=1:length(b) %iterate over future states
    pr=0;
    for i=1:length(b) %iterate over current states
        pr=pr+Ppolicy(i,j)*b(i);
    end
    pos=O(1,j,o);
    pob = probb(o,b,Ppolicy,O,length(b));
    bb(j)=(pos/pob)*pr;
end
b=bb;
end