function POMDP = spaan2pascal(pomdp)

POMDP.nStat = pomdp.nrStates;
POMDP.nAct = pomdp.nrActions;
POMDP.nObs = pomdp.nrObservations;
POMDP.Ta = permute(pomdp.transition,[2,1,3]);
POMDP.To = permute(pomdp.observation,[1,3,2]);
POMDP.Rew = squeeze(sum(pomdp.transition .* pomdp.reward3,1));
if isfield(pomdp,'values') & strcmp(pomdp.values,'cost')
  POMDP.Rew = -POMDP.Rew;
end

% sanity check
transErr = max(max(abs(sum(POMDP.Ta,2)-1)));
if transErr > 1e-5
  sprintf('Transition Error: %f\n',transErr);
  exit;
end
obsErr = max(max(abs(sum(POMDP.To,2)-1)));
if obsErr > 1e-5
  sprintf('Observation Error: %f\n',transErr);
  exit;
end

for actId = 1:POMDP.nAct
  POMDP.spRew{actId} = sparse(POMDP.Rew(:,actId));
  POMDP.spTa{actId} = sparse(POMDP.Ta(:,:,actId));
  POMDP.spTo{actId} = sparse(POMDP.To(:,:,actId));
  for obsId = 1:POMDP.nObs
    %POMDP.Tao{obsId,actId} = POMDP.Ta(:,:,actId)*diag(POMDP.To(:,obsId,actId));
    %POMDP.spTao{obsId,actId} = sparse(POMDP.Tao{obsId,actId});
    POMDP.spTao{obsId,actId} = POMDP.spTa{actId} * sparse(diag(POMDP.To(:,obsId,actId)));
  end
end

if ~isfield(pomdp,'gamma') || pomdp.gamma > 0.999
  POMDP.discount = 0.999;
else
  POMDP.discount = pomdp.gamma;
end
if isfield(pomdp,'start')
  POMDP.initBel = pomdp.start;
else
  POMDP.initBel = ones(1,POMDP.nStat)/POMDP.nStat;
end

%maxDiffRew = max(max(POMDP.Rew)) - min(min(POMDP.Rew));
%maxDiffVal = maxDiffRew/(1-POMDP.discount);
%POMDP.tol = min(0.01*(1-POMDP.discount)/2, 1e-5*maxDiffVal);
%POMDP.tol = 1e-5*maxDiffVal;

%if max(max(POMDP.Rew)) == 0
%  negative = find(POMDP.Rew(:)<0);
%  maxValFn = abs(max(POMDP.Rew(negative)))/(1-POMDP.discount);
%else
%  maxValFn = abs(max(max(POMDP.Rew)))/(1-POMDP.discount);
%end
%POMDP.tol = 10^(ceil(log10(maxValFn))-3)*(1-POMDP.discount)/2; 

maxValFn = max(max(POMDP.Rew))/(1-POMDP.discount);
minValFn = min(min(POMDP.Rew))/(1-POMDP.discount);
POMDP.tol = 10^(ceil(log10(max(abs(maxValFn),abs(minValFn))))-3)*(1-POMDP.discount)/2;
