#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ac_int.h>


enum t_SpecSCC_10_fsm_state_new {
					SpecSCC_10_fsm_Proceed = 0,
					SpecSCC_10_fsm_x1__Rollback = 1,
					SpecSCC_10_fsm_x1__Fill0 = 2,
					SpecSCC_10_fsm_x1__Fill1 = 3,
					SpecSCC_10_fsm_Init0 = 4,
					SpecSCC_10_fsm_Init1 = 5
				};

// Struct names
				struct SCC_14_out_0 {
					bool p0_guard;
					int p1;
					bool p2;
					bool p3;
					bool p4;
				};

				struct SCC_14_to_SpecSCC_10_out {
					bool write;
					struct SCC_14_out_0 data;
				};

				struct SpecSCC_10_out_0 {
					int p0;
					bool p1;
					bool p2;
					bool p3;
					int p4;
				};

				struct SpecSCC_10_to_SCC_15_out {
					bool write;
					struct SpecSCC_10_out_0 data;
				};

				struct fifo_SCC_14_to_SpecSCC_10 {
					struct SCC_14_out_0 data_out;
					bool empty;
				};

				struct fifo_SpecSCC_10_to_SCC_15 {
					struct SpecSCC_10_out_0 data_out;
					bool empty;
				};

				struct fsm_cmd_x {
					ac_int<1, false> nextInput;
					ac_int<1, false> commit;
					ac_int<3, false> muRollBack;
					ac_int<32, false> arrayRollBack;
					ac_int<3, false> rewind;
					ac_int<1, false> rbwe;
					ac_int<32, false> gammaRollBack_x;
					ac_int<1, false> startStall_x;
					ac_int<32, false> selSlowPath_x;
				};

				struct fsm_mispec_in_x {
					ac_int<32, false> x;
				};

				struct statex {
					t_SpecSCC_10_fsm_state_new state;
					ac_int<3, false> rewindCpt;
					ac_int<1, false> delayed_commit_0;
					ac_int<1, false> delayed_commit_1;
					ac_int<1, false> delayed_commit_2;
					ac_int<32, false> array_rollback;
					ac_int<3, false> mu_rollback;
					ac_int<3, false> rewind;
					ac_int<1, false> rbwe;
					ac_int<1, false> commit_x;
					ac_int<32, false> selSlowPath_x;
					ac_int<32, false> rollback_x;
					ac_int<1, false> startStall_x;
					ac_int<3, false> rewindDepth;
					ac_int<32, false> slowPath_x;
				};










					struct SCC_14_out_0 SCC_14_SpecSCC_10_data;
					bool SCC_14_SpecSCC_10_empty_flag=true;
					bool SCC_14_SpecSCC_10_full_flag=false;

					bool SCC_14_SpecSCC_10_empty(){
						return SCC_14_SpecSCC_10_empty_flag;
					}

					bool SCC_14_SpecSCC_10_full(){
						return SCC_14_SpecSCC_10_full_flag;
					}

					void SCC_14_SpecSCC_10_read(){
						SCC_14_SpecSCC_10_empty_flag=true;
						SCC_14_SpecSCC_10_full_flag=false;
						return  ;
					}

					void SCC_14_SpecSCC_10_write (struct SCC_14_to_SpecSCC_10_out in){
						if (in.write) {
							SCC_14_SpecSCC_10_empty_flag=false;
							SCC_14_SpecSCC_10_full_flag=true;
							SCC_14_SpecSCC_10_data = in.data;
						}
						return;
					}


					struct SCC_14_out_0 SCC_14_SpecSCC_10_peek(){
						return SCC_14_SpecSCC_10_data ;
					}



						struct SpecSCC_10_out_0 SpecSCC_10_SCC_15_data;
						bool SpecSCC_10_SCC_15_empty_flag=true;
						bool SpecSCC_10_SCC_15_full_flag=false;

						bool SpecSCC_10_SCC_15_empty(){
							return SpecSCC_10_SCC_15_empty_flag;
						}

						bool SpecSCC_10_SCC_15_full(){
							return SpecSCC_10_SCC_15_full_flag;
						}

						void SpecSCC_10_SCC_15_read(){
							SpecSCC_10_SCC_15_empty_flag=true;
							SpecSCC_10_SCC_15_full_flag=false;
							return  ;
						}

						void SpecSCC_10_SCC_15_write (struct SpecSCC_10_to_SCC_15_out in){
							if (in.write) {
								SpecSCC_10_SCC_15_empty_flag=false;
								SpecSCC_10_SCC_15_full_flag=true;
								SpecSCC_10_SCC_15_data = in.data;
							}
							return;
						}


						struct SpecSCC_10_out_0 SpecSCC_10_SCC_15_peek(){
							return SpecSCC_10_SCC_15_data ;
						}



unsigned int next(int lfsr);
int slow(int x);
int fast(int x);
bool mispec(int x);
int i;

int ccycles = 0;
int get_ticks();
int get_trip_count();
int main();
int io_printf(int state,bool enable, const char *fmt, ...);
signed int io_state;

int _SpecSCC_10_dline3_1_dline_0;
int _SpecSCC_10_dline3_1_dline_1;
int _SpecSCC_10_dline3_1_dline_2;
bool _SpecSCC_10_dline2_2_dline_0;
bool _SpecSCC_10_dline2_2_dline_1;
struct statex _SpecSCC_10_dline1_3_dline_0;
ac_int<1, false> SpecSCC_10_nextInput;
ac_int<1, false> SpecSCC_10_commit;
ac_int<3, false> SpecSCC_10_muRollback;
ac_int<3, false> SpecSCC_10_rewind;
ac_int<1, false> SpecSCC_10_rbwe;
ac_int<32, false> SpecSCC_10_selSlowPath_x;
int _SpecSCC_10_dline3_4_dline_0;
int _SpecSCC_10_dline3_4_dline_1;
int _SpecSCC_10_dline3_4_dline_2;
bool _SpecSCC_10_dline3_5_dline_0;
bool _SpecSCC_10_dline3_5_dline_1;
bool _SpecSCC_10_dline3_5_dline_2;
bool _SpecSCC_10_dline3_6_dline_0;
bool _SpecSCC_10_dline3_6_dline_1;
bool _SpecSCC_10_dline3_6_dline_2;
bool _SpecSCC_10_dline3_7_dline_0;
bool _SpecSCC_10_dline3_7_dline_1;
bool _SpecSCC_10_dline3_7_dline_2;
int _SpecSCC_10_dline3_8_dline_0;
int _SpecSCC_10_dline3_8_dline_1;
int _SpecSCC_10_dline3_8_dline_2;
int rollBack_SpecSCC_10_28_x_mu(int in, ac_int<3, false> offset, ac_int<1, false> nextInput);
bool rewind_SpecSCC_10_34(bool in, ac_int<3, false> offset, ac_int<1, false> nextInput);
bool rewind_SpecSCC_10_35(bool in, ac_int<3, false> offset, ac_int<1, false> nextInput);
int rewind_SpecSCC_10_37(int in, ac_int<3, false> offset, ac_int<1, false> nextInput);
bool rewind_SpecSCC_10_39(bool in, ac_int<3, false> offset, ac_int<1, false> nextInput);
bool rewind_SpecSCC_10_41(bool in, ac_int<3, false> offset, ac_int<1, false> nextInput);
bool loop_s;
bool start_s;











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
								state.rewindDepth = (ac_int<3,false>)3;
								state.slowPath_x = (ac_int<32,false>)1;
								state.startStall_x = (ac_int<1,false>)1;
								state.selSlowPath_x = state.slowPath_x;
								state.rbwe = (ac_int<1,false>)1;
								state.array_rollback = (ac_int<32,false>)3;
								state.mu_rollback = (ac_int<3,false>)3;
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
							state.mu_rollback = (ac_int<3,false>)(0);
							state.rewind = (ac_int<3,false>)(0);
							state.rbwe = (ac_int<1,false>)(0);
							state.commit_x = (ac_int<1,false>)(0);
							state.selSlowPath_x = (ac_int<32,false>)(0);
							state.rollback_x = (ac_int<32,false>)(0);
							state.startStall_x = (ac_int<1,false>)(0);
							state.rewindDepth = (ac_int<3,false>)(0);
							state.slowPath_x = (ac_int<32,false>)(0);
				}
				return state;
			}
			}




struct fsm_cmd_x fsm_x_command(struct statex cs) {
{
	#pragma HLS inline
	struct fsm_cmd_x result;
	result.nextInput= (cs.rewindCpt == (ac_int<3,false>)0) ? (ac_int<1, false>)1 : (ac_int<1, false>)0;
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
	currentState.mu_rollback = (ac_int<3,false>)0;
	currentState.rewind = (ac_int<3,false>)0;
	currentState.rbwe = (ac_int<1,false>)0;
	currentState.commit_x = (ac_int<1,false>)0;
	currentState.selSlowPath_x = (ac_int<32,false>)0;
	currentState.rollback_x = (ac_int<32,false>)0;
	currentState.startStall_x = (ac_int<1,false>)0;

		currentState = SpecSCC_10_fsm_nxt(mispecBits.x, currentState);



		if (currentState.rewindCpt > (ac_int<3,false>)0) {
			currentState.rewindCpt = currentState.rewindCpt - (ac_int<3,false>)1;
		}

		currentState.rewindCpt += currentState.rewind;

		currentState.delayed_commit_0 = currentState.delayed_commit_1 & currentState.commit_x;
		currentState.delayed_commit_1 = currentState.delayed_commit_2 ;
		currentState.delayed_commit_2 = (ac_int<1,false>)1 ;

		return currentState;
}

/*
unsigned int next(int lfsr) {
			{
				
				#pragma HLS INLINE on
				int _bit;
				
				_bit = 0u;
				_bit = (lfsr >> 0u ^ lfsr >> 2u ^ lfsr >> 3u ^ lfsr >> 5u) & 1u;
				lfsr = lfsr >> 1 | _bit << 15;
				return lfsr;
			}
			}

int slow(int x) {
			
			#pragma SHLS LATENCY min=5 max=5
			
			#pragma HLS INLINE off
			{
				return x % (1 << 15) * (x % (1 << 15));
			}
			}

int fast(int x) {
			{
				return x + 1;
			}
			}

bool mispec(int x) {
			
			#pragma SHLS LATENCY min=3 max=3
			
			#pragma HLS INLINE off
			{
				return (next(x) + 1 & 0x3) == 0;
			}
			}
*/
bool mispec(int x);
int fast(int x);
int slow(int x);
struct fsm_mispec_in_x fsm_mispec_in_x_value_0(ac_int<32, false> p_0) {
			{
				struct fsm_mispec_in_x res;
				
				res.x = p_0;
				return res;
			}
			}

struct SpecSCC_10_out_0 SpecSCC_10_out_0_value_1(int p_0, bool p_1, bool p_2, bool p_3, int p_4) {
			{
				struct SpecSCC_10_out_0 res;
				
				res.p0 = p_0;
				res.p1 = p_1;
				res.p2 = p_2;
				res.p3 = p_3;
				res.p4 = p_4;
				return res;
			}
			}

struct SpecSCC_10_to_SCC_15_out SpecSCC_10_to_SCC_15_out_value_2(bool p_0, struct SpecSCC_10_out_0 p_1) {
			{
				struct SpecSCC_10_to_SCC_15_out res;
				
				res.write = p_0;
				res.data = p_1;
				return res;
			}
			}

struct SCC_14_out_0 SCC_14_out_0_value_3(bool p_0, int p_1, bool p_2, bool p_3, bool p_4) {
			{
				struct SCC_14_out_0 res;
				
				res.p0_guard = p_0;
				res.p1 = p_1;
				res.p2 = p_2;
				res.p3 = p_3;
				res.p4 = p_4;
				return res;
			}
			}

struct SCC_14_to_SpecSCC_10_out SCC_14_to_SpecSCC_10_out_value_4(bool p_0, struct SCC_14_out_0 p_1) {
			{
				struct SCC_14_to_SpecSCC_10_out res;
				
				res.write = p_0;
				res.data = p_1;
				return res;
			}
			}



struct statex statex_value_5(
		t_SpecSCC_10_fsm_state_new p_0,
		ac_int<3, false> p_1,
		ac_int<1, false> p_2,
		ac_int<1, false> p_3,
		ac_int<1, false> p_4,
		ac_int<32, false> p_5,
		ac_int<3, false> p_6,
		ac_int<3, false> p_7,
		ac_int<1, false> p_8,
		ac_int<1, false> p_9,
		ac_int<32, false> p_10,
		ac_int<32, false> p_11,
		ac_int<1, false> p_12,
		ac_int<3, false> p_13,
		ac_int<32, false> p_14) {
			{
				struct statex res;
				
				res.state = p_0;
				res.rewindCpt = p_1;
				res.delayed_commit_0 = p_2;
				res.delayed_commit_1 = p_3;
				res.delayed_commit_2 = p_4;
				res.array_rollback = p_5;
				res.mu_rollback = p_6;
				res.rewind = p_7;
				res.rbwe = p_8;
				res.commit_x = p_9;
				res.selSlowPath_x = p_10;
				res.rollback_x = p_11;
				res.startStall_x = p_12;
				res.rewindDepth = p_13;
				res.slowPath_x = p_14;
				return res;
			}
			}

struct statex fsmx_init() {
			{
				return statex_value_5(
						SpecSCC_10_fsm_Init0,
						(ac_int<3, false>)0,
						(ac_int<1, false>)0,
						(ac_int<1, false>)0,
						(ac_int<1, false>)0,
						(ac_int<32, false>)0,
						(ac_int<3, false>)0,
						(ac_int<3, false>)0,
						(ac_int<1, false>)1,
						(ac_int<1, false>)0,
						(ac_int<32, false>)0,
						(ac_int<32, false>)0,
						(ac_int<1, false>)0,
						(ac_int<3, false>)0,
						(ac_int<32, false>)0);
			}
			}

void SpecSCC_10_dline3_1_push(int data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_1_dline_2 = _SpecSCC_10_dline3_1_dline_1;
					_SpecSCC_10_dline3_1_dline_1 = _SpecSCC_10_dline3_1_dline_0;
					_SpecSCC_10_dline3_1_dline_0 = data_in;
				}
			}
			}

int SpecSCC_10_dline3_1_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline3_1_dline_2;
			}
			}

void SpecSCC_10_dline2_2_push(bool data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline2_2_dline_1 = _SpecSCC_10_dline2_2_dline_0;
					_SpecSCC_10_dline2_2_dline_0 = data_in;
				}
			}
			}

bool SpecSCC_10_dline2_2_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline2_2_dline_1;
			}
			}

void SpecSCC_10_dline1_3_push(struct statex data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline1_3_dline_0 = data_in;
				}
			}
			}

struct statex SpecSCC_10_dline1_3_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline1_3_dline_0;
			}
			}

void SpecSCC_10_dline1_3_init(struct statex data_in) {
			{
				_SpecSCC_10_dline1_3_dline_0 = data_in;
			}
			}

void SpecSCC_10_dline3_4_push(int data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_4_dline_2 = _SpecSCC_10_dline3_4_dline_1;
					_SpecSCC_10_dline3_4_dline_1 = _SpecSCC_10_dline3_4_dline_0;
					_SpecSCC_10_dline3_4_dline_0 = data_in;
				}
			}
			}

int SpecSCC_10_dline3_4_pop(bool pop_enable) {
			{

				if (pop_enable) {}
				return _SpecSCC_10_dline3_4_dline_2;
			}
			}

void SpecSCC_10_dline3_5_push(bool data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_5_dline_2 = _SpecSCC_10_dline3_5_dline_1;
					_SpecSCC_10_dline3_5_dline_1 = _SpecSCC_10_dline3_5_dline_0;
					_SpecSCC_10_dline3_5_dline_0 = data_in;
				}
			}
			}

bool SpecSCC_10_dline3_5_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline3_5_dline_2;
			}
			}

void SpecSCC_10_dline3_6_push(bool data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_6_dline_2 = _SpecSCC_10_dline3_6_dline_1;
					_SpecSCC_10_dline3_6_dline_1 = _SpecSCC_10_dline3_6_dline_0;
					_SpecSCC_10_dline3_6_dline_0 = data_in;
				}
			}
			}

bool SpecSCC_10_dline3_6_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline3_6_dline_2;
			}
			}

void SpecSCC_10_dline3_7_push(bool data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_7_dline_2 = _SpecSCC_10_dline3_7_dline_1;
					_SpecSCC_10_dline3_7_dline_1 = _SpecSCC_10_dline3_7_dline_0;
					_SpecSCC_10_dline3_7_dline_0 = data_in;
				}
			}
			}

bool SpecSCC_10_dline3_7_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline3_7_dline_2;
			}
			}

void SpecSCC_10_dline3_8_push(int data_in, bool push_enable) {
			{
				if (push_enable) {
					_SpecSCC_10_dline3_8_dline_2 = _SpecSCC_10_dline3_8_dline_1;
					_SpecSCC_10_dline3_8_dline_1 = _SpecSCC_10_dline3_8_dline_0;
					_SpecSCC_10_dline3_8_dline_0 = data_in;
				}
			}
			}

int SpecSCC_10_dline3_8_pop(bool pop_enable) {
			{
				if (pop_enable) {}
				return _SpecSCC_10_dline3_8_dline_2;
			}
			}

				int x;
				bool guard;
				struct fsm_cmd_x cmd;
				bool _guard_0;
				int _i_1;
				struct SCC_14_to_SpecSCC_10_out SCC_14_out_0_var;
				struct SCC_14_out_0 SpecSCC_10_in_0;
				int _SpecSCC_10_dline3_1_pop_0;
				bool _SpecSCC_10_dline2_2_pop_1;
				struct statex _SpecSCC_10_dline1_3_pop_2;
				int _SpecSCC_10_dline3_4_pop_3;
				bool _SpecSCC_10_dline3_5_pop_4;
				bool _SpecSCC_10_dline3_6_pop_5;
				bool _SpecSCC_10_dline3_7_pop_6;
				int _SpecSCC_10_dline3_8_pop_7;
				int _rollBack_SpecSCC_10_28_x_mu_8;
				int _x_9;
				int SpecSCC_10_mu_x_10;
				struct statex _fsm_x_next_11;
				bool _mispec_12;
				int _slow_13;
				int _fast_14;
				bool _rewind_SpecSCC_10_34_15;
				bool _rewind_SpecSCC_10_35_16;
				int _rewind_SpecSCC_10_37_17;
				bool _rewind_SpecSCC_10_39_18;
				bool _rewind_SpecSCC_10_41_19;
				struct SpecSCC_10_to_SCC_15_out SpecSCC_10_out_0_var;
				struct SpecSCC_10_out_0 SCC_15_in_0;
				signed int _io_state_0;
				int _io_printf_1;

void init_single_spec() {
				x = 0x12345678;
				io_state = 0;
				guard = true;
				SpecSCC_10_dline1_3_init(fsmx_init());
				start_s = true;
				loop_s = true;
				ccycles = -1;
}

void next_single_spec() {
				while (loop_s) {


						ccycles = ccycles + 1;
						if (!SpecSCC_10_SCC_15_empty()) {
							SCC_15_in_0 = SpecSCC_10_SCC_15_peek();
							_io_state_0 = io_state;
							loop_s = !((!SCC_15_in_0.p1));
							_io_printf_1 = 0;
							io_state = SCC_15_in_0.p2 ? _io_printf_1 : _io_state_0;
							if (true)
								SpecSCC_10_SCC_15_read();
						}
						if ((!SCC_14_SpecSCC_10_empty()) && (!SpecSCC_10_SCC_15_full())) {
							SpecSCC_10_in_0 = SCC_14_SpecSCC_10_peek();
							_SpecSCC_10_dline3_1_pop_0 = SpecSCC_10_dline3_1_pop(true);
							_SpecSCC_10_dline2_2_pop_1 = SpecSCC_10_dline2_2_pop(true);
							_SpecSCC_10_dline1_3_pop_2 = SpecSCC_10_dline1_3_pop(true);
							cmd = fsm_x_command(_SpecSCC_10_dline1_3_pop_2);
							SpecSCC_10_nextInput = cmd.nextInput;
							SpecSCC_10_commit = cmd.commit;
							SpecSCC_10_muRollback = cmd.muRollBack;
							SpecSCC_10_rewind = cmd.rewind;
							SpecSCC_10_rbwe = cmd.rbwe;
							SpecSCC_10_selSlowPath_x = cmd.selSlowPath_x;
							_SpecSCC_10_dline3_4_pop_3 = SpecSCC_10_dline3_4_pop(true);
							_SpecSCC_10_dline3_5_pop_4 = SpecSCC_10_dline3_5_pop(true);
							_SpecSCC_10_dline3_6_pop_5 = SpecSCC_10_dline3_6_pop(true);
							_SpecSCC_10_dline3_7_pop_6 = SpecSCC_10_dline3_7_pop(true);
							_SpecSCC_10_dline3_8_pop_7 = SpecSCC_10_dline3_8_pop(true);
							SpecSCC_10_mu_x_10 = x;
							//_rollBack_SpecSCC_10_28_x_mu_8 = rollBack_SpecSCC_10_28_x_mu(SpecSCC_10_mu_x_10, SpecSCC_10_muRollback, SpecSCC_10_rbwe);
							_rollBack_SpecSCC_10_28_x_mu_8 = rollBack_SpecSCC_10_28_x_mu(0, (ac_int<3, false>)0, (ac_int<1, false>)0);
							_fsm_x_next_11 = fsm_x_next(
									fsm_mispec_in_x_value_0(
											_SpecSCC_10_dline2_2_pop_1 ? (ac_int<32, false>)1 : (ac_int<32, false>)0
									),
									_SpecSCC_10_dline1_3_pop_2
							);
							SpecSCC_10_dline1_3_push(_fsm_x_next_11, true);
							_mispec_12 = mispec(_rollBack_SpecSCC_10_28_x_mu_8);
							SpecSCC_10_dline2_2_push((bool)(_mispec_12), true);
							_slow_13 = slow(_rollBack_SpecSCC_10_28_x_mu_8);
							SpecSCC_10_dline3_1_push((int)(_slow_13), true);
							_fast_14 = fast(_rollBack_SpecSCC_10_28_x_mu_8);
							_x_9 = (bool)SpecSCC_10_selSlowPath_x ? _SpecSCC_10_dline3_1_pop_0 : _fast_14;
							SpecSCC_10_dline3_4_push((int)(_x_9), true);
							_rewind_SpecSCC_10_34_15 = rewind_SpecSCC_10_34(SpecSCC_10_in_0.p2, SpecSCC_10_rewind, SpecSCC_10_nextInput);
							x = _rewind_SpecSCC_10_34_15 ? _x_9 : _rollBack_SpecSCC_10_28_x_mu_8;
							_rewind_SpecSCC_10_35_16 = rewind_SpecSCC_10_35(SpecSCC_10_in_0.p0_guard, SpecSCC_10_rewind, SpecSCC_10_nextInput);
							SpecSCC_10_dline3_5_push((bool)(_rewind_SpecSCC_10_35_16), true);
							_rewind_SpecSCC_10_37_17 = rewind_SpecSCC_10_37(SpecSCC_10_in_0.p1, SpecSCC_10_rewind, SpecSCC_10_nextInput);
							SpecSCC_10_dline3_8_push((int)(_rewind_SpecSCC_10_37_17), true);
							_rewind_SpecSCC_10_39_18 = rewind_SpecSCC_10_39(SpecSCC_10_in_0.p3, SpecSCC_10_rewind, SpecSCC_10_nextInput);
							SpecSCC_10_dline3_6_push((bool)(_rewind_SpecSCC_10_39_18), true);
							_rewind_SpecSCC_10_41_19 = rewind_SpecSCC_10_41(SpecSCC_10_in_0.p4, SpecSCC_10_rewind, SpecSCC_10_nextInput);
							SpecSCC_10_dline3_7_push((bool)(_rewind_SpecSCC_10_41_19), true);
							SpecSCC_10_out_0_var = SpecSCC_10_to_SCC_15_out_value_2((bool)SpecSCC_10_commit, SpecSCC_10_out_0_value_1(_SpecSCC_10_dline3_4_pop_3, _SpecSCC_10_dline3_5_pop_4, _SpecSCC_10_dline3_6_pop_5, _SpecSCC_10_dline3_7_pop_6, _SpecSCC_10_dline3_8_pop_7));
							SpecSCC_10_SCC_15_write(SpecSCC_10_out_0_var);
							if ((bool)cmd.nextInput)
								SCC_14_SpecSCC_10_read();
						}
						if (!SCC_14_SpecSCC_10_full()) {
							_guard_0 = guard;
							_i_1 = i;
							i = _guard_0 ? _i_1 + 1 : _i_1;
							guard = i < 1024;
							SCC_14_out_0_var = SCC_14_to_SpecSCC_10_out_value_4(true, SCC_14_out_0_value_3(guard, _i_1, (bool)(_guard_0), (bool)(_guard_0), (bool)(_guard_0)));
							SCC_14_SpecSCC_10_write(SCC_14_out_0_var);
						}
						start_s = false;

				}

}

#pragma toplevel
void run() {
	init:
	;
	;
	while(true) {
		next:
		;
		;
	}
}
