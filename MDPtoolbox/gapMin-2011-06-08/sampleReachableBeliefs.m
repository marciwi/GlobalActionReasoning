function [beliefSet,values] = sampleReachableBeliefs(POMDP,ub,lb,n)
%function [beliefSet,values] = sampleReachableBeliefs(POMDP,ub,lb,n)

beliefSet = [];
values = [];
visitedBeliefs = [];

while size(beliefSet,1) < n

  belief = POMDP.initBel;
  %prob = 1;
  for i = 1:15
    %i = i
    if findBelief(belief,[visitedBeliefs]) > 0
      'already visited belief'
      keyboard
    end
    visitedBeliefs = [visitedBeliefs;belief];

    % compute best qVal
    [actId,oneStepLookaheadVal] = mostPromisingAction(belief,POMDP,ub);

    % add belief if is new
    id = findBelief(belief,[beliefSet;ub.beliefSet]);
    %id = findBelief(belief,[beliefSet;ub.beliefSet;eye(POMDP.nStat)]);
    if id == 0
      currentVal = upperBound(belief,ub.beliefSet,ub.values,ub.alphaVectors);
      reduction = currentVal - oneStepLookaheadVal;
      %if reduction > POMDP.tol
        beliefSet = [beliefSet; belief];
        values = [values; oneStepLookaheadVal];
        %keyboard
        break;
      %end
    end
    %keyboard  

    % compute next belief
    intermediateBelief = belief * POMDP.spTa{actId};
    for obsId = 1:POMDP.nObs
      nextBelief = intermediateBelief .* POMDP.To(:,obsId,actId)';
      ubVal = upperBound(nextBelief,ub.beliefSet,ub.values,ub.alphaVectors);
      lbVal = lowerBound(nextBelief,lb);
      gap(obsId) = ubVal - lbVal;
    end
    %gap = gap
    [largestGap,obsId] = max(gap);
    %obsProbs = intermediateBelief * POMDP.To(:,:,actId);
    %obsId = sampleMultinomial(obsProbs);
    %prob = prob * obsProbs(obsId);
    nextBelief  = intermediateBelief .* POMDP.To(:,obsId,actId)';
    zeroStates = find(nextBelief < 1/POMDP.nStat*1e-3);
    nextBelief(zeroStates) = 0;
    belief = nextBelief / sum(nextBelief);
  end
end


