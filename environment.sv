class environment;
    virtual TopIf vif;

    mailbox #(transaction) mon2scb;
    mailbox #(transaction) gen2drv;

    driver drv;
    generator gen;
    scoreboard scb;
    monitor mon;

    function new(virtual TopIf vif,int num_trans =100);
        this.vif = vif;
        gen2drv = new();
        mon2scb = new();
        drv = new(gen2drv,vif);
        gen = new(gen2drv,num_trans);
        scb = new(mon2scb);
        mon = new(mon2scb,vif);
    endfunction

    task run();
        fork 
            drv.run();
            gen.run();
            scb.run();
            mon.run();
        join_none
    endtask
endclass