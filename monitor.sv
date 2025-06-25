class monitor;
mailbox #(transaction) mon2scb;
virtual TopIf vif;

function new(mailbox #(transaction) mon2scb,virtual TopIf vif);
    this.mon2scb = mon2scb;
    this.vif = vif;
endfunction

task run();
    forever begin 
        @(posedge vif.clk);
        if (vif.rd_en || vif.wr_en || vif.mem_rd_en || vif.mem_data_valid) begin
            transaction t =new();
            t.addr = vif.addr;
            t.wr_data = vif.wr_data;
            t.wr_en = vif.wr_en;
            t.rd_en = vif.rd_en;

            t.mem_data = vif.mem_data;
            t.mem_data_valid = vif.mem_data_valid;
            t.rd_data_from_cache = vif.rd_data;
            t.hit = vif.hit;
            t.stall = vif.stall;
            t.mem_rd_en = vif.mem_rd_en;
            t.mem_addr = vif.mem_addr;

            mon2scb.put(t);
            if(vif.mem_rd_en) 
                $display("[MON] @%0t: Reading from Pmem, addr = %0d", $time, vif.mem_addr);
                    
            if(vif.mem_data_valid)
                $display("[MON] @%0t: Pmem returned data = 0x%h form address %0d", $time, vif.mem_data,vif.mem_addr);

            if(vif.stall)
                $display("[MON] Stall detected");

            if(vif.wr_data)
                $display("[MON] Writing 0x%h in adddress %0d",vif.wr_data,vif.addr);

            if(vif.mem_wd_valid)
                    $display("[MON] @%0t: data = 0x%h written in  address %0d", $time, vif.mem_wd_data,vif.mem_addr);
        end
    end
endtask
endclass