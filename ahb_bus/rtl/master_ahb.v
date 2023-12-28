// Assumptions made - v1 : The max hsize or the transfer size of the data is = 32,
//                         The design only works for the incrementing burst but not for the wrapping burst,
//                         The slave isn't introducing any wait states,
//                         The slave's response to be always an Okay. 
//                         Read and a write doesn't happen consecutively but only after again initiating the transaction.                     
//                         Burst and single transfers can't happen continously in the current design 
module ahb_master #(
    parameter                   ADDR_WIDTH = 32,
    parameter                   DATA_WIDTH = 32,
    parameter                   TRANS_SIZE = 32  // can be 8/16 or 32
)(
    //Global signals,
    input                       hclk,
    input                       hresetn,

    //Manager signals 
    output [ADDR_WIDTH-1:0]     haddr,
    output [DATA_WIDTH-1:0]     hwdata,
    output                      hwrite,
    output [2:0]                hburst, 
    output [1:0]                htrans,
    output [2:0]                hsize,     
//    output                      hmastlock, //should be 0
//    output [6:0]  hprot,
    
    //Subordinate signals 
    input [DATA_WIDTH-1:0]      hrdata,
    input                       hready,
    input [1:0]                      hresp,

    //External and valid signal
    input                       stop_trans,
    input                       start_trans,
    input [ADDR_WIDTH-1:0]      ext_haddr,   //can be any address like 0x32
    input [DATA_WIDTH-1:0]      ext_hwdata,  //can be any value
    input                       ext_hwrite,    
    input [2:0]                 ext_hburst,   //3'd0 for a signle transfer 
    input [2:0]                 ext_hsize,
//    input                       ext_hmastlock, // 0 
    output [31:0]               ext_hrdata
//    input [6:0]   ext_prot        

  
);
    reg [DATA_WIDTH-1:0]        mem [DATA_WIDTH-1:0];
    reg [ADDR_WIDTH-1:0]        r_haddr = 0;
    reg [DATA_WIDTH-1:0]        r_hwdata = 0;
    reg                         r_hwrite = 0;
    reg [2:0]                   r_hburst = 0;
    reg [4:0]                   r_counter = 0;
    reg [1:0]                   r_htrans = 0;
    reg [2:0]                   r_hsize = 0;
//    reg                         r_hmastlock;
//    reg [DATA_WIDTH-1:0]        r_ext_hrdata = 0;
    reg [3:0]                   p_state = 0;
    reg [4:0]                   r_burst = 0;
    reg [8:0]                   r_hsize_no = 0;          
    parameter                   IDLE = 4'd0;


 /*   localparam BURST_SIZE = 1 ? (ext_hburst == 3'd0) :
                            4 ? (ext_hburst == 3'd3) : 
                            8 ? (ext_hburst == 3'd5) : 
                            16 ; */ // You can't use signals to get a localparam like here you used ext_hburst

    assign haddr = r_haddr;
    assign htrans = r_htrans;
    assign hwdata = r_hwdata;
    assign hwrite = r_hwrite;
    assign hburst = r_hburst;
 //  assign ext_hrdata = r_ext_hrdata;
    assign hsize = r_hsize;

    always @(posedge hclk or negedge hresetn) begin
        if (!hresetn) begin
            r_htrans <= 2'd0;
            r_haddr <= 32'd0;
            r_hwrite <= 0;
            r_hsize <= 0;
        end else begin
            case (p_state)
                4 : begin
                    if (start_trans) begin
                        p_state <= IDLE;
                    end
                end
                IDLE : begin
                    if (start_trans) begin
                        p_state <= 1;
                        r_haddr <= ext_haddr;
                        r_hwrite <= ext_hwrite;
                        r_hburst <= ext_hburst;
                        r_hsize <= ext_hsize;
                        r_htrans <= 2'd2;
                    end 
                    if (ext_hburst == 3'd3 || ext_hburst == 3'd5 || ext_hburst == 3'd7) begin
                        p_state <= 2;
                    end
                end
                1 : begin
                    if (hresp == 0 && hready == 1) begin
                        if (stop_trans == 0) begin
                            if (ext_hburst == 3'd0 || ext_hburst == 3'd3 || ext_hburst == 3'd5 || ext_hburst == 3'd7) begin         
                                r_haddr <= ext_haddr;
                                r_hwrite <= ext_hwrite;
                                r_hburst <= ext_hburst;
                                r_hsize <= ext_hsize;
                                r_htrans <= 2'd2;
                                p_state <= 2;
                            end
                        end else 
                            p_state <= 4;

                        if (ext_hwrite == 1) begin
                            r_hwdata <= ext_hwdata;
                        // end else begin
                        //    r_ext_hrdata <= hrdata;
                        // end
                    end
                end
                end
            

                2 : begin
                    if (hresp == 0 && hready == 1) begin
                        if (r_hburst == 3'd3 || r_hburst == 3'd5 || r_hburst == 3'd7 ) begin
                            if (r_counter == r_burst - 1) begin
                                r_counter <= 0;
                                p_state <= 3;
                                r_htrans <= 2'd0;
                            end else begin
                                r_haddr <= r_haddr + (r_hsize_no >> 3);
                                r_htrans <= 2'd3;
                                r_counter <= r_counter + 1;
                                p_state <=  2;
                            end
                        end else if (stop_trans) begin
                            p_state <= 4;
                            r_htrans <= 0;
                        end else if (r_hburst == 3'd0) 
                        begin
                            r_haddr <= ext_haddr;
                            r_counter <= 0;
                            r_htrans <= 2'd2;
                            p_state <= 1;
                        end 

                        if (ext_hwrite == 1) begin
                            r_hwdata <= ext_hwdata;
                        // end else begin
                        //    r_ext_hrdata <= hrdata;
                        end
                    end
                end

                3 : begin
                    if (stop_trans) begin
                        p_state <= 4;
                        r_htrans <= 2'd0;
                    end
                end
            endcase
        end
    end
    
    assign ext_hrdata = hrdata;
    
    always @(*) begin
        case(ext_hburst)
            2,3 : r_burst = 4;
            4,5 : r_burst = 8;
            6,7 : r_burst = 16;
            default : r_burst = 1;
        endcase
    end

    always @(*) begin
        case(ext_hsize) 
            2'b00 : r_hsize_no = 8;
            2'b01 : r_hsize_no = 16;
            2'b10 : r_hsize_no = 32;
            default : r_hsize_no = 32;

        endcase
    end

endmodule    

//     always @(posedge hclk) begin
//         if (r_counter == 0) begin
//             r_htrans <= 2'd2;
//         end else if (r_counter < r_burst-1) begin
//             r_htrans <= 2'd3;
//         end else begin
//             r_htrans <= 2'd0;
//         end
//     end



// Not pipelined and not configured htrans yet
 


// if (hresp == 0 && hready == 1) begin
//                         if (ext_hburst == 3'd0  && TRANS_SIZE == 32 | ext_hburst == 3'd0 && TRANS_SIZE == 16 | ext_hburst == 3'd0 && TRANS_SIZE == 8) begin         
//                             if (ext_hwrite == 1) begin
//                                 r_haddr <= ext_haddr;
//                                 r_hwdata <= ext_hwdata;
//                             end else begin
//                                 r_ext_hrdata <= hrdata;
//                             end
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 32 | ext_hburst == 3'd5 && TRANS_SIZE == 32 | ext_hburst == 3'd7 && TRANS_SIZE == 32) begin
//                             if (ext_hwrite == 1) begin
//                                 r_haddr <= r_haddr + 4;
//                                 r_hwdata <= ext_hwdata;
//                             end else begin
//                                 r_ext_hrdata <= hrdata;
//                             end         
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 16 | ext_hburst == 3'd5 && TRANS_SIZE == 16 | ext_hburst == 3'd7 && TRANS_SIZE == 16) begin
//                             if (ext_hwrite == 1) begin
//                                 r_haddr <= r_haddr + 2;
//                                 r_hwdata <= ext_hwdata;
//                             end else begin
//                                 r_ext_hrdata <= hrdata;
//                             end    
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 8 | ext_hburst == 3'd5 && TRANS_SIZE == 8 | ext_hburst == 3'd7 && TRANS_SIZE == 8) begin
//                             if (ext_hwrite == 1) begin
//                                 r_haddr <= r_haddr + 1;
//                                 r_hwdata <= ext_hwdata;
//                             end else begin
//                                 r_ext_hrdata <= hrdata;
//                             end 
//                         end 
//                         end 


// module ahb_master #(
//     parameter                   ADDR_WIDTH = 32,
//     parameter                   DATA_WIDTH = 32,
//     parameter                   TRANS_SIZE = 32  // can be 8/16 or 32
// )(
//     //Global signals,
//     input                       hclk,
//     input                       hresetn,

//     //Manager signals 
//     output [ADDR_WIDTH-1:0]     haddr,
//     output [DATA_WIDTH-1:0]     hwdata,
//     output                      hwrite,
//     output [2:0]                hburst, 
// //    output                      hmastlock, //should be 0
// //    output [6:0]  hprot,
    
//     //Subordinate signals 
//     input [DATA_WIDTH-1:0]      hrdata,
//     input                       hready,
//     input                       hresp,

//     //External and valid signal
//     input                       stop_trans,
//     input                       start_trans,
//     input [ADDR_WIDTH-1:0]      ext_haddr,   //can be any address like 0x32
//     input [DATA_WIDTH-1:0]      ext_hwdata,  //can be any value
//     input                       ext_hwrite,    
//     input [2:0]                 ext_hburst   //3'd0 for a signle transfer 
// //    input                       ext_hmastlock, // 0 
// //    output [31:0]               ext_hrdata
// //    input [6:0]   ext_prot        

  
// );
//     reg [DATA_WIDTH-1:0]        mem [DATA_WIDTH-1:0];
//     reg [ADDR_WIDTH-1:0]        r_haddr = 0;
//     reg [DATA_WIDTH-1:0]        r_hwdata = 0;
//     reg                         r_hwrite = 0;
//     reg [2:0]                   r_hburst = 0;
//     reg [4:0]                   r_counter = 0;
//     reg [2:0]                   r_htrans = 0;
// //    reg                         r_hmastlock;
//     reg [DATA_WIDTH-1:0]        r_ext_hrdata = 0;
//     reg [3:0]                   p_state = 0;
//     reg                         r_counter_flag = 0;
//     reg [4:0]                   r_burst = 0;           
//     parameter                   IDLE = 4'd0;


//  /*   localparam BURST_SIZE = 1 ? (ext_hburst == 3'd0) :
//                             4 ? (ext_hburst == 3'd3) : 
//                             8 ? (ext_hburst == 3'd5) : 
//                             16 ; */ // You can't use signals to get a localparam like here you used ext_hburst

//     assign haddr = r_haddr;
//     assign htrans = r_htrans;
//     assign hwdata = r_hwdata;
//     assign hwrite = r_hwrite;
//     assign hburst = r_hburst;
//     assign ext_hrdata = r_ext_hrdata;

//     always @(posedge hclk or negedge hresetn) begin
//         if (!hresetn) begin
//             r_htrans <= 2'd0;
//             r_haddr <= 32'd0;
//             r_hwrite <= 0;
//         end else begin
//             case (p_state)
//                 IDLE : begin
//                     if (start_trans) begin
//                         p_state <= 1;
//                         r_haddr <= ext_haddr;
//                         r_hwrite <= ext_hwrite;
//                         r_hburst <= ext_hburst;
//                         r_counter_flag <= 1;
//                     end 
               
//                 2 : begin
//                     if (hresp == 0 && hready == 1) begin
//                         if (ext_hburst == 3'd0  && TRANS_SIZE == 32 | ext_hburst == 3'd0 && TRANS_SIZE == 16 | ext_hburst == 3'd0 && TRANS_SIZE == 8) begin         
//                             r_haddr <= ext_haddr;
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 32 || ext_hburst == 3'd5 && TRANS_SIZE == 32 || ext_hburst == 3'd7 && TRANS_SIZE == 32) begin
//                             r_haddr <= r_haddr + 4;        
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 16 || ext_hburst == 3'd5 && TRANS_SIZE == 16 || ext_hburst == 3'd7 && TRANS_SIZE == 16) begin
//                             r_haddr <= r_haddr + 2;    
//                         end else if (ext_hburst == 3'd3 && TRANS_SIZE == 8 || ext_hburst == 3'd5 && TRANS_SIZE == 8 || ext_hburst == 3'd7 && TRANS_SIZE == 8) begin                       
//                             r_haddr <= r_haddr + 1; 
//                         end 
//                     end
//                     if (ext_hwrite == 1) begin
//                         r_hwdata <= ext_hwdata;
//                     end else begin
//                         r_ext_hrdata <= hrdata;
//                     end
//                     p_state <= 3;
//                 end
//                 3 : begin
//                     if(ext_hburst == 3'd3 | ext_hburst == 3'd5 | ext_hburst == 3'd7) begin
//                         if (r_counter > r_burst-1) begin
//                             r_counter <= 0;
//                             p_state <= IDLE; 
//                         end else begin
//                             r_counter <= r_counter + 1;
//                             p_state <= 2;
//                         end
//                     end else if (ext_hburst == 3'd0) begin
//                         p_state <= 2;
//                     end else if (stop_trans) begin
//                         p_state <= IDLE; 
//                     end
//                 end
//             endcase
//         end
//     end
    

    
//     always @(*) begin
//         case(ext_hburst)
//             0 : r_burst = 1;
//             2,3 : r_burst = 4;
//             4,5 : r_burst = 8;
//             6,7 : r_burst = 16;
//             default : r_burst = 1;
//         endcase
//     end
    

//     always @(posedge hclk) begin
//         if (r_counter == 0) begin
//             r_htrans <= 2'd2;
//         end else if (r_counter < r_burst) begin
//             r_htrans <= 2'd3;
//         end else begin
//             r_htrans <= 2'd0;
//         end
//     end
// endmodule
