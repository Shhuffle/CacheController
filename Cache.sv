module CacheController(TopIf.CacheController intf);
parameter NUM_LINES = 2**18;
parameter TAG_WIDTH = 11;

// Tag and Valid arrays
logic [TAG_WIDTH-1:0] tag_array [0:NUM_LINES-1]; // Stores the tag address of every line mapped form block.
logic                 valid_array [0:NUM_LINES-1]; //It will indicate if the data at that line is correct or not stores 1 if correct 0 if incorrect 

logic [63:0] cachemem [0:NUM_LINES-1]; //cache memory
logic [17:0] index;


typedef enum logic [1:0] {
    IDLE,
    WRITE,
    READ,
    STALL
}state_t;

state_t current_state, next_state;

assign index = intf.addr[19:2];
typedef enum logic {
    hit,
    miss
} tagHitorMiss;

function void CacheStatus(ref tagHitorMiss t);
    t = miss;
    intf.hit = 1'b0;
    if (tag_array[index] == intf.addr[31:21]) 
    begin 
        if(valid_array[index] == 1'b1 && current_state == READ)begin
        intf.hit = 1;
        t = hit;
        end
        else if(current_state == WRITE)
        begin 
            intf.hit =1;
            t = hit;
        end
    end
endfunction


tagHitorMiss t_hit_miss;
always_comb begin 
    CacheStatus(t_hit_miss);
end



always_ff @(posedge intf.clk or negedge intf.rst) begin 
    if(!intf.rst) begin
        foreach (valid_array[i]) begin //reset will earse all the value at the cache tag and its value so the value is invalid
            valid_array[i] <= 1'b0;
        end
            intf.hit <= 0;
            intf.stall <= 0;
            intf.rd_data <= 0;

        current_state <= IDLE;
    end
    else begin  
        current_state <= next_state;
    end
end



always_comb begin
    case(current_state)
    IDLE : begin 
            if(intf.wr_en) 
                next_state = WRITE;
            else if(intf.rd_en)
                next_state = READ;
            else if(intf.mem_rd_en)
                next_state = STALL;
        end

    WRITE : begin 
        if(t_hit_miss == hit)
        begin 
            cachemem[index] = intf.wr_data;
        end
        next_state = IDLE;
    end

    READ : begin 
        if(t_hit_miss == hit)
        begin
            intf.rd_data = cachemem[index];
        end
        next_state = IDLE;
    end
    default: next_state = IDLE;
   endcase
end
endmodule