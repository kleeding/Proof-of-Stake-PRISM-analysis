// model type declaration
dtmc

// number of agents
const int n = 4;
// Distribution of stake ratios
const double r1;
const double r2;
const double r3;

// How agent 3 will split their stake between the new accounts
const double split;

// New agents stake ratios
const double r3a = r3*split;
const double r3b = r3-r3a;

// granularity parameter
const int g;

// slot coefficient
const double f=1/g;

// probability function
formula pi = 1-pow((1-f),r1);

// number of leaders elected
formula leaders = leader1+leader2+leader3a+leader3b;
// number of blocks finalised
formula blocks = finalised1+finalised2+finalised3a+finalised3b;

// Length of an epoch
const int T=100;

// synchronising process
module stepper

	step : [1..3] init 1;

	[election] step=1 -> (step'=2);
	[consensus0] step=2 -> (step'=3);
	[consensus1] step=2 -> (step'=3);
	[consensus2] step=2 -> (step'=3);
	[consensus3a] step=2 -> (step'=3);
	[consensus3b] step=2 -> (step'=3);

	[reset] step=3 -> (step'=1);

endmodule

// Agent 1
module A1

	// 0 - waiting, 1 - produce block, 2 - expect block
	leader1 : [0..2] init 0;
	finalised1 : [0..1] init 0;

	[election] step=1 -> pi:(leader1'=1)
			  +1-pi:true;

	[consensus0] step=2&leaders=0 -> true;
	[consensus1] step=2&leader1=1 -> (finalised1'=1)
					&(leader1'=0);
	[consensus2] step=2&leader2=1 -> (leader1'=0);
	[consensus3a] step=2&leader3a=1 -> (leader1'=0);
	[consensus3b] step=2&leader3b=1 -> (leader1'=0);

	[reset] step=3 -> (finalised1'=0);

endmodule

// Using PRISMs module copying functionality
module A2=A1 [
leader1=leader2,
leader2=leader1,
finalised1=finalised2,
r1=r2,
consensus1=consensus2,
consensus2=consensus1
] endmodule // Agent 2
module A3a=A1 [
leader1=leader3a,
leader3a=leader1,
finalised1=finalised3a,
r1=r3a,
consensus1=consensus3a,
consensus3a=consensus1
] endmodule // Agent 3a
module A3b=A1 [
leader1=leader3b,
leader3b=leader1,
finalised1=finalised3b,
r1=r3b,
consensus1=consensus3b,
consensus3b=consensus1
] endmodule // Agent 3b
// Reward value of 1 applied to any state
// which finalises blocks
rewards "active_slots"
	[reset] blocks>0 : 1;
endrewards

// Reward value of 1 applied to any state
// which does not finalise a blocks
rewards "empty_slots"
	[reset] blocks=0: 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 has been elcted
rewards "agent_elected"
	leader3a=1 : 1;
	leader3b=1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elected"
	leaders>0 : leaders;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 produced a block
rewards "agent_blocks"
	finalised3a=1 : 1;
	finalised3b=1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_blocks"
	blocks>0 : blocks;
endrewards

// Reward value of reward applied to any state
// in which agent 3 produced a block
rewards "agent_rewards"
	finalised3a=1 : 1/T;
	finalised3b=1 : 1/T;
endrewards

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	blocks>0 : blocks/T;
endrewards
