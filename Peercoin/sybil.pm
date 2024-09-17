// Model type declaration
dtmc

// Stake ratio distribution
const double r1; // Set 0 < r1 < 1
const double r2 = 1-r1;

// How agent 2 will split their stake between the new accounts
const double split;

// New agents stake ratios
const double r2a=r2*split;
const double r2b=r2-r2a;

// Granularity of each slot
const int g=1;

// Stake age parameters
const minAge = 3;
const int maxAge = 9;
const int ageLimit = 36;

formula age_update = mod(step,3*g-2)=0? 1 : 0;

// Agents probability of being elected to produce a block
formula p = r1/g * min(age1+age_update,maxAge)/(maxAge);

// Agents eligibility to stake (e.g., old enough)
formula eligible = (age1+age_update>=minAge)? true : false;

// Total number of solutions found during a step
formula solutions = solution1+solution2a+solution2b;

// Total number of agents chosen as block proposer
formula winners = winner1+winner2a+winner2b;

// Highest coinage from agents with solutions found
formula maxCoinage = max(r1*age1*solution1,r2a*age2a*solution2a,r2b*age2b*solution2b);

// Total number of eligible stakers
formula eligible_stakers = (age1+1>=minAge? 1:0)+(age2a+1>=minAge? 1:0)+(age2b+1>=minAge? 1:0);

module stepper

	step : [1..3*g] init 1;

	[election] mod(step,3)=1 -> (step'=step+1);
	[consensus0] mod(step,3)=2 -> (step'=step+1);
	[consensus1] mod(step,3)=2 -> (step'=step+1);
	[consensus2a] mod(step,3)=2 -> (step'=step+1);
	[consensus2b] mod(step,3)=2 -> (step'=step+1);
	[reset] mod(step,3)=0 -> (step' = (step=3*g)? 1 : step+1);

endmodule

// Module process for agent 1
module agent1

	age1 : [0..ageLimit] init minAge-1;
	solution1 : [0..1] init 0;
	winner1 : [0..1] init 0;

	// Solution search
	[election] eligible -> p:(solution1'=1)&(age1'=min(age1+age_update,ageLimit)) 
			   + 1-p:(age1'=min(age1+age_update,ageLimit));
	[election] !eligible -> (age1'=age1+age_update);

	// Highest coinage selection rule
	[consensus1] solution1=1&(r1*age1)=maxCoinage -> (solution1'=0)&(winner1'=1);
	[consensus2a] solution2a=1&(r2a*age2a)=maxCoinage->(solution1'=0);
	[consensus2b] solution2b=1&(r2b*age2b)=maxCoinage->(solution1'=0);
	[consensus0] solutions=0 -> (solution1'=0);

	// Reset to prepare for new step
	[reset] winner1=1 -> (winner1'=0)&(age1'=0);
	[reset] winner1=0 -> true;

endmodule

// Agents using agent 1 as a template module
// Module process for agent 2a
module agent2a=agent1 [
age1=age2a,
solution1=solution2a,
winner1=winner2a,
r1=r2a,
age2a=age1,
solution2a=solution1,
winner2a=winner1,
r2a=r1,
consensus1=consensus2a,
consensus2a=consensus1
] endmodule
// Module process for agent 2b
module agent2b=agent1 [
age1=age2b,
solution1=solution2b,
winner1=winner2b,
r1=r2b,
age2b=age1,
solution2b=solution1,
winner2b=winner1,
r2b=r1,
consensus1=consensus2b,
consensus2b=consensus1
] endmodule

// Reward value of 1 or 2 applied to any state
// in which agent 3a or/and 3b found a solution
rewards "agent_elected"
	solution2a = 1 : 1; 
	solution2b = 1 : 1; 
endrewards

// Reward value of [1..n] applied to any state
// in which has agents which found solutions
rewards "total_elected"
	solutions > 0 : solutions; 
endrewards

// Reward value of 1 applied to any state
// in which agent 3a or 3b were chosen as winner
rewards "agent_produced"
	winner2a = 1 : 1;
	winner2b = 1 : 1; 
endrewards

// Reward value of [1..n] applied to any state
// in which winners were chosen
rewards "total_produced"
	winners > 0 : winners; 
endrewards

// Reward value of agent 3a or 3b's coinage applied to any state
// in which either were chosen as winner
rewards "agent_rewards"
	winner2a = 1 : r2a*age2a; 
	winner2b = 1 : r2b*age2b; 
endrewards

// Reward value of (coinage of winner) applied to any state
// in which winners were chosen
rewards "total_rewards"
	winner1 = 1 : r1*age1;
	winner2a = 1 : r2a*age2a;
	winner2b = 1 : r2b*age2b;
endrewards
