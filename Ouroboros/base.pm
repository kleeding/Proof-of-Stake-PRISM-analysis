// model type declaration
dtmc

// number of agents
const int n = 3;

// Distribution of stake ratios
const double r1;
const double r2;
const double r3;

// Length of an epoch
const int T=100;

// Process used to simulate biased coin flipping
module LeaderSelection

	// local variable to show which agent was 
	// chosen as leader
	leader : [0..n] init 0;

	// Choosing a leader with probability equal to their
	// stake ratio
	[choose] leader=0 -> r1:(leader'=1)
			    		+r2:(leader'=2)
			    		+r3:(leader'=3);

	// reset to prepare for the next slot
	[reset] leader>0 -> (leader'=0);

endmodule

// Agent 1
module A1

	// 0 - waiting, 1 - produce block, 2 - expect block
	action1 : [0..2] init 0;

	// agent performs an action depending on the election result
	[act] action1=0&leader!=0 -> (action1'=leader=1? 1:2);

	// reset to prepare for the next slot
	[reset] action1>0 -> (action1'=0);

endmodule

// Agent 2
module A2
	action2 : [0..2] init 0;
	[act] action2=0&leader!=0 -> (action2'=leader=2? 1:2);
	[reset] action2>0 -> (action2'=0);
endmodule

// Agent 3
module A3
	action3 : [0..2] init 0;
	[act] action3=0&leader!=0 -> (action3'=leader=3? 1:2);
	[reset] action3>0 -> (action3'=0);
endmodule

// Reward value of 1 applied to any state
// which uses a [reset] command
rewards "slots"
	[reset] true : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 has been elected
rewards "agent_elections"
	[act] leader=3 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elections"
	[act] leader=1 : 1;
	[act] leader=2 : 1;
	[act] leader=3 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 produced a block
rewards "agent_blocks"
	[reset] action3=1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_blocks"
	[reset] action1=1 : 1;
	[reset] action2=1 : 1;
	[reset] action3=1 : 1;
endrewards

// Reward value of reward applied to any state
// in which agent 3 produced a block
rewards "agent_rewards"
	[reset] action3=1 : 1/T;
endrewards

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	[reset] action1=1 : 1/T;
	[reset] action2=1 : 1/T;
	[reset] action3=1 : 1/T;
endrewards
