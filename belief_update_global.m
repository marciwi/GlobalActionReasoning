function b = belief_update_global(o,b,a,P,O)
%%   b = belief_update_global(o,b,a,P,O)
%
%   Pr(o|b,a) 
%   based on p.393 of Reinforcement Learning - State of the Art
%
%Inputs------------------------------------------------------------
%o:             observation number
%b:             belief probability vector
%               length(b) should be global state space size
%a:             action number
%P:             State transition probability
%O:             Observation probability matrix
%
%Outputs-----------------------------------------------------------
%b:             updated belief probability vector
%
%   See also BELIEF_UPDATE_LOCAL,BELIEF_UPDATE_LOCAL_ACTION,BELIEF_UPDATE_SANSACTION.

%% Notes:
% - Works (though be wary of errors)
% - no dependencies on other functions (yet)
%% check inputs
if size(o)>1; error('observation o should be single digit'); end;
    % this same check might be used to enable single agent beliefs

%% Update belief
bb=zeros(1,length(b));  %pre-allocate for speed
for j=1:length(b)         %iterate over future states		
	bb(j)=O(a,j,o)*P(:,j,a)'*b';
end
b=bb/sum(bb);
end
