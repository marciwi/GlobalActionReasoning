function newPOMDP = constructPOMDP(POMDP,ub,extPts,oldPOMDP)
% function newPOMDP = constructPOMDP(POMDP,ub,extPts,oldPOMDP)

%fprintf('Constructing FIB_POMDP\n');

nBeliefs = size(ub.beliefSet,1);
if extPts
  newPOMDP.nStat = POMDP.nStat + nBeliefs;
  newPOMDP.Rew = [POMDP.Rew; ub.beliefSet*POMDP.Rew];
  beliefs = [eye(POMDP.nStat); ub.beliefSet];
else
  newPOMDP.nStat = nBeliefs;
  newPOMDP.Rew = ub.beliefSet*POMDP.Rew;
  beliefs = ub.beliefSet;
end
newPOMDP.nAct = POMDP.nAct;
newPOMDP.nObs = POMDP.nObs;
newPOMDP.discount = POMDP.discount;
newPOMDP.tol = POMDP.tol;

for actId = 1:newPOMDP.nAct
  for obsId = 1:POMDP.nObs
    matrix = zeros(newPOMDP.nStat,nBeliefs+POMDP.nStat);
    for beliefId = 1:newPOMDP.nStat
      nextBelief = beliefs(beliefId,:)*POMDP.spTao{obsId,actId};
      obsProb = sum(nextBelief);
      if obsProb > 1e-8
        if exist('oldPOMDP','var') && size(oldPOMDP.reachableBeliefs,1) >= beliefId
   	      relevantBeliefIds = [oldPOMDP.reachableBeliefs{beliefId,obsId,actId}',nBeliefs-newPOMDP.nStat+oldPOMDP.nStat+1:nBeliefs];
          relevantBeliefSet = ub.beliefSet(relevantBeliefIds,:);
          [val,relevantDist] = upperBound(nextBelief,relevantBeliefSet,ub.values(relevantBeliefIds),ub.alphaVectors);
          dist = zeros(newPOMDP.nStat,1);
          dist([1:POMDP.nStat,POMDP.nStat+relevantBeliefIds]) = relevantDist;
        else
           [val,dist] = upperBound(nextBelief,ub.beliefSet,ub.values,ub.alphaVectors);
        end
        dist(find(dist<1e-8)) = 0;
        newPOMDP.reachableBeliefs{beliefId,obsId,actId} = find(dist(POMDP.nStat+1:end)>0);
        matrix(beliefId,:) = dist';
        %if max(abs(obsProb - sum(dist))) > 1e-8
        %  sumDist = sum(dist)
        %  keyboard
        %end
      end
    end
    newPOMDP.spTao{obsId,actId} = sparse(matrix);
  end
end

[val,initBel] = upperBound(POMDP.initBel,ub.beliefSet,ub.values,ub.alphaVectors);
newPOMDP.initBel = initBel';
