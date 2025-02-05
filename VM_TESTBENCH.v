`timescale 1ns/1ps

module vending_fsm_tb;

  reg clk, rst_n;
  reg money_inserted, inserted_money_valid, product_selected, product_available;
  reg [7:0] inserted_money_value, product_cost;
  wire return_money, deliver_product, return_change;
  wire [7:0] change_value;

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  vending_fsm DUT (
    .clk(clk),
    .rst_n(rst_n),
    .money_inserted(money_inserted),
    .inserted_money_valid(inserted_money_valid),
    .inserted_money_value(inserted_money_value),
    .product_selected(product_selected),
    .product_cost(product_cost),
    .product_available(product_available),
    .return_money(return_money),
    .deliver_product(deliver_product),
    .return_change(return_change),
    .change_value(change_value)
  );

  initial begin
    // Test Case 1
    rst_n = 0;
    money_inserted = 0;
    inserted_money_valid = 0;
    inserted_money_value = 0;
    product_selected = 0;
    product_cost = 0;
    product_available = 0;

    #20 rst_n = 1;

    #10 inserted_money_value = 8'd100 ; money_inserted = 1;
    #10 inserted_money_valid = 1;

    #20 product_selected = 1; product_cost = 8'd75;
    #10 product_available = 1;

//     #30 product_selected = 0;

    #50;
    
 // Test Case 2
     rst_n = 0;
    money_inserted = 0;
    inserted_money_valid = 0;
    inserted_money_value = 0;
    product_selected = 0;
    product_cost = 0;
    product_available = 0;

    #20 rst_n = 1;
    #20 money_inserted = 1; inserted_money_value = 8'd50;
    #10 inserted_money_valid = 1;

    #20 product_selected = 1;product_cost = 8'd65; 
    #10 product_available = 1;

    #30 product_selected = 0;

    #50;

    #100 $finish;
  end

  initial begin
    $dumpfile("vending_fsm_waveform.vcd");
    $dumpvars(0, vending_fsm_tb);
  end

endmodule

