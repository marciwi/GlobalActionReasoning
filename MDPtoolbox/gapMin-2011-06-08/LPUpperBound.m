function [ub,dist] = LPUpperBound(scaledBelief,beliefSet,values,alphaVectors)
% function [ub,dist] = LPUpperBound(scaledBelief,beliefSet,values,alphaVectors)

nBeliefs = size(beliefSet,1);
nStates = size(beliefSet,2);

% check if the scaledBelief is 0
total = sum(scaledBelief);
if total < 1e-8
  ub = 0;
  dist = zeros(nStates+nBeliefs,1);
  return;
end

% QMDP upper bound
ub = max(scaledBelief*alphaVectors);
cornerVals = max(alphaVectors,[],2); 

%% check if the belief is already in beliefSet
%id = findBelief(scaledBelief/total,beliefSet);
%if id ~= 0
%  ub = min(ub,values(id)*total);
%  dist = zeros(nStates+nBeliefs,1);
%  dist(nStates+id) = total;
%  return;
%end

%% solve linear program
%% obvious LP
%f = [cornerVals;values];
%Aeq = [eye(nStates,nStates),beliefSet'];
%beq = scaledBelief';
%LB = zeros(nStates+nBeliefs,1);
%%[x,fval] = linprog(f,[],[],Aeq,beq,LB);
%[x,fval,solstat] = cplexint([],f,sparse(Aeq),beq,1:size(Aeq,1),[],LB);
%ub = fval;
%dist = x;

%% LP restricted to nonzero states and compatible beliefs
%zeroStates = find(scaledBelief==0);
%compatibleBeliefs = find(sum(Aeq(zeroStates,:),1) == 0);
%nonZeroStates = find(scaledBelief>0);
%f2 = f(compatibleBeliefs);
%Aeq2 = Aeq(nonZeroStates,compatibleBeliefs);
%beq2 = beq(nonZeroStates);
%LB2 = LB(compatibleBeliefs);
%[x2,fval2,solstat2] = cplexint([],f2,sparse(Aeq2),beq2,1:size(Aeq2,1),[],LB2);
%ub2 = fval2;
%dist2 = zeros(size(f));
%dist2(compatibleBeliefs) = x2;

% LP without corner variables
f3 = values - beliefSet*cornerVals;
A3 = beliefSet';
b3 = scaledBelief';
%LB3 = zeros(nBeliefs,1);
%[x3,fval3,solstat3] = cplexint([],f3,sparse(A3),b3,[],[],LB3);
%ub3 = fval3 + scaledBelief*cornerVals;
%dist3 = [scaledBelief' - beliefSet'*x3; x3];

% LP without corner variables restricted to nonzero states and compatible beliefs
zeroStates = find(scaledBelief==0);
compatibleBeliefs = find(sum(beliefSet(:,zeroStates),2) == 0);
if length(compatibleBeliefs) > 0
  nonZeroStates = find(scaledBelief>0);
  f4 = f3(compatibleBeliefs);
  A4 = A3(nonZeroStates,compatibleBeliefs);
  b4 = b3(nonZeroStates);
  if length(compatibleBeliefs) > 1
    LB4 = zeros(size(A4,2),1);
    OPTIONS.lic_rel = 1000000;
    [x4,fval4,solstat4] = cplexint([],f4,A4,b4,[],[],LB4,[],[],[],OPTIONS);
    %[x5,fval5] = logBarrier(f4,A4,b4,ones(length(f4),1)*0.001,0.00001,100);
    %maxdiff = max(abs(x5-x4))
  else
    x4 = min(b4./A4);
    fval4 = x4 * f4;
  end
  ub = min(ub,fval4 + scaledBelief*cornerVals);
  dist = zeros(size(f3));
  dist(compatibleBeliefs) = x4;
  dist = [scaledBelief' - beliefSet(compatibleBeliefs,:)'*x4; dist];

  %maxDiff = max(abs(dist3-dist4));
  %if maxDiff > 0.00001
  %  maxDiff = maxDiff
  %  keyboard
  %end
else
  ub = min(ub, scaledBelief * cornerVals);
  dist = [scaledBelief'; zeros(size(beliefSet,1),1)];
end
