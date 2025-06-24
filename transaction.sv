class transaction;
randc bit [31:0] addr;
rand bit wr_en,rd_en;
rand bit [63:0] wr_data;

//variable to store some output of the cache and the input of the memory, will be used in monitor and scoreboard.
bit [63:0] mem_data; //data read form the primary memory
bit mem_data_valid;
bit [63:0] rd_data_from_cache; //data read form the cache memory
bit hit , stall, mem_rd_en;
bit [31:0] mem_addr;


//to allow only read or write in one clock cycle
constraint validRW {
    wr_en + rd_en <= 1'b1; //ensure either rd is enabled or write is enable at a time
};

function void display();
  $display("ADDR: %h | WR: %b | RD: %b | WR_DATA: %h | RD_DATA: %h | HIT: %b | STALL: %b",
            addr, wr_en, rd_en, wr_data, rd_data, hit, stall);
endfunction

endclass