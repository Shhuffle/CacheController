class generator;
    mailbox #(transaction) gen2drv;
    int num_trans;
    
    function new (mailbox #(transaction) gen2drv, int num_trans = 100);
        this.gen2drv = gen2drv;
        this.num_trans = num_trans;
    endfunction


    task run();
        repeat (num_trans) begin
            transaction t = new();
            assert(t.randomize()) else $fatal("Randomization failed: ");
            gen2drv.put(t);
        end
    endtask
endclass