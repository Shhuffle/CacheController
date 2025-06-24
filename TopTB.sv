module top_tb;

    logic clk, rst;

    // Interface instantiation
    TopIf inf_inst(clk, rst);

    // DUT instantiations
    CacheController dut (.intf(inf_inst));
    Pmemory         dut2(.intf(inf_inst));

    // Environment
    environment env;

    // Clock generation
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // Main test sequence
    initial begin 
        env = new(inf_inst, 100); // 100 transactions
        rst = 1'b0;
        #15 rst = 1'b1;           // Release reset after 15 time units
        env.run();                // Start environment
        #20000;                   // Give enough time for simulation to complete
        $display("Testbench completed at time %0t", $time);
        $finish;
    end

endmodule
