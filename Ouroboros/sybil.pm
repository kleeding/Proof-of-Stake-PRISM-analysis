// model type declaration
dtmc

// number of agents
const int n = 4;
// Distribution of stake ratios
const double r3;
const double r1=(1-r3)/(n-1);
const double r2=1-r1-r3;

// How agent 3 will split their stake between the new accounts
const double split=0.5;

// New agents stake ratios
const double r3a=r3*split;
const double r3b=r3-r3a;

// Length of an epoch
const int T=100;

// Process used to simulate biased coin flipping
module leaderSelection

	// local variable to show which agent was 
	// chosen as leader
	leader : [0..n] init 0;

	// Choosing a leader with probability equal to their
	// stake ratio
	[choose] leader=0 -> r1:(leader'=1)
			    +r2:(leader'=2)
			    +r3a:(leader'=3)
			    +r3b:(leader'=4);

	// reset to prepare for next slot
	[reset] leader>0 -> (leader'=0);

endmodule

// Agent 1
module A1

	// 0 - waiting, 1 - produce block, 2 - expect block
	action1 : [0..2] init 0;

	// agent performs an action depending on election result
	[act] action1=0&leader!=0 -> (action1'=leader=1? 1:2);

	// reset to prepare for next slot
	[reset] action1>0 -> (action1'=0);

endmodule

// Agent 2
module A2

	// 0 - waiting, 1 - produce block, 2 - expect block
	action2 : [0..2] init 0;

	// agent performs an action depending on election result
	[act] action2=0&leader!=0 -> (action2'=leader=2? 1:2);

	// reset to prepare for next slot
	[reset] action2>0 -> (action2'=0);

endmodule

// Agent 3a
module A3a

	// 0 - waiting, 1 - produce block, 2 - expect block
	action3a : [0..2] init 0;

	// agent performs an action depending on election result
	[act] action3a=0&leader!=0 -> (action3a'=leader=3? 1:2);

	// reset to prepare for next slot
	[reset] action3a>0 -> (action3a'=0);

endmodule

// Agent 3b
module A3b

	// 0 - waiting, 1 - produce block, 2 - expect block
	action3b : [0..2] init 0;

	// agent performs an action depending on election result
	[act] action3b=0&leader!=0 -> (action3b'=leader=4? 1:2);

	// reset to prepare for next slot
	[reset] action3b>0 -> (action3b'=0);

endmodule

// Using PRISMs module copying functionality
//module A2=A1 [action1=action2] endmodule // Agent 2
//module A3=A1 [action1=action3] endmodule // Agent 3

rewards "slots"
	[reset] true : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 has been elcted
rewards "agent_elected"
	[act] leader=3 : 1;
	[act] leader=4 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which has agents elected
rewards "total_elected"
	[act] leader=1 : 1;
	[act] leader=2 : 1;
	[act] leader=3 : 1;
	[act] leader=4 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3 produced a block
rewards "agent_blocks"
	[reset] action3a=1 : 1;
	[reset] action3b=1 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_blocks"
	[reset] action1=1 : 1;
	[reset] action2=1 : 1;
	[reset] action3a=1 : 1;
	[reset] action3b=1 : 1;
endrewards

// Reward value of reward applied to any state
// in which agent 3 produced a block
rewards "agent_rewards"
	[reset] action3a=1 : 1/T;
	[reset] action3b=1 : 1/T;
endrewards

// Reward value of [1..n]*reward applied to any state
// in which agents produced blocks
rewards "total_rewards"
	[reset] action1=1 : 1/T;
	[reset] action2=1 : 1/T;
	[reset] action3a=1 : 1/T;
	[reset] action3b=1 : 1/T;
endrewards
