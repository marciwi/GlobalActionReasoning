function [lb,alphaId] = lowerBound(belief,alphaVectors)
% function [lb,alphaId] = lowerBound(belief,alphaVectors)

if size(alphaVectors,2) > 0
  [lb,alphaId] = max(belief*alphaVectors);
else
  lb = -inf;
  alphaId = 0;
end

