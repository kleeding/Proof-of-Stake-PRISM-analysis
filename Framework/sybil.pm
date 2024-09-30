// model type declaration
dtmc

// Distribution of stake
const int s1 = 2; // agent 1's stake
const int s2 = 2; // agent 2's stake
const int s3 = 2; // agent 3's stake

// Parameter set to describe how agent 3's
// stake is split between two accounts
const double split = 0.5; 

const double s3a = s3*split; // agent 3a's stake
const double s3b = s3-s3a; // agent 3's stake updated

// Granularity of each slot
const int g = 1;

// Total stake in the distribution
formula tS = s1 + s2 + s3;

// Probability agent 1 elected to produce a block
formula p = s1/tS/g; // elected

// Total number of agents elected during a sub-slot
formula elected = elected1 + elected2 + elected3a + elected3b;

// Total number of agents with finalised blocks produced
formula produced = produced1 + produced2 + produced3a + produced3b;

// Highest stake of elected agents
formula maxS=max(s1*elected1,s2*elected2,s3a*elected3a,s3b*elected3b);

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
	[consensus3a] elected>0&elected3a=1 -> (elected1'=0);
	[consensus3b] elected>0&elected3b=1 -> (elected1'=0);
	
endmodule

module agent3a=agent1 [
    elected1=elected3a, 
    produced1=produced3a, 
    elected3a=elected1, 
    s1=s3a,
    s3=s1, 
    consensus1=consensus3a, 
    consensus3a=consensus1] 
endmodule // Agent 3a
module agent3b=agent1 [
    elected1=elected3b, 
    produced1=produced3b, 
    elected3b=elected1, 
    s1=s3b,
    s3=s1, 
    consensus1=consensus3b, 
    consensus3b=consensus1] 
endmodule // Agent 3b

// Reward value of 1 applied to any state
// in which either agent 3a, 3b or both have been elected
rewards "A3_elected"
	elected3a = 1 : 1;
	elected3b = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elected"
	elected > 0 : elected;
endrewards

// Reward value of 1 applied to any state
// in which either agent3a, 3b or both produced a block
rewards "A3_produced"
	produced3a = 1 : 1;
	produced3b = 1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_produced"
	produced > 0 : produced;
endrewards

// Reward value of reward applied to any state
// in which either agent3a, 3b or both gained a reward
rewards "A3_rewards"
	produced3a = 1 : reward;
	produced3b = 1 : reward;
endrewards

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	produced > 0 : produced*reward;
endrewards
