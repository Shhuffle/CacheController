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
        forever begin 
            transaction t = new();
            mon2scb.get(t);

            int idx = t.addr[20:3];

            if (t.hit) begin
                if (t.wr_en) begin
                    ref_cachemem[idx] = t.wr_data;
                    for (int i = 0; i < 8; i++)
                        ref_Pmem[t.addr + i] = t.wr_data[8*i +: 8];
                end

                if (t.rd_en) begin
                    if (ref_cachemem[idx] !== t.rd_data)
                        $error("[SCB] Cache read mismatch! Expected: %h, Got: %h", ref_cachemem[idx], t.rd_data);
                end

            end else if (t.stall && t.mem_data_valid) begin
                int mem_idx = t.mem_addr[20:3];
                ref_cachemem[mem_idx] = t.mem_data;

               
                logic [63:0] expected;
                expected = 64'b0;
                for (int i = 0; i < 8; i++)
                    expected[8*i +: 8] = ref_Pmem[t.mem_addr + i];

                if (expected !== t.mem_data)
                    $error("[SCB] Memory refill mismatch! Expected: %h, Got: %h", expected, t.mem_data);
            end
        end
    endtask
endclass
