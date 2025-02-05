module vending_fsm(
  input clk,
  input rst_n,
  input money_inserted,
  input inserted_money_valid,
  input [7:0] inserted_money_value,
  input product_selected,
  input [7:0] product_cost,
  input product_available,
  output reg return_money,
  output reg deliver_product,
  output reg return_change,
  output reg [7:0] change_value
  );

  parameter ST_IDLE              = 3'b000,
            ST_CHECK_MONEY_VLD   = 3'b001,
            ST_WAIT_FOR_PRD_SEL  = 3'b010,
            ST_CHECK_PRD_AVL     = 3'b011,
            ST_CHECK_PRD_COST    = 3'b100,
            ST_DELIVER_PRODUCT   = 3'b101,
            ST_RETURN_CHANGE     = 3'b110;

  reg [2:0] st_cur_r, st_nxt_s;
  reg return_money_s, deliver_product_s, return_change_s;
  reg product_cost_lesser_s;
  reg [7:0] change_s; 
  reg signed [8:0] change_temp_s;

  always @(*) begin
    if (inserted_money_value < product_cost) begin
      change_temp_s = {1'b0, inserted_money_value};
    end else begin
      change_temp_s = {1'b0, inserted_money_value} - {1'b0, product_cost};
    end
    product_cost_lesser_s = (inserted_money_value < product_cost);
    change_s = change_temp_s[7:0];
  end

  always @(*) begin
    return_money = return_money_s;
    deliver_product = deliver_product_s;
    return_change = return_change_s;
    change_value = change_s;
  end

  always @(posedge clk or negedge rst_n) begin  
    if (!rst_n) begin
      st_cur_r <= ST_IDLE;
    end else begin
      st_cur_r <= st_nxt_s;
    end
  end

  always @(*) begin
    st_nxt_s = st_cur_r;
    return_money_s = 1'b0;
    deliver_product_s = 1'b0;
    return_change_s = 1'b0;

    case (st_cur_r)
      ST_IDLE: begin
        if (money_inserted) st_nxt_s = ST_CHECK_MONEY_VLD;
      end
      ST_CHECK_MONEY_VLD: begin  
        if (inserted_money_valid) st_nxt_s = ST_WAIT_FOR_PRD_SEL;
        else begin
          st_nxt_s = ST_IDLE;
          return_money_s = 1'b1;
        end
      end
      ST_WAIT_FOR_PRD_SEL: begin
        if (product_selected) st_nxt_s = ST_CHECK_PRD_AVL;
      end
      ST_CHECK_PRD_AVL: begin
        if (product_available) st_nxt_s = ST_CHECK_PRD_COST;
        else begin
          st_nxt_s = ST_IDLE;
          return_money_s = 1'b1;
        end
      end
      ST_CHECK_PRD_COST: begin
        if (!product_cost_lesser_s) st_nxt_s = ST_DELIVER_PRODUCT;  
        else begin
          st_nxt_s = ST_IDLE;
          return_money_s = 1'b1;
        end
      end
      ST_DELIVER_PRODUCT: begin
        deliver_product_s = 1'b1;
        if (change_s > 0) st_nxt_s = ST_RETURN_CHANGE;
        else st_nxt_s = ST_IDLE;
      end
      ST_RETURN_CHANGE: begin
        return_change_s = 1'b1;
        st_nxt_s = ST_IDLE;
      end
    endcase
  end

endmodule

