module Pmemory(TopIf.Pmem intf);
  parameter MEM_DEPTH = 2**32; // might be too heavy for simulations.
  logic [7:0] mem [0:MEM_DEPTH-1];

  logic [63:0] data_buffer;


  always_ff @(posedge intf.clk or negedge intf.rst) begin
    if (!intf.rst) begin
      intf.mem_data       <= 64'b0;
      intf.mem_data_valid <= 1'b0;
    end
    else begin
      if (intf.mem_rd_en) begin
        // Load 64-bit data (8 bytes)
        for (int i = 0; i < 8; i++) begin
           data_buffer[8*i +: 8] = mem[intf.mem_addr + i]; // little endian rule i.e lower mem address stores the LSB
        end


        intf.mem_data       <= data_buffer;
        intf.mem_data_valid <= 1'b1;
      end
      else begin
        intf.mem_data_valid <= 1'b0;
      end
    end
  end
endmodule
