function reducedBeliefSet = beliefSetDiff(beliefSet1,beliefSet2)
%function reducedBeliefSet = beliefSetDiff(beliefSet1,beliefSet2)

reducedBeliefSet = beliefSet1;
nBeliefs = size(beliefSet1,1);
for i = nBeliefs:-1:1
  if findBelief(reducedBeliefSet(i,:),beliefSet2) > 0
    reducedBeliefSet = reducedBeliefSet([1:i-1,i+1:end],:);
  end
end
