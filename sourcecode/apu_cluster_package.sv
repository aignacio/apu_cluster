////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 ETH Zurich, University of Bologna                       //
// All rights reserved.                                                       //
//                                                                            //
// This code is under development and not yet released to the public.         //
// Until it is released, the code is under the copyright of ETH Zurich        //
// and the University of Bologna, and may contain unpublished work.           //
// Any reuse/redistribution should only be under explicit permission.         //
//                                                                            //
// Bug fixes and contributions will eventually be released under the          //
// SolderPad open hardware license and under the copyright of ETH Zurich      //
// and the University of Bologna.                                             //
//                                                                            //
// Engineer:       Michael Gautschi - gautschi@iis.ee.ethz.ch                 //
//                                                                            //
// Design Name:    apu_cluster_package                                        //
// Project Name:   Shared APU                                                 //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    dummy file to include the right package                    //
//                 if used in pulp, include the cluster package               //
//                 otherwise define the parameters to test the unit standalone//
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

`include "ulpsoc_defines.sv"

`ifdef APU_CLUSTER
`include "apu_package.sv"
import apu_package::*;

`else

package apu_package;
   
   parameter C_NB_CORES   = `NB_CORES;

   // CPU side / general params
   parameter WARG          = 32;
   parameter WRESULT       = 32;

   parameter NARGS_CPU     = 3;
   parameter WOP_CPU       = 6;
   parameter NUSFLAGS_CPU  = 0;
   parameter NDSFLAGS_CPU  = 15;

   parameter WCPUTAG       = 0;
   parameter WAPUTAG       = (WCPUTAG+$clog2(C_NB_CORES));
   
   // apu units defines
   parameter PRIVATE_FP_ADDSUB = 1;
   parameter PRIVATE_FP_MULT   = 1;
   parameter PRIVATE_FP_MAC    = 1;
   parameter PRIVATE_FP_CAST   = 1;
   parameter PRIVATE_FP_DIV    = 0;
   parameter PRIVATE_FP_SQRT   = 0;
   parameter PRIVATE_FP_DIVSQRT= 1;
   
   // DSP-general
   parameter DSP_WIDTH    = 32;
   parameter DSP_OP_WIDTH = 3;

   parameter SHARED_DSP_MULT = 1;
   parameter SHARED_INT_MULT = 0;
   parameter SHARED_INT_DIV  = 0;

   // FP-general
   parameter FP_ENABLE    = 1;
   parameter SHARED_FP    = 1;
   parameter FP_WIDTH     = 32;
   parameter SIG_WIDTH    = 23;
   parameter EXP_WIDTH    = 8;
   parameter IEEE_COMP    = 1;
   parameter APUTYPE_FP   = (SHARED_FP) ? SHARED_DSP_MULT + SHARED_INT_MULT + SHARED_INT_DIV : 0;
   parameter APU_FLAGS_FP = 2;

   parameter SHARED_FP_DIV   = (SHARED_FP) ? 0 : 0;
   parameter SHARED_FP_SQRT  = (SHARED_FP) ? 0 : 0;
   parameter SHARED_DIVSQRT  = 1;

   // DSP-Mult
   parameter NDSFLAGS_DSP_MULT  = 2;
   parameter NUSFLAGS_DSP_MULT  = 0;
   parameter APUTYPE_DSP_MULT   = (SHARED_DSP_MULT) ? 0 : 0;
   parameter integer NAPUS_DSP_MULT = (C_NB_CORES==2) ? 1 : C_NB_CORES/2;
   parameter WOP_DSP_MULT       = 3;
   parameter PIPE_REG_DSP_MULT  = 1;
   parameter APU_FLAGS_DSP_MULT = 0;
   
   // Int-Mult
   parameter NDSFLAGS_INT_MULT  = 8;
   parameter NUSFLAGS_INT_MULT  = 0;
   parameter APUTYPE_INT_MULT   = (SHARED_INT_MULT) ? SHARED_DSP_MULT : 0;
   parameter integer NAPUS_INT_MULT = (C_NB_CORES==2) ? 1 : C_NB_CORES/2;
   parameter WOP_INT_MULT       = 3;
   parameter APU_FLAGS_INT_MULT = 1;
   
   // Int-div
   parameter NDSFLAGS_INT_DIV   = 0;
   parameter NUSFLAGS_INT_DIV   = 0;
   parameter APUTYPE_INT_DIV    = (SHARED_INT_DIV) ? SHARED_DSP_MULT + SHARED_INT_MULT : 0;
   parameter integer NAPUS_INT_DIV = (C_NB_CORES==2) ? 1 : C_NB_CORES/4;
   parameter WOP_INT_DIV        = 3;
      
   // addsub
   parameter NDSFLAGS_ADDSUB  = 3;
   parameter NUSFLAGS_ADDSUB  = 8;
   parameter APUTYPE_ADDSUB   = (SHARED_FP) ? APUTYPE_FP   : 0;
   parameter integer NAPUS_ADDSUB = (PRIVATE_FP_ADDSUB) ? C_NB_CORES : C_NB_CORES/2;
   parameter WOP_ADDSUB       = 1;
   parameter PIPE_REG_ADDSUB  = 1;
         
   // mult
   parameter NDSFLAGS_MULT = 3;
   parameter NUSFLAGS_MULT = 8;
   parameter APUTYPE_MULT  = (SHARED_FP) ? APUTYPE_FP+1  : 0;
   parameter integer NAPUS_MULT = (PRIVATE_FP_MULT) ? C_NB_CORES : (C_NB_CORES==2) ? 1 : C_NB_CORES/4;
   parameter WOP_MULT      = 1;
   parameter PIPE_REG_MULT = 1;
   
   // casts
   parameter NDSFLAGS_CAST = 3;
   parameter NUSFLAGS_CAST = 8;
   parameter APUTYPE_CAST  = (SHARED_FP) ? APUTYPE_FP+2  : 0;
   parameter integer NAPUS_CAST = (PRIVATE_FP_CAST) ? C_NB_CORES : (C_NB_CORES==2) ? 1 : C_NB_CORES/4;
   parameter WOP_CAST      = 1;
   parameter PIPE_REG_CAST = 1;
   
   // mac
   parameter NDSFLAGS_MAC = 3;
   parameter NUSFLAGS_MAC = 8;
   parameter APUTYPE_MAC  = (SHARED_FP) ? APUTYPE_FP+3  : 0;
   parameter integer NAPUS_MAC = (PRIVATE_FP_MAC) ? C_NB_CORES : (C_NB_CORES==2) ? 1 : C_NB_CORES/4;
   parameter WOP_MAC      = 2;
   parameter PIPE_REG_MAC = 2;
   
   // div
   parameter NDSFLAGS_DIV = 3;
   parameter NUSFLAGS_DIV = 8;
   parameter APUTYPE_DIV  = (SHARED_FP_DIV) ? APUTYPE_FP+4 : 0;
   parameter integer NAPUS_DIV    = (PRIVATE_FP_DIV) ? C_NB_CORES : 1;
   parameter WOP_DIV      = 1;
   parameter PIPE_REG_DIV = 4;
   
   // sqrt
   parameter NDSFLAGS_SQRT = 3;
   parameter NUSFLAGS_SQRT = 8;
   parameter APUTYPE_SQRT  = (SHARED_FP_SQRT) ? APUTYPE_FP+5 : 0;
   parameter integer NAPUS_SQRT    = (PRIVATE_FP_SQRT) ? C_NB_CORES  : 1;
   parameter WOP_SQRT      = 1;
   parameter PIPE_REG_SQRT = 5;
   
   // iter divsqrt
   parameter NDSFLAGS_DIVSQRT = 3;
   parameter NUSFLAGS_DIVSQRT = 8;
   parameter APUTYPE_DIVSQRT  = (SHARED_DIVSQRT) ? APUTYPE_FP+4 : 0;
   parameter integer NAPUS_DIVSQRT    = (PRIVATE_FP_DIVSQRT) ? C_NB_CORES : 1;
   parameter WOP_DIVSQRT      = 1;
   
   // FP-defines
   parameter C_NAN_P = 32'h7fc00000;
   parameter C_NAN_N = 32'hffc00000;
   parameter C_ZERO_P = 32'h00000000;
   parameter C_ZERO_N = 32'h80000000;
   parameter C_INF_P = 32'h7f800000;
   parameter C_INF_N = 32'hff800000;
   parameter C_MAX_INT = 32'h7fffffff;
   parameter C_MIN_INT = 32'h80000000;
   parameter C_MAX_INT_F = (2**31)-1;
   parameter C_MIN_INT_F = -(2**31);


   // generated values
   parameter C_APUTYPES   = (SHARED_FP_SQRT) ? (SHARED_FP_DIV) ? APUTYPE_FP+6 : APUTYPE_FP+5 : (SHARED_DIVSQRT) ? APUTYPE_FP+5 : APUTYPE_FP+4;

   parameter NAPUTYPES    = C_APUTYPES;
   parameter WAPUTYPE     = $clog2(C_APUTYPES);


   parameter C_OP_ADD  = 0;
   parameter C_OP_SUB  = 1;
   parameter C_OP_MULT = 2;
   parameter C_OP_MAC  = 3;
   parameter C_OP_DIV  = 4;
   parameter C_OP_SQRT = 5;
   parameter C_OP_ITF  = 6;
   parameter C_OP_FTI  = 7;

   parameter C_N_OPS    = 8;

endpackage // apu_package
`endif