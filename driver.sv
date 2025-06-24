class driver;

virtual TopIf vif;
mailbox #(transaction) gen2dri;

function new(mailbox #(transaction) gen2dri , virtual TopIf vif) 
    this.gen2dri = gen2dri;
    this.vif =  vif;
endfunction

task run()

endtask


endclass