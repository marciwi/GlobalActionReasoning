function [ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,maxIter)
% function [ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,maxIter)

% check if the scaledBelief is 0
total = sum(scaledBelief);
if total < 1e-8
  ub = 0;
  nBeliefs = size(beliefSet,1);
  nStates = size(beliefSet,2);
  dist = zeros(nStates+nBeliefs,1);
  return;
end

% QMDP upper bound
QMDPUpperBound = max(scaledBelief*alphaVectors); 

% Sawtooth
cornerVals = max(alphaVectors,[],2);
improvements = values - beliefSet * cornerVals;
dist = zeros(size(beliefSet,1),1);
ub = scaledBelief*cornerVals;
for iter = 1:maxIter
  coefficients = min((ones(size(beliefSet,1),1) * scaledBelief) ./ beliefSet,[],2);
  [minVal,minId] = min(coefficients .* improvements);
  if dist(minId) > 0 | minVal > -1e-8
    break;
  end
  ub = ub+minVal;
  dist(minId) = coefficients(minId);
  scaledBelief = scaledBelief - coefficients(minId) * beliefSet(minId,:);
end
dist = [scaledBelief';dist];

% Make sure that ub is not greater than QMDP upper bound
%if QMDPUpperBound < ub - 100
%  'error: QMDPUpperBound < ub - 100'
%  keyboard
%end
%ub = min(ub,QMDPUpperBound);

%if iter > 2
%  iter = iter
%  keyboard
%end

if abs(total - sum(dist)) > 1e-5
  'error: sum(dist) ~= total'
  keyboard
end
