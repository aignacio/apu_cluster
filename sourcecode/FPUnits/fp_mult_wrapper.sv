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
// Design Name:    fp_mult_wrapper                                            //
// Project Name:   Shared APU                                                 //
// Language:       SystemVerilog                                              //
//                                                                            //
// Description:    Wraps the DW fp-mult unit                                  //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

import apu_cluster_package::*;

module fp_mult_wrapper
#(
  parameter C_MULT_PIPE_REGS = 0,
  parameter TAG_WIDTH = 0,
  parameter RND_WIDTH = NDSFLAGS_MULT,
  parameter STAT_WIDTH = NUSFLAGS_MULT
)
 (
  // Clock and Reset
  input  logic                  clk_i,
  input  logic                  rst_ni,

  input  logic                  En_i,
  
  input logic [FP_WIDTH-1:0]    OpA_i,
  input logic [FP_WIDTH-1:0]    OpB_i,
  input logic [TAG_WIDTH-1:0]   Tag_i,

  input logic [RND_WIDTH-1:0]   Rnd_i,
  output logic [STAT_WIDTH-1:0] Status_o,

  output logic [FP_WIDTH-1:0]   Res_o,
  output logic [TAG_WIDTH-1:0]  Tag_o,
  output logic                  Valid_o,
  output logic                  Ready_o,
  input  logic                  Ack_i
 
);

   // DISTRIBUTE PIPE REGS
   parameter C_PRE_PIPE_REGS   = C_MULT_PIPE_REGS;
   parameter C_POST_PIPE_REGS  = 0;

   // PRE PIPE REG SIGNALS
   logic [FP_WIDTH-1:0]  OpA_DP     [C_PRE_PIPE_REGS+1];
   logic [FP_WIDTH-1:0]  OpB_DP     [C_PRE_PIPE_REGS+1];
   logic                 En_SP      [C_PRE_PIPE_REGS+1];
   logic [TAG_WIDTH-1:0] Tag_DP     [C_PRE_PIPE_REGS+1];
   logic [RND_WIDTH-1:0] Rnd_DP     [C_PRE_PIPE_REGS+1];
   
   // POST PIPE REG SIGNALS
   logic                  EnPost_SP      [C_POST_PIPE_REGS+1];
   logic [TAG_WIDTH-1:0]  TagPost_DP     [C_POST_PIPE_REGS+1];
   logic [FP_WIDTH-1:0]   Res_DP         [C_POST_PIPE_REGS+1];
   logic [STAT_WIDTH-1:0] Status_DP      [C_POST_PIPE_REGS+1];
   
   // assign input. note: index [0] is not a register here!
   assign OpA_DP[0]    = En_i ? OpA_i :'0;
   assign OpB_DP[0]    = En_i ? OpB_i :'0;
   assign En_SP[0]     = En_i;
   assign Tag_DP[0]    = Tag_i;
   assign Rnd_DP[0]    = Rnd_i;
   
   // propagate states
   assign EnPost_SP[0]      = En_SP[C_PRE_PIPE_REGS]; 
   assign TagPost_DP[0]     = Tag_DP[C_PRE_PIPE_REGS];  

   // assign output
   assign Res_o             = Res_DP[C_POST_PIPE_REGS];
   assign Valid_o           = EnPost_SP[C_POST_PIPE_REGS];
   assign Tag_o             = TagPost_DP[C_POST_PIPE_REGS];
   assign Status_o          = Status_DP[C_POST_PIPE_REGS];
   assign Ready_o           = 1'b1;
   
   DW_fp_mult
     #(
       .sig_width(SIG_WIDTH),
       .exp_width(EXP_WIDTH),
       .ieee_compliance(IEEE_COMP)
       )
   fp_mult_i
     (
      .a(OpA_DP[C_PRE_PIPE_REGS]),
      .b(OpB_DP[C_PRE_PIPE_REGS]),
      .rnd(Rnd_DP[C_PRE_PIPE_REGS]),
      .z(Res_DP[0]),
      .status(Status_DP[0])
      );

   // PRE_PIPE_REGS
   generate
    genvar i;
      for (i=1; i <= C_PRE_PIPE_REGS; i++)  begin: g_pre_regs

         always_ff @(posedge clk_i or negedge rst_ni) begin : p_pre_regs
            if(~rst_ni) begin
               En_SP[i]         <= '0;
               OpA_DP[i]        <= '0;
               OpB_DP[i]        <= '0;
               Tag_DP[i]        <= '0;
               Rnd_DP[i]        <= '0;
            end 
            else begin
               // this one has to be always enabled...
               En_SP[i]       <= En_SP[i-1];
               
               // enabled regs
               if(En_SP[i-1]) begin
                  OpA_DP[i]       <= OpA_DP[i-1];
                  OpB_DP[i]       <= OpB_DP[i-1];
                  Tag_DP[i]       <= Tag_DP[i-1];
                  Rnd_DP[i]       <= Rnd_DP[i-1];
               end
            end
         end
      end
   endgenerate

   
   // POST_PIPE_REGS
   generate
    genvar j;
      for (j=1; j <= C_POST_PIPE_REGS; j++)  begin: g_post_regs

         always_ff @(posedge clk_i or negedge rst_ni) begin : p_post_regs
            if(~rst_ni) begin
               EnPost_SP[j]     <= '0;
               Res_DP[j]        <= '0;
               TagPost_DP[j]    <= '0;
               Status_DP[j]     <= '0;
            end 
            else begin
               // this one has to be always enabled...
               EnPost_SP[j]       <= EnPost_SP[j-1];
               
               // enabled regs
               if(EnPost_SP[j-1]) begin
                  Res_DP[j]       <= Res_DP[j-1];
                  TagPost_DP[j]   <= TagPost_DP[j-1];
                  Status_DP[j]    <= Status_DP[j-1];
               end
            end
         end
      end
   endgenerate
   
endmodule
