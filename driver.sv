class driver;

    virtual TopIf vif;
    mailbox #(transaction) gen2drv;

    function new(mailbox #(transaction) gen2drv , virtual TopIf vif); 
        this.gen2drv = gen2drv;
        this.vif = vif;
    endfunction

    task run();
        transaction t;
        forever begin
            gen2drv.get(t);
            drive(t);
        end
    endtask

    task drive(ref transaction t);
        vif.addr    <= t.addr;
        vif.wr_data <= t.wr_data;
        vif.wr_en   <= t.wr_en;
        vif.rd_en   <= t.rd_en;

        t.display();
        // @(posedge vif.clk);
        // vif.wr_en <= 0;
        // vif.rd_en <= 0;
    endtask
endclass
