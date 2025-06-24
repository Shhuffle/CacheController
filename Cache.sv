module CacheController(TopIf.CacheController intf);
parameter NUM_LINES = 2**18;
parameter TAG_WIDTH = 11;

// Tag and Valid arrays
logic [TAG_WIDTH-1:0] tag_array [0:NUM_LINES-1]; // Stores the tag address of every line mapped form block.
logic                 valid_array [0:NUM_LINES-1]; //It will indicate if the data at that line is correct or not stores 1 if correct 0 if incorrect 

logic [63:0] cachemem [0:NUM_LINES-1]; //cache memory
logic [17:0] index;

logic was_wmiss, was_wmiss_next; //will be used in the state case. IF 0 then the refill will of read type and if 1 then the refill state will of write type

always_ff @(posedge intf.clk or negedge intf.rst) begin
    if (!intf.rst) begin
        was_wmiss <= 1'b0;
    end else begin
        was_wmiss <= was_wmiss_next;
    end
end

typedef enum logic [2:0] {
    IDLE,
    WRITE,
    READ,
    RMISS,
    WMISS,
    REFILL
}state_t;

state_t current_state, next_state;
assign index = intf.addr[20:3];

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
        foreach (tag_array[i]) begin
            tag_array[i] <= 0;
            cachemem[i] <= 0;
            valid_array[i] <=0;
        end

            intf.hit <= 0;
            intf.stall <= 0;
            intf.rd_data <= 0;
            intf.mem_rd_en <= 0;
            intf.mem_wd_en <=0;
            intf.mem_data_valid <=0;
            intf.mem_wd_valid <=0;

        current_state <= IDLE;
    end
    else begin  
        current_state <= next_state;
    end
end


always_comb begin
    case(current_state)
    IDLE : begin 
            if (intf.rd_en && t_hit_miss == miss)
            next_state = RMISS;
            else if (intf.rd_en && t_hit_miss == hit)
            next_state = READ;
            else if (intf.wr_en && t_hit_miss == miss)
            next_state = WMISS;
            else if (intf.wr_en && t_hit_miss == hit)
            next_state = WRITE;
            else
            next_state = IDLE;
        end
    WRITE : begin 
            cachemem[index] = intf.wr_data;
            valid_array[index]=1'b1; // After successfull write indicating that the data at that location is valid
            next_state = IDLE;
        end
    
    READ : begin 
        if(t_hit_miss == hit)
        begin
            intf.rd_data = cachemem[index];
        end
        next_state = IDLE;
    end
    RMISS: begin 
            intf.stall = 1'b1;
            intf.mem_rd_en = 1'b1;
            intf.mem_addr = intf.addr;

            if(intf.mem_data_valid) 
                next_state = REFILL;
            else 
                next_state = RMISS;//stay in this state till the data is received form the memory

            was_wmiss_next= 1'b0;
        end

    WMISS: begin 
            intf.stall = 1'b1;
            intf.mem_wd_en = 1'b1;
            intf.mem_addr = intf.addr;
            intf.mem_wd_data = intf.wr_data;


            if(intf.mem_wd_valid) 
                next_state = REFILL;
            else 
                next_state = WMISS ; //stay in this state untill the data is written back to the primary memory.

             was_wmiss_next = 1'b1;
            end

    REFILL: begin 

            if(!was_wmiss)
                cachemem[index] = intf.mem_data;
            else if(was_wmiss)
                cachemem[index] = intf.wr_data;

            tag_array[index] = intf.addr[31:21];
            valid_array[index] = 1'b1;


            intf.stall = 1'b0;
            intf.mem_rd_en = 1'b0;

            if(intf.rd_en) begin 
                intf.rd_data = intf.mem_data;
            end
            next_state = IDLE;
        end
    default: next_state = IDLE;
   endcase
end
endmodule





