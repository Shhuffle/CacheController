class transaction;
randc logic [31:0] addr;
rand logic wr_en,rd_en;
rand logic [63:0] wr_data;

//variable to store some output of the cache and the input of the memory, will be used in monitor and scoreboard.
logic [63:0] mem_data; //data read form the primary memory
logic mem_data_valid;
logic [63:0] rd_data_from_cache; //data read form the cache memory
logic hit , stall, mem_rd_en;
logic [31:0] mem_addr;


//to allow only read or write in one clock cycle
constraint validRW {
    wr_en + rd_en <= 1'b1; //ensure either rd is enabled or write is enable at a time
};

function void display();
  $display("ADDR: %h | WR: %b | RD: %b | WR_DATA: %h | RD_DATA: %h | HIT: %b | STALL: %b",
            addr, wr_en, rd_en, wr_data, rd_data, hit, stall);
endfunction

endclass