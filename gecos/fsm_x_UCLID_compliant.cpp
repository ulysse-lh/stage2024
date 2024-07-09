#include <ac_int.h>
#include <stdio.h>
		
struct fsm_cmd_x {
	bool nextInput;
	ac_int<1,false> commit;
	ac_int<32,false> muRollBack;
	ac_int<32,false> arrayRollBack;
	ac_int<2,false> rewind;
	ac_int<1,false> rbwe;
	ac_int<32,false> gammaRollBack_x;
	ac_int<1,false> startStall_x;
	ac_int<32,false> selSlowPath_x;
};

enum t_SpecSCC_10_fsm_state_new {
					SpecSCC_10_fsm_Proceed = 0,
					SpecSCC_10_fsm_x1__Rollback = 1,
					SpecSCC_10_fsm_x1__Fill0 = 2,
					SpecSCC_10_fsm_x1__Fill1 = 3,
					SpecSCC_10_fsm_Init0 = 4,
					SpecSCC_10_fsm_Init1 = 5
				};

struct statex {
	t_SpecSCC_10_fsm_state_new state;
	ac_int<2,false> rewindCpt;
	ac_int<1,false> delayed_commit_0;
	ac_int<1,false> delayed_commit_1;
	ac_int<1,false> delayed_commit_2;
	ac_int<32,false> array_rollback;
	ac_int<32,false> mu_rollback;
	ac_int<2,false> rewind;
	ac_int<1,false> rbwe;
	ac_int<1,false> commit_x;
	ac_int<32,false> selSlowPath_x;
	ac_int<32,false> rollback_x;
	ac_int<1,false> startStall_x;
	ac_int<2,false> rewindDepth;
	ac_int<32,false> slowPath_x;
};






struct statex SpecSCC_10_fsm_nxt(ac_int<32,false> mispec_x, struct statex state);


struct statex SpecSCC_10_fsm_nxt(ac_int<32,false> mispec_x, struct statex state) {
			
			#pragma HLS INLINE
			{
				switch (state.state) {
					case SpecSCC_10_fsm_Proceed: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.commit_x = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							state.commit_x = (ac_int<1,false>)1;
							if (mispec_x == (ac_int<32,false>)1) {
								state.state = SpecSCC_10_fsm_x1__Rollback;
								state.rbwe = (ac_int<1,false>)0;
								state.commit_x = (ac_int<1,false>)0;
								state.rewindDepth = (ac_int<2,false>)3;
								state.slowPath_x = (ac_int<32,false>)1;
								state.startStall_x = (ac_int<1,false>)1;
								state.selSlowPath_x = state.slowPath_x;
								state.rbwe = (ac_int<1,false>)1;
								state.array_rollback = (ac_int<32,false>)3;
								state.mu_rollback = (ac_int<32,false>)3;
								state.rewind = state.rewindDepth;
							}
							break;
						}
					case SpecSCC_10_fsm_x1__Rollback: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							if (true)
								state.state = SpecSCC_10_fsm_x1__Fill0;
							break;
						}
					case SpecSCC_10_fsm_x1__Fill0: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							if (true)
								state.state = SpecSCC_10_fsm_x1__Fill1;
							break;
						}
					case SpecSCC_10_fsm_x1__Fill1: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							state.commit_x = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							if (true)
								state.state = SpecSCC_10_fsm_Proceed;
							break;
						}
					case SpecSCC_10_fsm_Init0: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							if (true)
								state.state = SpecSCC_10_fsm_Init1;
							break;
						}
					case SpecSCC_10_fsm_Init1: 
						{
							state.rbwe = (ac_int<1,false>)1;
							state.selSlowPath_x = (ac_int<32,false>)0;
							if (true)
								state.state = SpecSCC_10_fsm_Proceed;
							break;
						}
					default:
							state.array_rollback = (ac_int<32,false>)(0);
							state.mu_rollback = (ac_int<32,false>)(0);
							state.rewind = (ac_int<2,false>)(0);
							state.rbwe = (ac_int<1,false>)(0);
							state.commit_x = (ac_int<1,false>)(0);
							state.selSlowPath_x = (ac_int<32,false>)(0);
							state.rollback_x = (ac_int<32,false>)(0);
							state.startStall_x = (ac_int<1,false>)(0);
							state.rewindDepth = (ac_int<2,false>)(0);
							state.slowPath_x = (ac_int<32,false>)(0);
				}
				return state;
			}
			}

		
struct fsm_mispec_in_x {
ac_int<32,false> x;
};


struct fsm_cmd_x fsm_x_command(struct statex cs) {
{
	#pragma HLS inline
	struct fsm_cmd_x result;
	result.nextInput= (cs.rewindCpt == (ac_int<2,false>)0);
	result.commit=cs.delayed_commit_0;
	result.rewind=cs.rewind;
	result.muRollBack=cs.mu_rollback;
	result.arrayRollBack=cs.array_rollback;
	result.gammaRollBack_x=cs.rollback_x;
	result.selSlowPath_x=cs.selSlowPath_x;
	result.startStall_x=cs.startStall_x;
	result.rbwe = cs.rbwe;
	return result;
}
}

struct statex fsm_x_next(struct fsm_mispec_in_x mispecBits, struct statex currentState) 
{
	
	#pragma HLS inline
	//We set all state outputs to zero
	currentState.array_rollback = (ac_int<32,false>)0;
	currentState.mu_rollback = (ac_int<32,false>)0;
	currentState.rewind = (ac_int<2,false>)0;
	currentState.rbwe = (ac_int<1,false>)0;
	currentState.commit_x = (ac_int<1,false>)0;
	currentState.selSlowPath_x = (ac_int<32,false>)0;
	currentState.rollback_x = (ac_int<32,false>)0;
	currentState.startStall_x = (ac_int<1,false>)0;
	
		currentState = SpecSCC_10_fsm_nxt(mispecBits.x, currentState);
	
	
		/*if (currentState.state < 0 || currentState.state >= 6 ) {
			printf(" Illegal State %d ",currentState.state);
		}*/
		
		if (currentState.rewindCpt > (ac_int<2,false>)0) {
			currentState.rewindCpt = currentState.rewindCpt - (ac_int<2,false>)1;
		}
		
		currentState.rewindCpt += currentState.rewind;
		
		currentState.delayed_commit_0 = currentState.delayed_commit_1 & currentState.commit_x;
		currentState.delayed_commit_1 = currentState.delayed_commit_2 ;
		currentState.delayed_commit_2 = (ac_int<1,false>)1 ;

		return currentState;
}					

#pragma toplevel
void stuff() {
	init:
	{}
	while (true) {
		next:{}
	}

}

