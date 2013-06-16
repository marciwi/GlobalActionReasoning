function [newAlphaVectors,uselessBeliefs] = pbvi(POMDP, lb, maxIter)
% function [newAlphaVectors,uselessBeliefs] = pbvi(POMDP, lb, maxIter)

%fprintf('Running PBVI\n');

if ~exist('maxIter','var')
  maxIter = 100000;
end

alphaVectors = lb.alphaVectors;
prevMaxImprovement = 0;
for iterId = 1:maxIter
  %iterId = iterId
  newAlphaVectors = []; 
  uselessBeliefs = [];
  for beliefId = 1:size(lb.beliefSet,1)
    [actId,newVal,newAlpha] = bestConservativeAction(lb.beliefSet(beliefId,:),POMDP,alphaVectors);
    currentVal = lowerBound(lb.beliefSet(beliefId,:),newAlphaVectors);
    [oldVal,alphaId] = lowerBound(lb.beliefSet(beliefId,:),alphaVectors);
    if newVal > max(oldVal,currentVal) 
      newAlphaVectors = [newAlphaVectors,newAlpha];
    elseif oldVal > currentVal
      newAlphaVectors = [newAlphaVectors,alphaVectors(:,alphaId)];
    else
      uselessBeliefs = [uselessBeliefs, beliefId];
    end
  end
    maxImprovement = max(max(lb.beliefSet*newAlphaVectors,[],2) - max(lb.beliefSet*alphaVectors,[],2));
  if maxImprovement < POMDP.tol & prevMaxImprovement < POMDP.tol 
    bestInit = max(POMDP.initBel * newAlphaVectors);
    %fprintf('bestInit = %f\t (found in %i steps)\n',bestInit,iterId);
    break;
  end
  alphaVectors = newAlphaVectors;
  prevMaxImprovement = maxImprovement;
end


