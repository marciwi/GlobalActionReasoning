function [bestActId, bestQval, bestAlpha] = bestConservativeAction(belief,POMDP,alphaVectors)
%function [bestActId, bestQval, bestAlpha] = bestConservativeAction(belief,POMDP,alphaVectors)

qVectors = POMDP.Rew;
%qVectors2 = POMDP.Rew;
for actId = 1:POMDP.nAct
  intermediateBelief = belief * POMDP.spTa{actId};
  bpAlpha = 0;
  for obsId = 1:POMDP.nObs
    nextBelief = intermediateBelief .* POMDP.To(:,obsId,actId)';
    %nextBelief = belief * POMDP.spTao{obsId,actId};
    [val, alphaId] = lowerBound(nextBelief,alphaVectors);
    %qVectors2(:,actId) = qVectors2(:,actId) + POMDP.discount*POMDP.spTao{obsId,actId}*alphaVectors(:,alphaId);
    bpAlpha = bpAlpha + POMDP.To(:,obsId,actId).*alphaVectors(:,alphaId);
  end
  qVectors(:,actId) = qVectors(:,actId) + POMDP.discount * POMDP.spTa{actId} * bpAlpha;
end
[bestQval,bestActId] = max(belief*qVectors);
bestAlpha = qVectors(:,bestActId);

%maxDiff = max(max(abs(qVectors - qVectors2)));
%if maxDiff > 1e-5
%  maxDiff = maxDiff
%  keyboard
%end
