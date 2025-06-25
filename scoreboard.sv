class scoreboard;
    parameter index = 2 ** 12;
    parameter mem_size = 2 ** 22;

    mailbox #(transaction) mon2scb;

    bit [63:0] ref_cachemem [0:index-1];
    bit [7:0]  ref_Pmem [0:mem_size-1];

    function new(mailbox #(transaction) mon2scb);
        this.mon2scb = mon2scb;
    endfunction 

    task run();
         int cache_idx,mem_idx;
         logic [63:0] expected;
        forever begin 
            transaction t = new();
            mon2scb.get(t);

            cache_idx = t.addr[20:3];
            mem_idx   = t.mem_addr[20:3];

            if (t.hit) begin
                if (t.wr_en) begin
                    ref_cachemem[cache_idx] = t.wr_data;
                    for (int i = 0; i < 8; i++)
                        ref_Pmem[t.addr + i] = t.wr_data[8*i +: 8];
                end

                if (t.rd_en) begin
                    if (ref_cachemem[cache_idx] !== t.rd_data_from_cache)
                        $error("[SCB] Cache read mismatch! Expected: %h, Got: %h", ref_cachemem[cache_idx], t.rd_data_from_cache);
                end

            end else if (t.stall) begin
                if (t.mem_data_valid) begin 
                    ref_cachemem[mem_idx] = t.mem_data;

                    expected = 64'b0;
                    for (int i = 0; i < 8; i++)
                        expected[8*i +: 8] = ref_Pmem[t.mem_addr + i];

                    if (expected !== t.mem_data)
                        $error("[SCB] Memory refill mismatch! Expected: %h, Got: %h", expected, t.mem_data);
                end 

                if (t.mem_wd_en && t.mem_wd_valid) begin 
                    for (int i = 0; i < 8; i++) 
                        ref_Pmem[t.mem_addr + i] = t.wr_data[8*i +: 8];

                    
                    ref_cachemem[mem_idx] = t.wr_data;
                end
            end
        end
    endtask
endclass
