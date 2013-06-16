%% Input known optimal results from Dec-POMDP page
%these values do not assume a discount factor

if		strcmp(mdp.filename,'recycling.dpomdp')	%recycling robots
	hPrevResults = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 20 30 40 50 60 70];
	RPrevResults = [7 10.660125 13.38 16.486 19.5542 22.63374 25.709878 28.787037 31.863889 34.940833 38.01775 41.094675 44.171598 47.248521 62.633136 93.402367 124.171598 154.940828 185.710059 216.47929];
elseif	strcmp(mdp.filename,'dectiger.dpomdp')	%dec-tiger
	hPrevResults = [2 3 4 5 6];
	RPrevResults = [-4 5.190812 4.802755 7.026451 10.381625];
elseif	strcmp(mdp.filename,'fireFighting_2_3_3.dpomdp')
	%fire fighting 2 agents 3 houses 3 fire_levels
	hPrevResults = [2 3 4 5 6];
	RPrevResults = [-4.383496 -5.736969 -6.578834 -7.069874 -7.175591];
else
	hPrevResults = [0];
	RPrevResults = [0];
end



