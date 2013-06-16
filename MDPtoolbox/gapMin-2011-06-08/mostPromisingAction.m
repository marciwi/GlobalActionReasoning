function [bestActId, bestQval] = mostPromisingAction(belief,POMDP,ub)
%function [bestActId, bestQval] = mostPromisingAction(belief,POMDP,ub)

qValues = belief*POMDP.Rew;
for actId = 1:POMDP.nAct
  for obsId = 1:POMDP.nObs
    nextBelief = belief * POMDP.spTao{obsId,actId};
    %[sortedDotProducts,sortedIds] = sort(ub.beliefSet * nextBelief');
    %topIds = sortedIds(max(1,length(sortedIds)-POMDP.nStat+1):end);
    val = upperBound(nextBelief,ub.beliefSet,ub.values,ub.alphaVectors);
    %val2 = upperBound(nextBelief,ub.beliefSet(topIds,:),ub.values(topIds),ub.alphaVectors);
    %difference = val2-val;
    %if difference > POMDP.tol
    %  difference
    %  keyboard
    %end
    qValues(actId) = qValues(actId) + POMDP.discount*val;
  end
end
[bestQval,bestActId] = max(qValues);
