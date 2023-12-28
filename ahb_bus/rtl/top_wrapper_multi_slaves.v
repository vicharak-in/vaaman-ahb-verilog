//`include "ahb_master.v"
//`include "../rtl/slave/sramc_top.v"
//`include "interconnect_decoder.v"
//`include "interconnect_mux.v"

module top_ahb_multi_slaves #(
    parameter                   ADDR_WIDTH = 32,
    parameter                   DATA_WIDTH = 32,
    parameter                   TRANS_SIZE = 32  
)(
    input                       hclk,
//    input                       sram_clk,
    input                       hresetn,
    input                       stop_trans,
    input                       start_trans,
    input [ADDR_WIDTH-1:0]      ext_haddr,
    input [DATA_WIDTH-1:0]      ext_hwdata,
    input                       ext_hwrite,    
    input [2:0]                 ext_hburst,
    input [2:0]                 ext_hsize,
    input                       dft_en,
    input                       bist_en,
    output [DATA_WIDTH-1:0]     o_hrdata
);

    wire [ADDR_WIDTH-1:0]       w_haddr;
    wire [DATA_WIDTH-1:0]       w_hwdata;
    wire                        w_hwrite;
    wire [2:0]                  w_hburst;
    wire [1:0]                  w_htrans;
    wire [2:0]                  w_hsize;
    wire [DATA_WIDTH-1:0]       w_hrdata;
    wire                        w_hready;
    wire [1:0]                  w_hresp;
    wire [3:0]                  w_hsel;
    wire                        w_hready_slv1;
    wire                        w_hready_slv2;
    wire                        w_hready_slv3;
    wire [1:0]                  w_hresp_slv1;
    wire [1:0]                  w_hresp_slv2;
    wire [1:0]                  w_hresp_slv3;
    wire [DATA_WIDTH-1:0]       w_hrdata_slv1;
    wire [DATA_WIDTH-1:0]       w_hrdata_slv2;
    wire [DATA_WIDTH-1:0]       w_hrdata_slv3;




ahb_master  #(.ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .TRANS_SIZE(TRANS_SIZE))
     master   (
    .hclk        (hclk),
    .hresetn     (hresetn),
    .haddr       (w_haddr),
    .hwdata      (w_hwdata),
    .hwrite      (w_hwrite),
    .hburst      (w_hburst),
    .htrans      (w_htrans),
    .hsize       (w_hsize),
    .hrdata      (w_hrdata),
    .hready      (w_hready),
    .hresp       (w_hresp),
    .stop_trans  (stop_trans),
    .start_trans (start_trans),
    .ext_haddr   (ext_haddr),
    .ext_hwdata  (ext_hwdata),
    .ext_hwrite  (ext_hwrite),
    .ext_hburst  (ext_hburst),
    .ext_hsize   (ext_hsize),
    .ext_hrdata  (o_hrdata)
);


interconnect_decoder #(.ADDR_WIDTH(32))
decoder (

    .haddr       (w_haddr),
    .hsel        (w_hsel)
);



interconnect_mux mux (
    .i_hready_slv1   (w_hready_slv1),
    .i_hrdata_slv1   (w_hrdata_slv1),
    .i_hresp_slv1    (w_hresp_slv1),
    .i_hready_slv2   (w_hready_slv2),
    .i_hrdata_slv2   (w_hrdata_slv2),
    .i_hresp_slv2    (w_hresp_slv2),
    .i_hready_slv3   (w_hready_slv3),
    .i_hrdata_slv3   (w_hrdata_slv3),
    .i_hresp_slv3    (w_hresp_slv3),
    .i_hsel_decoder  (w_hsel),
    .o_hready        (w_hready),
    .o_hrdata        (w_hrdata),
    .o_hresp         (w_hresp)
);






sramc_top slave1 (
    .hclk            (hclk     ),
    .sram_clk        (hclk ),
    .hresetn         (hresetn  ),
    .hsel            (w_hsel[0]),
    .hwrite          (w_hwrite ),
    .hready          (w_hready   ),
    .hsize           (w_hsize  ),
    .hburst          (w_hburst ),
    .htrans          (w_htrans ),
    .hwdata          (w_hwdata ),
    .haddr           (w_haddr  ),
    .dft_en          (dft_en   ),
    .bist_en         (bist_en  ),
    .hready_resp     (w_hready_slv1),
    .hresp           (w_hresp_slv1  ),
    .hrdata          (w_hrdata_slv1 ),
    .bist_done       (),
    .bist_fail       ()
 );

 sramc_top slave2 (
    .hclk            (hclk     ),
    .sram_clk        (hclk ),
    .hresetn         (hresetn  ),
    .hsel            (w_hsel[1]),
    .hwrite          (w_hwrite ),
    .hready          (w_hready   ),
    .hsize           (w_hsize  ),
    .hburst          (w_hburst ),
    .htrans          (w_htrans ),
    .hwdata          (w_hwdata ),
    .haddr           (w_haddr  ),
    .dft_en          (dft_en   ),
    .bist_en         (bist_en   ),
    .hready_resp     ( w_hready_slv2 ),
    .hresp           ( w_hresp_slv2  ),
    .hrdata          ( w_hrdata_slv2 ),
    .bist_done       (),
    .bist_fail       ()
 );

 sramc_top slave3 (
    .hclk            (hclk     ),
    .sram_clk        (hclk ),
    .hresetn         (hresetn  ),
    .hsel            (w_hsel[2]),
    .hwrite          (w_hwrite ),
    .hready          (w_hready   ),
    .hsize           (w_hsize  ),
    .hburst          (w_hburst ),
    .htrans          (w_htrans ),
    .hwdata          (w_hwdata ),
    .haddr           (w_haddr  ),
    .dft_en          (dft_en   ),
    .bist_en         (bist_en   ),
    .hready_resp     ( w_hready_slv3 ),
    .hresp           ( w_hresp_slv3  ),
    .hrdata          ( w_hrdata_slv3 ),
    .bist_done       (),
    .bist_fail       ()
 );

endmodule 
