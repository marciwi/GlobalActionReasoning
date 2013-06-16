function id = findBelief(belief,beliefSet)


% check if the belief is already in beliefSet
nBeliefs = size(beliefSet,1);
if nBeliefs == 0
  id = 0;
else
  [minDiff,id] = min(max(abs(ones(nBeliefs,1)*belief - beliefSet),[],2));
  if minDiff > 1e-8
    id = 0;
  end
end
