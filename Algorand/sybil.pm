// model type declaration
dtmc

// number of participants
const int n = 3;
// distribution of stake ratios
const double r3;
const double r1 = (1-r3)/2;
const double r2 = 1-r1-r3;

// How agent 3 will split their stake between the new accounts
const double split;

// New agents stake ratios
const double r3a=r3*split;
const double r3b=r3-r3a;

// total stake
const int totalW = 100;

// distribution of stake
const int w1 = floor(r1*totalW+0.5);
const int w2 = floor(r2*totalW+0.5);
const int w3a = floor(r3a*totalW+0.5);
const int w3b = floor(r3b*totalW+0.5);

// proposal count aim
const int tau;

// probability per sub-user
formula p = tau/totalW;

// agent with maximum stake
formula maxW = max(w1,w2,w3a,w3b);
// total number of proposals during round
formula proposals = proposal1+proposal2+proposal3a+proposal3b;

module Model

	// local variables
	step : [0..2] init 0; // synchronisation stepper
	checked : [0..maxW] init 0; // keeping track of checks
	leader : [0..n+1] init 0; // chosen actual leader

	// Proposal step
	// Agents checking sub-users for proposals/potential leaders
	[proposals] step=0 & checked<maxW -> (checked'=checked+1);
	[proposals] step=0 & checked=maxW -> (step'=1);

	// Selection step
	// Choosing an actual leader from all proposals
	[select] step=1 & proposals>0 -> 
			 proposal1/proposals:(leader'=1)&(step'=2)
                    	+proposal2/proposals:(leader'=2)&(step'=2)
                    	+proposal3a/proposals:(leader'=3)&(step'=2)
                    	+proposal3b/proposals:(leader'=4)&(step'=2);
	// No proposals = No leader
	[select] step=1 & proposals=0 -> (step'=2);
    
	// Reset step - prepare for next round
   	[reset] step=2 -> (leader'=0)&(checked'=0)&(step'=0);

endmodule

// Agent 1 - template agent process
module A1

    	proposal1 : [0..w1] init 0;
    
    	// Step 0 (part 1) - Check for proposals for each sub-user
    	[proposals] step=0 & checked<w1 -> p:(proposal1'=min(proposal1+1,w1))
                                    +1-p:true;
    	// Step 0 (part 1) - Loop (wait) once all sub-users have been checked
    	[proposals] step=0 & checked>=w1 -> true;
    
    	// Step 2 - Reset variables ready for the next round
    	[reset] step=2 -> (proposal1'=0);

endmodule

// Using PRISMs module copying functionality
module A2=A1 [w1=w2, w2=w1, proposal1=proposal2] endmodule // Agent 2
module A3a=A1 [w1=w3a, w3a=w1, proposal1=proposal3a] endmodule // Agent 3
module A3b=A1 [w1=w3b, w3b=w1, proposal1=proposal3b] endmodule // Agent 3

// Reward value of 1 applied to any state
// which uses a [reset] command
rewards "rounds"
    	[reset] true : 1;
endrewards

// Reward value of 1 applied to any state
// transitions to the next slot without having
// chosen a leader
rewards "no_leader"
    	[reset] leader=0 : 1;
endrewards

// Reward value of [1..w3] applied to any state
// in which agent 3a or 3b has potential leaders
rewards "agent_proposals"
    	[select] proposal3a>0 : proposal3a;
    	[select] proposal3b>0 : proposal3b;
endrewards

// Reward value of [1..totalW] applied to any state
// in which potential leaders were elected
rewards "total_proposals"
    	[select] proposals>0 : proposals;
endrewards

// Reward value of 1 applied to each state
// in which agent 3a or 3b has been elected
rewards "agent_elected"
	[select] proposal3a>0 : 1;
	[select] proposal3b>0 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents were elected
rewards "total_elected"
	[select] proposal1>0 : 1;
	[select] proposal2>0 : 1;
	[select] proposal3a>0 : 1;
	[select] proposal3b>0 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3a or 3b produced a block
rewards "agent_blocks"
    	[reset] leader=3 : 1;
    	[reset] leader=4 : 1;
endrewards

// Reward value of [1..n] applied to any state
// in which agents produced blocks
rewards "total_blocks"
	[reset] leader=1 : 1;
	[reset] leader=2 : 1;
	[reset] leader=3 : 1;
	[reset] leader=4 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agent 3a or 3b produced a block
rewards "agent_rewards"
    	[reset] leader=3 : 1;
    	[reset] leader=4 : 1;
endrewards

// Reward value of 1 applied to any state
// in which agents produced blocks
rewards "total_rewards"
	[reset] leader=1 : 1;
	[reset] leader=2 : 1;
	[reset] leader=3 : 1;
	[reset] leader=4 : 1;
endrewards
