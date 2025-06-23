interface TopIf(input logic clk, input logic rst);

logic rd_en, wr_en, hit,stall, mem_rd_en, mem_data_valid;
logic [63:0]wr_data, rd_data, mem_data;
logic [31:0] addr, mem_addr;

modport CacheController(input addr,rd_en,wr_en,wr_data,mem_data,mem_data_valid,clk,rst,
                        output rd_data,hit,stall,mem_rd_en,mem_addr);

endinterface