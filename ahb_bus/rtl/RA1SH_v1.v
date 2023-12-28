`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
module RA1SH_v1 ( 
   output [BITS-1:0]         Q,          
   input                     CLK,        
   input                     CEN,        //chip select 
   input                     WEN,        
   input [ADDR_WIDTH-1:0]    A,          
   input [BITS-1:0]          D,          //data_in [7:0]
   input                     OEN         
);

    parameter BITS = 8;
    parameter WORD_DEPTH = 8192;
    parameter ADDR_WIDTH = 13;
    
    reg [BITS-1:0]        mem [WORD_DEPTH-1:0];
    reg [BITS-1:0]        q_reg;
 //   reg [ADDR_WIDTH-1:0]  a_reg;
    
    
    
//   wire [BITS-1:0]         _Q;
//   wire			           _OENi;
//   wire [ADDR_WIDTH-1:0]   _A;
//   wire			           _CLK;
//   wire			           _CEN;
//   wire			           _OEN;
//   wire                    _WEN;
//   wire [BITS-1:0]         _D;
    
    
   assign Q = q_reg;

        always @(posedge CLK) begin
            if (!CEN) begin
                if (!WEN) begin
                    mem [A] <= D;
                    q_reg <= D;
                end else begin
                    q_reg <= mem [A];
                end 
            end else begin
                q_reg <= q_reg;
            end 
        end
        
        
//bufif0 (Q[0], _Q[0], _OENi);
//bufif0 (Q[1], _Q[1], _OENi);
//bufif0 (Q[2], _Q[2], _OENi);
//bufif0 (Q[3], _Q[3], _OENi);
//bufif0 (Q[4], _Q[4], _OENi);
//bufif0 (Q[5], _Q[5], _OENi);
//bufif0 (Q[6], _Q[6], _OENi);
//bufif0 (Q[7], _Q[7], _OENi);
//buf (_D[0], D[0]);
//buf (_D[1], D[1]);
//buf (_D[2], D[2]);
//buf (_D[3], D[3]);
//buf (_D[4], D[4]);
//buf (_D[5], D[5]);
//buf (_D[6], D[6]);
//buf (_D[7], D[7]);
//buf (_A[0], A[0]);
//buf (_A[1], A[1]);
//buf (_A[2], A[2]);
//buf (_A[3], A[3]);
//buf (_A[4], A[4]);
//buf (_A[5], A[5]);
//buf (_A[6], A[6]);
//buf (_A[7], A[7]);
//buf (_A[8], A[8]);
//buf (_A[9], A[9]);
//buf (_A[10], A[10]);
//buf (_A[11], A[11]);
//buf (_A[12], A[12]);
//buf (_CLK, CLK);
//buf (_WEN, WEN);
//buf (_OEN, OEN);
//buf (_CEN, CEN);


//assign _OENi = _OEN;
//assign _Q = q_reg;

endmodule 