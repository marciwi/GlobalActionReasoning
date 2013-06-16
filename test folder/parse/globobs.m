function obs = globobs(observations,ob,ag)

%       obs = globobs(observations,ob,ag)
%
%Derives the global observation (number) from the 
%input set of local observations
%
%Inputs------------------------------------------------------------
%observations:      vector of single agent observations 
%                   (per item in range [1,ob])
%ob:                number of observations possible per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%obs:               The corresponding global observation number
%                   in the set [1,ob*ag]
%
%   See also: SINGLOBS

obs=1;
observations=observations-1;
for i=1:length(observations)
    obs=obs+observations(i)*ob^(ag-i);
end
end