`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module ahb_slave_if(
    // Global signals
    input  hclk,
    input  hresetn,
    // AHB Master signals 
    input  hsel,                   
    input  hready,                 
    input  hwrite,                 
    input  [1:0]   htrans,         
    input  [2:0]   hsize,          
    input  [2:0]   hburst,         
    input  [31:0]  haddr,          
    input  [31:0]  hwdata,         
    // sram_core data output signals for read data from sram
    input  [7:0]  sram_q0,              
    input  [7:0]  sram_q1,              
    input  [7:0]  sram_q2,              
    input  [7:0]  sram_q3,
    input  [7:0]  sram_q4,
    input  [7:0]  sram_q5,
    input  [7:0]  sram_q6,
    input  [7:0]  sram_q7,
    


    // signals to AHB bus 
    output  [1:0]  hresp,             
    output         hready_resp,       
    output  [31:0] hrdata,            

    // sram read or write enable signals
    // when "sram_w_en" is low, it means write sram, when "sram_w_en" is high, it means read sram,
    output  sram_w_en,  

    // choose the write srams when bank is confirmed
    // bank_csn allows the four bytes in the 32-bit width to be written independently
    output  reg        bank_sel,
    output  reg [3:0]  bank0_csn,
    output  reg [3:0]  bank1_csn,

    // signals to sram_core in normal operation, it contains sram address and data writing into sram 
    output  [12:0]  sram_addr_out,          
    output  [31:0]  sram_wdata              
); 

    // internal registers used for temp the input ahb signals 
    // temperate all the AHB input signals
    reg         hwrite_r;         
    reg  [2:0]  hsize_r;          
    reg  [2:0]  hburst_r;         
    reg  [1:0]  htrans_r;         
    reg  [31:0] haddr_r;          

    reg  [3:0]  sram_csn;         
    // Internal signals    
    // "haddr'_sel" and hsize_sel" used to generate banks of sram: "bank0_sel" and "bank1_sel"
    wire  [1:0]  haddr_sel;
    wire  [1:0]  hsize_sel;

    wire         sram_csn_en;     

    wire         sram_write;     
    wire         sram_read;      
    wire  [15:0] sram_addr;      
    reg   [31:0] sram_data_out;  

    // transfer type signal encoding
    parameter  IDLE   = 2'b00; // htrans
    parameter  BUSY   = 2'b01;
    parameter  NONSEQ = 2'b10; 
    parameter  SEQ    = 2'b11;  
   
    parameter SUB_DATA = 1'b0;
//--------------------------------------------------------------------------------------------------------
//----------------------------------------------Main code------------------------------------------
//--------------------------------------------------------------------------------------------------------


    // Combitional portion ,     
    // assign the response and read data of the AHB slave
    // To implement sram function-writing or reading in one cycle, value of hready_resp is always "1"
    assign  hready_resp = 1'b1;    
    assign  hresp       = 2'b00;   

    // sram data output to AHB bus
    assign  hrdata = sram_data_out;  

    // Generate sram write and read enable signals
    assign  sram_write = ((htrans_r == NONSEQ) || (htrans_r == SEQ)) && hwrite_r;
    assign  sram_read = ((htrans_r == NONSEQ) || (htrans_r == SEQ)) && (! hwrite_r);
    assign  sram_w_en = !sram_write;     


    // Generate sram address 
    assign  sram_addr = haddr_r[15:0];      
    assign  sram_addr_out = sram_addr[12:0];
    // Generate bank select signals by the value of sram_addr[15].
    // Each bank(32K*32, comprises of four sram block(8K*8), and the width of the address of the bank is
    // 15 bits(14-0),so the sram_addr[15] is the minimum of the next bank. if it is value is '1', it means 
    // the next bank is selected.
    assign sram_csn_en = (sram_write || sram_read); 

    // signals used to generating sram chip select signal in one bank.


    assign  haddr_sel = sram_addr[14:13];    
    assign  hsize_sel  = hsize_r[1:0];

    // data from AHB writing into sram.
    assign  sram_wdata =hwdata;   




    always@(*)begin
        if(sram_csn_en)begin
            case(hsize_sel)
                2'b00:begin//8bit
                    bank0_csn = (sram_addr[15] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[15] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[15] == 1'b0)?1'b1:1'b0;
                end
                2'b01:begin                          
                    bank0_csn = (sram_addr[14] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[14] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[14] == 1'b0)?1'b1:1'b0;               
                end
                2'b10:begin                            
                    bank0_csn = (sram_addr[13] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[13] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[13] == 1'b0)?1'b1:1'b0;                
                end
                default:begin//Ĭ��32λ            
                    bank0_csn = (sram_addr[13] == 1'b0)?sram_csn:4'b1111;
                    bank1_csn = (sram_addr[13] == 1'b1)?sram_csn:4'b1111;
                    bank_sel =  (sram_addr[13] == 1'b0)?1'b1:1'b0;                 
                end
            endcase
        end
        else begin
            bank0_csn = 4'b1111;
            bank1_csn = 4'b1111;
            bank_sel  = 1'b1;
        end
    end
    
        
    // Choose the right data output of two banks(bank0,bank1) according to the value of bank_sel.
    
    // If bank_sel = 1'b1, bank1 selected;or, bank0 selected.    
   
    always@(posedge hclk)begin
        if(!hresetn)begin
            sram_data_out <= {32{SUB_DATA}};
        end
        else if(sram_read)begin
            if(bank_sel)begin
                case(hsize_sel)
                    2'b00:begin//data size 8bit
                        case(haddr_sel)
                            2'b00:sram_data_out <= {{24{SUB_DATA}},sram_q0};
                            2'b01:sram_data_out <= {{24{SUB_DATA}},sram_q1};
                            2'b10:sram_data_out <= {{24{SUB_DATA}},sram_q2};
                            2'b11:sram_data_out <= {{24{SUB_DATA}},sram_q3};
                        endcase
                    end
                    2'b01:begin//data size 16bit
                         case(haddr_sel[0])
                            1'b0:sram_data_out <= {{16{SUB_DATA}},sram_q1,sram_q0};
                            1'b1:sram_data_out <= {{16{SUB_DATA}},sram_q3,sram_q2};
                        endcase                   
                     
                    end
                    2'b10:sram_data_out <= {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit
                    default:begin 
                          sram_data_out <= {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit                  
                    end
                endcase
            end
            else begin
                 case(hsize_sel)
                    2'b00:begin//data size 8bit
                        case(haddr_sel)
                            2'b00:sram_data_out <= {{24{SUB_DATA}},sram_q4};
                            2'b01:sram_data_out <= {{24{SUB_DATA}},sram_q5};
                            2'b10:sram_data_out <= {{24{SUB_DATA}},sram_q6};
                            2'b11:sram_data_out <= {{24{SUB_DATA}},sram_q7};
                        endcase
                    end
                    2'b01:begin//data size 16bit
                         case(haddr_sel[0])
                            1'b0:sram_data_out <= {{16{SUB_DATA}},sram_q5,sram_q4};
                            1'b1:sram_data_out <= {{16{SUB_DATA}},sram_q7,sram_q6};
                        endcase                   
                     
                    end
                    2'b10:sram_data_out <= {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit
                    default:begin 
                          sram_data_out <= {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit                   
                   end
                endcase           
            end
        end
        else begin
            sram_data_out <= sram_data_out;
        end
    end



    // always@(*)begin
    //     if(!hresetn)begin
    //         sram_data_out = {32{SUB_DATA}};
    //     end
    //     else if(sram_read)begin
    //         if(bank_sel)begin
    //             case(hsize_sel)
    //                 2'b00:begin//data size 8bit
    //                     case(haddr_sel)
    //                         2'b00:sram_data_out = {{24{SUB_DATA}},sram_q0};
    //                         2'b01:sram_data_out = {{24{SUB_DATA}},sram_q1};
    //                         2'b10:sram_data_out = {{24{SUB_DATA}},sram_q2};
    //                         2'b11:sram_data_out = {{24{SUB_DATA}},sram_q3};
    //                     endcase
    //                 end
    //                 2'b01:begin//data size 16bit
    //                      case(haddr_sel[0])
    //                         1'b0:sram_data_out = {{16{SUB_DATA}},sram_q1,sram_q0};
    //                         1'b1:sram_data_out = {{16{SUB_DATA}},sram_q3,sram_q2};
    //                     endcase                   
                     
    //                 end
    //                 2'b10:sram_data_out = {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit
    //                 default:begin 
    //                       sram_data_out = {sram_q3,sram_q2,sram_q1,sram_q0};//data size 32bit                  
    //                 end
    //             endcase
    //         end
    //         else begin
    //              case(hsize_sel)
    //                 2'b00:begin//data size 8bit
    //                     case(haddr_sel)
    //                         2'b00:sram_data_out = {{24{SUB_DATA}},sram_q4};
    //                         2'b01:sram_data_out = {{24{SUB_DATA}},sram_q5};
    //                         2'b10:sram_data_out = {{24{SUB_DATA}},sram_q6};
    //                         2'b11:sram_data_out = {{24{SUB_DATA}},sram_q7};
    //                     endcase
    //                 end
    //                 2'b01:begin//data size 16bit
    //                      case(haddr_sel[0])
    //                         1'b0:sram_data_out = {{16{SUB_DATA}},sram_q5,sram_q4};
    //                         1'b1:sram_data_out = {{16{SUB_DATA}},sram_q7,sram_q6};
    //                     endcase                   
                     
    //                 end
    //                 2'b10:sram_data_out = {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit
    //                 default:begin 
    //                       sram_data_out = {sram_q7,sram_q6,sram_q5,sram_q4};//data size 32bit                   
    //                end
    //             endcase           
    //         end
    //     end
    //     else begin
    //         sram_data_out = sram_data_out;
    //     end
    // end

// Generate the sram chip selecting signals in one bank.
// results show the AHB bus write or read how many data once a time:byte(8),halfword(16) or word(32).
    always@(*) begin
        if(hsize_sel == 2'b10)            
          sram_csn = 4'b0;                //active low, sram_csn --> 4'b0000, then it is active
        else if(hsize_sel == 2'b01)       //16bits:halfword
          begin      
            if(haddr_sel[0] == 1'b0)        
              sram_csn = 4'b1100;         
            else                          //high halfword
              sram_csn = 4'b0011;         
          end
        else if(hsize_sel == 2'b00)       
          begin
            case(haddr_sel)
              2'b00:sram_csn = 4'b1110;    
              2'b01:sram_csn = 4'b1101;    
              2'b10:sram_csn = 4'b1011;    
              2'b11:sram_csn = 4'b0111;    
            endcase
          end
        else
          sram_csn = 4'b0;      
    end

// Sequential portion,     
// tmp the ahb address and control signals
    always@(posedge hclk or negedge hresetn) begin
        if(!hresetn)
          begin
            hwrite_r <= 1'b0;
            hsize_r  <= 3'b0;
            hburst_r <= 3'b0;         
            htrans_r <= 2'b0;
            haddr_r  <= 32'b0;
          end
        else if(hsel && hready)
          begin
            hwrite_r <= hwrite;
            hsize_r  <= hsize;       
            hburst_r <= hburst;      
            htrans_r <= htrans;
            haddr_r  <= haddr;
          end
        else
          begin
            hwrite_r <= 1'b0;
            hsize_r  <= 3'b0;
            hburst_r <= 3'b0;         
            htrans_r <= 2'b0;
            haddr_r  <= 32'b0;
          end
    end

endmodule
