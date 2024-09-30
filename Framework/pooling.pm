// model type declaration
dtmc

// Distribution of stake
const int s1 = 2; // agent 1's stake
const int s2 = 2; // agent 2's stake
const int s3 = 2; // agent 3's stake

// Granularity of each slot
const int g = 1;

// Stake set for new agent
const int s4 = s2+s3; 

// Total stake in the distribution
formula tS = s1 + s2 + s3;

// Probability agent 1 elected to produce a block
formula p = s1/tS/g; // elected

// Total number of agents elected during a sub-slot
formula elected = elected1 + elected4;

// Total number of agents with finalised blocks produced
formula produced = produced1 + produced4;

// Highest stake of elected agents
formula maxS=max(s1*elected1,s4*elected4);

// Agent 1
module agent1

    // Local variables
	elected1  : [0..1] init 0; 
	produced1 : [0..1] init 0;

    // Local election mechanism
	[election] elected=0 -> p  :(elected1'=1)&(produced1'=0) 
			              + 1-p:(elected1'=0)&(produced1'=0);
	
    // Local election mechanism
	[consensus1] elected>0&elected2=1 -> (elected1'=0)
	[consensus4] elected>0&elected4=1 -> (elected1'=0);
	
endmodule

// Agent 4
module agent4=agent1 [
    elected1=elected4, 
    produced1=produced4, 
    elected4=elected1, 
    s1=s4,
    s4=s1, 
    consensus1=consensus4, 
    consensus4=consensus1
    ] 
endmodule

// Reward value of 1 applied to any state
// in which agent 4 had been elected
rewards "A4_elected"
	elected4 = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elected"
	elected > 0 : elected;
endrewards

// Reward value of 1 applied to any state
// in which agent 4 produced a block
rewards "A4_produced"
	produced4 = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_produced"
	produced > 0 : produced;
endrewards

// Reward value of reward applied to any state
// in which agent 4 gained a reward
rewards "A4_rewards"
	produced4 = 1 : reward;
endrewards

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	produced > 0 : produced*reward;
endrewards
