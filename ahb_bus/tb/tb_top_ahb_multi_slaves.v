module tb_top_ahb_multi_slave ();
    parameter                   ADDR_WIDTH = 32;
    parameter                   DATA_WIDTH = 32;
    parameter                   TRANS_SIZE = 32;

    reg                       start_trans;
    reg [ADDR_WIDTH-1:0]      ext_haddr;
    reg [DATA_WIDTH-1:0]      ext_hwdata;
    reg                       ext_hwrite;    
    reg [2:0]                 ext_hburst;
    reg                       hclk;
    wire                      sram_clk;
    reg                       hresetn;
    wire [ADDR_WIDTH-1:0]     haddr;
    wire [DATA_WIDTH-1:0]     hwdata;
    wire                      hwrite;
    wire [2:0]                hburst; 
    reg  [1:0]                hresp;
    reg                       stop_trans;
    reg [31:0]                hrdata;
    reg [2:0]                 ext_hsize;
    reg                       hsel;
    reg                       hready;
    reg                       dft_en;
    reg                       bist_en;

    wire [2:0]                hsize;


    top_ahb_multi_slaves top_mod(
        .hclk          (hclk),
        .sram_clk      (sram_clk),
        .hresetn       (hresetn),
        .stop_trans    (stop_trans),
        .start_trans   (start_trans),
        .ext_haddr     (ext_haddr),
        .ext_hwdata    (ext_hwdata),
        .ext_hwrite    (ext_hwrite),
        .ext_hburst    (ext_hburst),
        .ext_hsize     (ext_hsize),
        .dft_en        (dft_en),
        .bist_en       (bist_en)

    );
    always #5 hclk = ~hclk;
    assign sram_clk = ~hclk;
    initial begin
	    hclk = 0;
        start_trans = 0;
        ext_haddr = 0;
        ext_hwdata = 0;
        ext_hwrite = 0;
        ext_hburst = 0;
        hresetn = 0; 
        stop_trans = 0; 
    end

    initial begin
        $dumpfile("top.vcd");
        $dumpvars;
    end

    initial begin
        #10 
            dft_en = 0;
            bist_en = 0;
            start_trans = 1;
            hresetn = 1;
            ext_haddr = 32'h4000001e;
            ext_hwrite = 1;
            ext_hburst = 3'd3;
            ext_hsize = 3'd2;


        #10 ext_hwdata = 32'd11;
        #10 ext_hwdata = 32'd12;
        #10 ext_hwdata = 32'd13;


        #10
            ext_hwdata = 32'd52;
        #10
            stop_trans = 1;   

        #10 stop_trans = 0; 

        #10
            ext_haddr = 32'hc000004e;
            ext_hwrite = 1;
            ext_hburst = 3'd0;
            ext_hsize = 3'd2;

        #10 ext_hwdata = 32'd10;
            ext_haddr = 32'h8000005e;
            ext_hwrite = 1;
            ext_hburst = 3'd0;
            ext_hsize = 3'd2;

        #10 ext_hwdata = 32'd14;

        #10 stop_trans = 1;

        #10 stop_trans = 0;
            ext_hwrite = 0;
            ext_hburst = 3'd3;
            ext_hsize = 3'd2;
            ext_haddr = 32'h4000001e;
        #60
            stop_trans = 1;
        
        #10 stop_trans = 0;

        #10 start_trans = 1;
            ext_hwrite = 1;
            ext_hburst = 3'd3;
            ext_hsize = 3'd2;
            ext_haddr = 32'h4000009e;
        #10 ext_hwdata = 32'd78;
        #10 ext_hwdata = 32'd79;
        #10 ext_hwdata = 32'd80;
        #10 ext_hwdata = 32'd81;

        #10 stop_trans = 1;

        #10 stop_trans = 0;

        #10 ext_haddr = 32'h40000068;
            ext_hwrite = 1;
            ext_hburst = 3'd0;
            ext_hsize = 3'd2;

        #10 ext_hwdata = 32'd90;
            ext_haddr = 32'h40000075;
            ext_hwrite = 1;
            ext_hburst = 3'd0;
            ext_hsize = 3'd2;

        #10 ext_hwdata = 32'd30;
            ext_hwrite = 1;
            #10
            ext_hburst = 3'd3;
            ext_hsize = 3'd2;
            ext_haddr = 32'h40000090;
        #10 ext_hwdata = 32'd50;
        #10 ext_hwdata = 32'd51;
        #10 ext_hwdata = 32'd53;
        #10 ext_hwdata = 32'd58;
        #10 stop_trans = 1;
        #10 stop_trans = 0;
            ext_hwrite = 0;
            ext_hburst = 3'd3;
            ext_hsize = 3'd2;
            ext_haddr = 32'h40000090;
        #60
            stop_trans = 1;
            #10 stop_trans = 0;
            start_trans = 0;

    

        #1000 $finish();
    end


endmodule 
