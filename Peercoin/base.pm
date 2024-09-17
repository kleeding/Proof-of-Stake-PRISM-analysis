// Model type declaration
dtmc

// Stake ratio distribution
const double r1 = 1/3;
const double r2 = 1/3;
const double r3 = 1/3;

// Granularity of each slot
const int g = 1;

// Stake age parameters
const minAge = 3;
const int maxAge = 9;
const int ageLimit = 36;

// Increase age by 1 only for each completed slot
formula age_update = mod(step,3*g-2)=0? 1 : 0;

// Agents probability of being elected to produce a block
formula p = r1/g * min(age1+age_update,maxAge)/(maxAge);

// Agents eligibility to stake (e.g., old enough)
formula eligible = (age1+age_update>=minAge)? true : false;

// Highest coinage from agents with solutions found
formula maxCoinage = max(r1*age1*selected1,
			 r2*age2*selected2,
    			 r3*age3*selected3);

// Total number of solutions found during a step
formula selected_agents = selected1+selected2+selected3;

// Total number of agents chosen as block proposer
formula winners = winner1+winner2+winner3;

// Total number of eligible stakers
formula eligible_stakers = (age1+1>=minAge? 1:0)
			   +(age2+1>=minAge? 1:0)
      			   +(age3+1>=minAge? 1:0);

module stepper

	step : [1..3*g] init 1;

	[election] mod(step,3)=1 -> (step'=step+1);
	[consensus0] mod(step,3)=2 -> (step'=step+1);
	[consensus1] mod(step,3)=2 -> (step'=step+1);
	[consensus2] mod(step,3)=2 -> (step'=step+1);
	[consensus3] mod(step,3)=2 -> (step'=step+1);
	[reset] mod(step,3)=0 -> (step'=(step=3*g)? 1 : step+1);

endmodule

// Module process for agent 1
module agent1

	// Agents local variables
	age1 : [0..ageLimit] init minAge-1;
	selected1 : [0..1] init 0;
	winner1 : [0..1] init 0;

	// Solution search
	[election] eligible -> p:(selected1'=1)
 					&(age1'=min(age1+age_update,ageLimit)) 
			   + 1-p:(age1'=min(age1+age_update,ageLimit));
	[election] !eligible -> (age1'=age1+age_update);

	// Highest coinage selection rule
	[consensus1] selected1=1&(r1*age1)=maxCoinage -> (selected1'=0)
 							&(winner1'=1);
	[consensus2] selected2=1&(r2*age2)=maxCoinage -> (selected1'=0);
	[consensus3] selected3=1&(r3*age3)=maxCoinage -> (selected1'=0);
	[consensus0] selected_agents=0 -> (selected1'=0);

	// Reset to prepare for next sub-slot
	[reset] winner1=1 -> (winner1'=0)&(age1'=0);
	[reset] winner1=0 -> true;

endmodule

// Agents using agent 1 as a template module
// Module process for agent 2
module agent2=agent1 [
age1=age2,
selected1=selected2,
winner1=winner2,
r1=r2,
age2=age1,
selected2=selected1,
winner2=winner1,
r2=r1,
consensus1=consensus2,
consensus2=consensus1
] endmodule
// Module process for agent 3
module agent3=agent1 [
age1=age3,
selected1=selected3,
winner1=winner3,
r1=r3,
age3=age1,
selected3=selected1,
winner3=winner1,
r3=r1,
consensus1=consensus3,
consensus3=consensus1
] endmodule

// Labels describing
// a state that has agents selected to propose
label "agents_selected" = selected_agents>0;
// a state that has conflicts
label "conflict" = selected_agents>1;
// a state that has winners
label "winners" = winners>0;
// a state that has multiple winners
label "failure" = winners>1;

// Reward value of 1 applied to any state
// that has an action label: election
rewards "subslots"
	[election] true : 1; 
endrewards

// Reward value of 1/g applied to any state
// that has an action label: election
rewards "slots"
	[election] true : 1/g; 
endrewards

// Reward value of 1 applied to any state
// that has multiple solutions found
// ( multiple agents elected)
rewards "conflicts"
	selected_agents > 1 : 1; 
endrewards

// Reward value equal to the number of current
rewards "eligibility"
	mod(step,3)=1 : eligible_stakers;
endrewards

// Reward value of agent 3's stake age applied to any state
// in which agent 3 was chosen as winner
rewards "agent_production_age"
	winner3 = 1 : age3;
endrewards

// Reward value of an agents stake age applied to any state
// in which that agent was chosen as winner
rewards "production_age"
	winner1 = 1 : age1;
	winner2 = 1 : age2;
	winner3 = 1 : age3;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 found a solution
rewards "agent_elected"
	selected3 = 1 : 1; 
endrewards

// Reward value of [1..n] applied to any state
// in which has agents which found solutions
rewards "total_elected"
	selected_agents > 0 : selected_agents; 
endrewards

// Reward value of 1 applied to any state
// in which agent 3 was chosen as winner
rewards "agent_produced"
	winner3 = 1 : 1; 
endrewards

// Reward value of [1..n] applied to any state
// in which winners were chosen
rewards "total_produced"
	winners > 0 : winners; 
endrewards

// Reward value of agent 3's coinage applied to any state
// in which agent 3 was chosen as winner
rewards "agent_rewards"
	winner3 = 1 : r3*age3; 
endrewards

// Reward value of (coinage of winner) applied to any state
// in which winners were chosen
rewards "total_rewards"
	winner1 = 1 : r1*age1;
	winner2 = 1 : r2*age2;
	winner3 = 1 : r3*age3;
endrewards
