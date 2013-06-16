function [newUb,newReachableBeliefs,newAlphaVectors] = cleanupUB(ub,tol,reachableBeliefs,alphaVectors);

newAlphaVectors = alphaVectors;
newReachableBeliefs = reachableBeliefs;
nBeliefs = size(ub.beliefSet,1);
nStat = size(ub.beliefSet,2);
newUb = ub;
for i = nBeliefs:-1:1
  belief = newUb.beliefSet(i,:);
  val = newUb.values(i);
  beliefSet = newUb.beliefSet([1:i-1,i+1:end],:);
  values = newUb.values([1:i-1,i+1:end]);
  if size(beliefSet,1) > 0
    [ubVal,dist] = upperBound(belief,beliefSet,values,newUb.alphaVectors);
    if ubVal - val < tol
      newUb.beliefSet = beliefSet;
      newUb.values = values; 
      newAlphaVectors = newAlphaVectors([1:nStat+i-1,nStat+i+1:end],:);

      %% adjust reachableBeliefs
      %newIds = find(dist(nStat+1:end)>=1e-8);
      %newReachableBeliefs = newReachableBeliefs([1:nStat+i-1,nStat+i+1:end],:,:);
      %for id = 1:prod(size(newReachableBeliefs))
      %  smallerIds = find(newReachableBeliefs{id}<i);
      %  greaterIds = find(newReachableBeliefs{id}>i);
      %  newReachableBeliefs{id} = [newReachableBeliefs{id}(smallerIds); newReachableBeliefs{id}(greaterIds)-1];
      %  if find(newReachableBeliefs{id}==i)
      %    newReachableBeliefs{id} = union(newReachableBeliefs{id}',newIds')';
      %  end
      %end    
    end
  end
end

%fprintf('Removed %i beliefs\n',size(ub.beliefSet,1) - size(newUb.beliefSet,1));
