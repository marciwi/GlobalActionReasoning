function [global_policy,local_policy,P,PR] = saveCurrentBelief(bpSet,filename,mdp)
% saveCurrentBelief - utility function for sampleBeliefs.m
%
%	function [global_policy,local_policy,P,PR] = saveCurrentBelief(bpSet,filename,mdp)
%
% Inputs:....................
%	bpSet				:set of belief points
%	filename			:string containing filename
%	mdp					:struct containing mdp problem
% Outputs:....................
%	global_policy		:global policy
%	local_policy		:local policy
%   P(SxS'xA)			:state transition function
%	PR
%
global problem;

if problem.useSparse
  [n,foo]=size(problem.beliefsSP);
  while problem.nnzBeliefs>=(n-problem.nrStates) % it's almost full,
													% realloc
    n=n*2;
    B=problem.beliefsSP;
    problem.beliefsSP=zeros(n,3);
    problem.beliefsSP(1:problem.nnzBeliefs,:)=B(1:problem.nnzBeliefs,:);
  end
  problem.nrBeliefs=problem.nrBeliefs+1;
  [I,J,S]=find(problem.belief);
  sz=size(I);
  I=repmat(problem.nrBeliefs,sz);
  bottom=problem.nnzBeliefs+1;
  top=bottom+sz(2)-1;

  problem.beliefsSP(bottom:top,1)=I';
  problem.beliefsSP(bottom:top,2)=J';
  problem.beliefsSP(bottom:top,3)=S';

  problem.nnzBeliefs=top;
else
  [n,d]=size(problem.beliefs);
  if problem.nrBeliefs==n % it's full, realloc
    B=problem.beliefs;
    problem.beliefs=zeros(n*2,problem.nrStates);
    problem.beliefs(1:problem.nrBeliefs,:)=B(1: problem.nrBeliefs,:);
  end
  problem.nrBeliefs=problem.nrBeliefs+1;
  problem.beliefs(problem.nrBeliefs,:)=problem.belief;
end
end
