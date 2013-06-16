%% Personally defined mdp problem.
%states may grow to include dirt level per room.
%actions should reflect the bate essentials of what a cleaner should do
agents = 3;     %number of agents
battery = 3;    %number of battery states
                %1. low
                %2. med
                %3. high
position = 5;   %number of rooms available for the agents
                %Chargers are placed in room 1 by default
chargers = 1;   %number of charging stations

actions = 4;    %number of actions per agent (up for alteration)
                %1. charge
                %2. move to other room
                %3. clean
                %4. do nothing

S = agents*position*battery;% total number of states
A = agents*actions;         % total number of actions

%% Define the transition variables & rewards
simcharge=0;    %=0 if robots can't charge simultaneously
                %=1 if they CAN charge simultaneously
p1=0.5;         %Move to desired room
p2=0.7;         %Move to common room/hall

r1=-10;         %Robot *dies*
r2=6;           %Robot finishes a room

%% Define function that creates single states from current rep
%this might not be necessary as I have already defined the total number
%of states (n actions)
%It might be handy to adequately choose the position of states n actions
%in the upcoming matrices to easily deduce which global state in 
%associated with which single state

%% Define the transition probability matrix
%P(SxS'xA)
P=zeros(S,S,A);

%% Define the Reward matrix
%R(SxS'xA)
R=zeros(S,S,A);