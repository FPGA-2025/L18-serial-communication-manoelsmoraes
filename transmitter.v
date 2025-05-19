module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sending;

    wire parity_bit = ~(^data_in); // paridade par

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            serial_out <= 1'b1; // linha em repouso
            sending <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
        end else begin
            if (start && !sending) begin
                sending <= 1;
                bit_cnt <= 0;
                shift_reg <= {parity_bit, data_in}; // [paridade, D6...D0]
                serial_out <= 1'b0; // start bit
            end else if (sending) begin
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt < 8)
                    serial_out <= shift_reg[bit_cnt];
                else begin
                    serial_out <= 1'b1; // linha volta ao repouso
                    sending <= 0;
                end
            end else begin
                serial_out <= 1'b1; // linha em repouso
                // Não faz nada se não estiver enviando
            end
        end
    end

endmodule
