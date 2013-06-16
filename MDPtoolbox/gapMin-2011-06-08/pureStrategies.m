function alphaVectors = pureStrategies(POMDP,maxIter)
% function alphaVectors = pureStrategies(POMDP,maxIter)

if ~exist('maxIter','var') 
  maxIter = 10000;
end

alphaVectors = ones(POMDP.nStat,POMDP.nAct)*min(min(POMDP.Rew))/(1-POMDP.discount);
for actId = 1:POMDP.nAct
  %fprintf('Computing pure strategy for action #%i\n',actId);
  newAlpha = zeros(POMDP.nStat,1);
  bellmanErr = POMDP.tol;

  % should speed this up with cgs
  for i = 1:maxIter
    prevAlpha = newAlpha;
    newAlpha = POMDP.Rew(:,actId) + POMDP.discount * POMDP.spTa{actId} * prevAlpha;
    bellmanErr = max(abs(newAlpha-prevAlpha));
    if bellmanErr <= POMDP.tol
      break;  
    end
  end
  
  alphaVectors(:,actId) = newAlpha;
end
alphaVectors = prunePointwise(alphaVectors,POMDP.tol);
