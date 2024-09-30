// model type declaration
dtmc

// Distribution of stake
const int s1 = 2; // agent 1's stake
const int s2 = 2; // agent 2's stake
const int s3 = 2; // agent 3's stake

// Granularity of each slot
const int g = 1;

// Total stake in the distribution
formula tS = s1 + s2 + s3;

// Probability agent 1 elected to produce a block
formula p = s1/tS/g; // elected

// Total number of agents elected during a sub-slot
formula elected = elected1 + elected2 + elected3;

// Total number of agents with finalised blocks produced
formula produced = produced1 + produced2 + produced3;

// Reward function - static
formula reward = 1;

// Agent 1
module agent1

    // Local variables
	elected1  : [0..1] init 0; 
	produced1 : [0..1] init 0;

    // Local election mechanism
	[election] elected=0 -> p  :(elected1'=1)&(produced1'=0) 
			                + 1-p:(elected1'=0)&(produced1'=0);
	
    // Random selection rule
	[consensus1] elected>0&elected1=1 -> (produced1'=1)&(elected1'=0);
	[consensus2] elected>0&elected2=1 -> (elected1'=0);
	[consensus3] elected>0&elected3=1 -> (elected1'=0);
	
endmodule

// PRISMS module copying functionality
// used to create multiple agents easily
// Agent 2
module agent2=agent1 [
    elected1=elected2, 
    produced1=produced2, 
    elected2=elected1, 
    s1=s2,
    s2=s1, 
    consensus1=consensus2, 
    consensus2=consensus1
    ] 
endmodule
// Agent 3
module agent3=agent1 [
    elected1=elected3,
    produced1=produced3,
    elected3=elected1,
    s1=s3,
    s3=s1,
    consensus1=consensus3,
    consensus3=consensus1
    ] 
endmodule

// Labels describing 
// a state that has a conflict
label "conflict" = elected>1;
// a state that has had multiple blocks finalised
label "failure" = produced>1;

// Reward value of 1 applied to any state
// that has an action label: elected
rewards "subslots"
	[election] true : 1;
endrewards

// Reward value of 1 applied to any state
// that has an action label: elected
rewards "slots"
	[election] true : 1/g;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 has been elcted
rewards "A3_elected"
	elected3 = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elected"
	elected > 0 : elected;
endrewards

// Reward value of 1 applied to any state
// in which conflicts had occurred 
// (multiple agents elected)
rewards "conflicts"
	elected > 1 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 produced a block
rewards "A3_produced"
	produced3 = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_produced"
	produced > 0 : produced;
endrewards

// Reward value of reward applied to any state
// in which agent 3 produced a block
rewards "A3_rewards"
	produced3 = 1 : reward;

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	produced > 0 : produced*reward;
endrewards
endrewards
