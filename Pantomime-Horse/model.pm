// Model type declaration
dtmc

const double ph = 0.5; // probability the head moves forward
const double pb = 0.5; // probability the back moves forward
const int n = 2; // Number of forward steps required for success

// module describing the head process
module head

    dist_h : [0..n] init 0; // distance moved by the head

    // both processes synchronised on 'step' action label
    // head moves forward with probability 'ph' 
    // and does nothing with probability '1-ph'
    [forward] dif>=0&dif<2&dist_h<n -> ph : (dist_h'=dist_h+1) 
                                        + 1-ph : true;
    // once the head has moved n step they can wait 
    // for the back to catch up
    [forward] dif>=0&dif<2&dist_h=n -> true;

    // head performer nods head
    [nod] dif>=0&dif<2&dist_h<n -> true;
    // head performer neighs
    [neigh] dif>=0&dif<2&dist_h<n -> true;

endmodule

// module describing the back process
module back

    dist_b : [0..n] init 0; // distance moved by the back

    // back moves forward with probability 'pb' 
    // and does nothing with probability '1-pb'
    [forward] dif>=0&dif<2&dist_b<n -> pb : (dist_b'=dist_b+1) 
                                    + 1-pb : true;
    //[step] dist_b=n&back_action=1 -> (back_action'=0);

    // back perform wags tail
    [wag] dif>=0&dif<2&dist_b<n -> true;
    // back perform kicks legs
    [kick] dif>=0&dif<2&dist_b<n -> true;

endmodule

formula dif = (dist_h-dist_b);

// Successful End States:
label "success" = dist_h=n&dist_b=n;
// Unsuccessful End States - Critical Failure States
label "tripped" = dif<0;
label "ripped" = dif>=2;

// Reward structure to keep track of how many total actions are used
rewards "time"
    [forward] true : 1;
    [nod] true : 1;
    [neigh] true : 1;
    [wag] true : 1;
    [kick] true : 1;
endrewards

// Reward structure to keep track of how many forward actions are used
rewards "forward"
    [forward] true : 1;
endrewards
