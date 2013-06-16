function [ub,dist] = upperBound(scaledBelief,beliefSet,values,alphaVectors)
% function [ub,dist] = upperBound(scaledBelief,beliefSet,values,alphaVectors)

global SAWTOOTH upperBoundType sawtoothMaxIter

if upperBoundType == SAWTOOTH
  [ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,sawtoothMaxIter);
else
  [ub,dist] = LPUpperBound(scaledBelief,beliefSet,values,alphaVectors);
end


%[ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,1);
%[ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,2);
%[ub,dist] = sawtoothUpperBound(scaledBelief,beliefSet,values,alphaVectors,100);
%[ub,dist] = LPUpperBound(scaledBelief,beliefSet,values,alphaVectors);