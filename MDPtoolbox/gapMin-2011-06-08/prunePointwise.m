function prunedAlphaVectors = prunePointwise(alphaVectors,tolerance)
% function prunedAlphaVectors = prunePointwise(alphaVectors,tolerance)

nVectors = size(alphaVectors,2);
notDominated = ones(1,nVectors);
for i = 1:nVectors
  for j = [1:i-1,i+1:nVectors]
    if notDominated(j)
      difference = alphaVectors(:,i) - alphaVectors(:,j);
      maxDiff = max(difference);
      minDiff = min(difference);
      if maxDiff < -minDiff & maxDiff < tolerance
        notDominated(i) = 0;
        break;
      end
    end
  end
end
prunedAlphaVectors = alphaVectors(:,find(notDominated));