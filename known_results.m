%% Input known optimal results from Dec-POMDP page
%these values do not assume a discount factor

if		strcmp(mdp.filename,'recycling.dpomdp')	%recycling robots
	hPrevResults = [2 3 4 5 6 7 8 9 10 11 12 13 14 15 20 30 40 50 60 70];
	RPrevResults = [7 10.660125 13.38 16.486 19.5542 22.63374 25.709878 28.787037 31.863889 34.940833 38.01775 41.094675 44.171598 47.248521 62.633136 93.402367 124.171598 154.940828 185.710059 216.47929];
elseif strcmp(mdp.filename,'Grid3x3corners.dpomdp')
	hPrevResults = [1 2 3 4 5];
	RPrevResults = [0 0 0.133200 0.433 0.896];
	hPrevResults = [hPrevResults 6:10];
	RPrevResults = [RPrevResults zeros(1,5)];
	
	RPrevResults(6) = 1.49;
	RPrevResults(10) = 4.68;
elseif strcmp(mdp.filename,'broadcastChannel.dpomdp')
	hPrevResults = [2 3 4 5 6 7 8 9 10 15 20 25 30 50 100 250 500 600 700 900];
	RPrevResults = [2.000000 2.990000 3.890000 4.790000 5.690000 6.590000 7.490000 8.390000 9.290000 13.790000 18.313228 22.881523 27.421850 45.501604 90.760423 226.500545 452.738119 543.228071 633.724279 814.709393];
% elseif strcmp(mdp.filename,'')
% 	hPrevResults = [0];
% 	RPrevResults = [0];
else
	hPrevResults = [0];
	RPrevResults = [0];
end