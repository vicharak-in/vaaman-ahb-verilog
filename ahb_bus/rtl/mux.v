module interconnect_mux(
    input           i_hready_slv1,
    input [31:0]    i_hrdata_slv1,
    input [1:0]          i_hresp_slv1,

    input           i_hready_slv2,
    input [31:0]    i_hrdata_slv2,
    input [1:0]         i_hresp_slv2,

    input           i_hready_slv3,
    input [31:0]    i_hrdata_slv3,
    input [1:0]         i_hresp_slv3,

    input [3:0]     i_hsel_decoder,

    output          o_hready,
    output [31:0]         o_hrdata,
    output [1:0]        o_hresp      

);

    assign {o_hready,o_hrdata,o_hresp} = (i_hsel_decoder[0]) ? {i_hready_slv1,i_hrdata_slv1,i_hresp_slv1} :
                                         (i_hsel_decoder[1]) ? {i_hready_slv2,i_hrdata_slv2,i_hresp_slv2} :
                                         (i_hsel_decoder[2]) ? {i_hready_slv3,i_hrdata_slv3,i_hresp_slv3} : {1'd0,32'd0,1'd0};

endmodule