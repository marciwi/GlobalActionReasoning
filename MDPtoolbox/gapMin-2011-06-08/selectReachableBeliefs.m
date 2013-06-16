function [lbBeliefSet,ubBeliefSet,values] = selectReachableBeliefs(POMDP,ub,lb,n,extPts,tightLB)
%function [lbBeliefSet,ubBeliefSet,values] = selectReachableBeliefs(POMDP,ub,lb,n,extPts,tightLB)

%fprintf('Selecting reachable belief states to be improved\n');

lbBeliefSet = [];
ubBeliefSet = [];
values = [];
visitedBeliefs = [];
beliefQueue = [];
gapQueue = [];
probQueue = [];
depthQueue = [];
pathQueue = {};

belief = POMDP.initBel;
path = [];
prob = 1;
depth = 1;
[ubVal,dist] = upperBound(belief,ub.beliefSet,ub.values,ub.alphaVectors);
%usefulUbBeliefIds = find(dist(POMDP.nStat+1:end)>1e-8)';

if extPts
  corners = eye(POMDP.nStat);
else
  corners = [];
end

newBeliefs = 0;
while newBeliefs < n
  visitedBeliefs = [belief; visitedBeliefs];
  if size(visitedBeliefs,1) > 1000
    visitedBeliefs = visitedBeliefs(1:1000,:);
  end
  
  % compute most promising and best conservative qVal
  [ubActId,ubOneStepLookAheadVal] = mostPromisingAction(belief,POMDP,ub);
  [lbActId,lbOneStepLookAheadVal] = bestConservativeAction(belief,POMDP,lb.alphaVectors);

  % add belief to ubBeliefSet
  ubId = findBelief(belief,[ubBeliefSet;ub.beliefSet;corners]);
  %ubId = findBelief(belief,ubBeliefSet);
  if ubId == 0
    currentVal = upperBound(belief,ub.beliefSet,ub.values,ub.alphaVectors);
    reduction = currentVal - ubOneStepLookAheadVal;
    if reduction > POMDP.tol
      uniquePath = beliefSetDiff(path,[ubBeliefSet;ub.beliefSet;corners]);
      ubBeliefSet = [ubBeliefSet; belief; uniquePath];
      values = [values; ubOneStepLookAheadVal];
      for i = 1:size(uniquePath,1)
    	values = [values; upperBound(uniquePath(i,:),ub.beliefSet,ub.values,ub.alphaVectors)];
      end
      newBeliefs = newBeliefs + 1;
      %if findBelief(belief,ub.beliefSet) > 0
      %  findBelief(belief,ub.beliefSet)
      %  keyboard
      %end
    end
  end

  % add belief to lbBeliefSet
  lbId = findBelief(belief,[lbBeliefSet;lb.beliefSet]);
  if lbId == 0
    currentVal = lowerBound(belief,lb.alphaVectors);
    improvement = lbOneStepLookAheadVal - currentVal;
    if improvement > POMDP.tol
      uniquePath = beliefSetDiff(path,[lbBeliefSet;lb.beliefSet]);
      lbBeliefSet = [lbBeliefSet; belief; uniquePath];
      newBeliefs = newBeliefs + 1;
    end
  end

  % compute next belief based on ubActId
  intermediateBelief = belief * POMDP.spTa{ubActId};
  for obsId = 1:POMDP.nObs
    nextBelief = intermediateBelief .* POMDP.To(:,obsId,ubActId)';
    zeroStates = find(nextBelief < 1/POMDP.nStat * 0.0001);
    nextBelief(zeroStates) = 0;
    obsProb(obsId) = sum(nextBelief);
    if obsProb(obsId) > 1e-8
      nextBelief  = nextBelief / obsProb(obsId);
      id = findBelief(nextBelief,visitedBeliefs);
      if id == 0
        [ubVal,dist] = upperBound(nextBelief,ub.beliefSet,ub.values,ub.alphaVectors);
        %usefulUbBeliefIds = union(usefulUbBeliefIds,find(dist(POMDP.nStat+1:end)>1e-8)');
        lbVal = lowerBound(nextBelief,lb.alphaVectors);
        if POMDP.discount^depth * (ubVal - lbVal) > POMDP.tol * 20
          gap(obsId) = prob * obsProb(obsId) * POMDP.discount * (ubVal - lbVal);
          [beliefQueue,gapQueue,probQueue,depthQueue,pathQueue] = insertInQueue(nextBelief,gap(obsId),prob*obsProb(obsId)*POMDP.discount,depth+1,[path;belief],beliefQueue,gapQueue,probQueue,depthQueue,pathQueue);
        end
      end
    end
  end

  % compute next belief based on lbActId
  if tightLB
    if lbActId ~= ubActId
      intermediateBelief = belief * POMDP.spTa{ubActId};
      for obsId = 1:POMDP.nObs
        nextBelief = intermediateBelief .* POMDP.To(:,obsId,lbActId)';
        zeroStates = find(nextBelief < 1/POMDP.nStat * 0.0001);
        nextBelief(zeroStates) = 0;
        obsProb(obsId) = sum(nextBelief);
        if obsProb(obsId) > 1e-8
          nextBelief  = nextBelief / obsProb(obsId);
          id = findBelief(nextBelief,visitedBeliefs);
          if id == 0
            [ubVal,dist] = upperBound(nextBelief,ub.beliefSet,ub.values,ub.alphaVectors);
            %usefulUbBeliefIds = union(usefulUbBeliefIds,find(dist(POMDP.nStat+1:end)>1e-8)');
            lbVal = lowerBound(nextBelief,lb.alphaVectors);
            if POMDP.discount^depth * (ubVal - lbVal) > POMDP.tol * 20
              gap(obsId) = prob * obsProb(obsId) * POMDP.discount * (ubVal - lbVal);
              [beliefQueue,gapQueue,probQueue,depthQueue,pathQueue] = insertInQueue(nextBelief,gap(obsId),prob*obsProb(obsId)*POMDP.discount,depth+1,[path;belief],beliefQueue,gapQueue,probQueue,depthQueue,pathQueue);
            end
          end
        end
      end
    end
  end  

  if size(beliefQueue,1) == 0
    break;
  end
  belief = beliefQueue(1,:);
  largestGap = gapQueue(1);
  prob = probQueue(1);
  depth = depthQueue(1);
  path = pathQueue{1};
  beliefQueue = beliefQueue(2:end,:);
  gapQueue = gapQueue(2:end);
  probQueue = probQueue(2:end);
  depthQueue = depthQueue(2:end);
  pathQueue = pathQueue(2:end);
  if size(beliefQueue,1) > 1000
    beliefQueue = beliefQueue(1:1000,:);
    gapQueue = gapQueue(1:1000);
    probQueue = probQueue(1:1000,:);
    depthQueue = depthQueue(1:1000,:);
    pathQueue = pathQueue(1:1000);
  end
  %fprintf('largestGap = %f\tbeliefQueueSize = %i\tprob = %f\tdepth = %i\n',largestGap,size(beliefQueue,1),prob,depth);
end

%fprintf('Searched %i beliefs; Added %i lbBeliefs and %i ubBeliefs\n',size(visitedBeliefs,1),size(lbBeliefSet,1),size(ubBeliefSet,1));

%irrelevantUbBeliefIds = setdiff(1:size(ub.beliefSet,1),usefulUbBeliefIds)
