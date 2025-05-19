module receiver (
    input clk,
    input rstn,
    output reg ready,
    output reg [6:0] data_out,
    output reg parity_ok_n,
    input serial_in
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg receiving;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            receiving <= 0;
            bit_cnt <= 0;
            shift_reg <= 0;
            data_out <= 0;
            ready <= 0;
            parity_ok_n <= 1; // isso precisa estar em 1 para indicar que não há dados válidos
        end else begin
            ready <= 0;

            if (!receiving) begin
                if (serial_in == 0) begin // detecta start bit
                    receiving <= 1;
                    bit_cnt <= 0;
                end
            end else begin
                 bit_cnt <= bit_cnt + 1;

                if (bit_cnt < 8) begin
                    // Armazena 7 bits de dados + paridade (bit_cnt 0 a 7)
                    shift_reg <= {serial_in, shift_reg[7:1]};
                end

                if (bit_cnt == 8) begin
                    // Após o 8º bit recebido (bit de paridade)
                    receiving <= 0;
                    data_out <= shift_reg[6:0];
                    parity_ok_n <= ^{shift_reg[6:0], serial_in}; // paridade dos dados + último bit
                    ready <= 1;
                end
            end
        end
    end

endmodule