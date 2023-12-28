module interconnect_decoder #(parameter ADDR_WIDTH = 32)(
    input [ADDR_WIDTH-1:0]  haddr,
    output [3:0]                     hsel
);

    reg [3:0]                        r_hsel;
    reg                              sel_en; 
    wire [1:0]                       w_haddr_sel;

    assign w_haddr_sel = haddr[31:30];
    assign hsel = r_hsel;

    always @(*) begin
        case (w_haddr_sel)
            2'd0 : r_hsel = 4'd0;
            2'd1 : r_hsel = 4'b0001;
            2'd2 : r_hsel = 4'b0010;
            2'd3 : r_hsel = 4'b0100;
            default : begin
                r_hsel = 4'd0;
            end
        endcase 
    end

endmodule 