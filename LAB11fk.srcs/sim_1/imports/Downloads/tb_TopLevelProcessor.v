`timescale 1ns/1ps
module tb_TopLevelProcessor;
    reg clk = 0, rst = 1;
    reg [15:0] sw = 16'h0000, btns = 16'h0000;
    wire [15:0] led;
    integer errors = 0;

    TopLevelProcessor dut(
        .clk(clk), .rst(rst), .sw(sw), .btns(btns), .led(led)
    );

    always #5 clk = ~clk;

    task check(input [31:0] got, exp, input [255:0] name);
        if (got === exp) $display("PASS %0s = %0d", name, got);
        else begin
            $display("FAIL %0s: got %0d expected %0d", name, got, exp);
            errors = errors + 1;
        end
    endtask

    task wait_led(input [15:0] val, input integer max, input [255:0] name);
        integer n;
        begin
            n = 0;
            while (led !== val && n < max) begin @(posedge clk); #1; n = n + 1; end
            check(led, val, name);
        end
    endtask

    initial begin
        $dumpfile("top.vcd");
        $dumpvars(0, tb_TopLevelProcessor);

        // Preload countdown + abort program directly into instruction memory
        #1;
        dut.imem.mem[0]  = 32'h30000293; // 0x00: addi x5, x0, 768    (sw addr)
        dut.imem.mem[1]  = 32'h20000313; // 0x04: addi x6, x0, 512    (led addr)
        dut.imem.mem[2]  = 32'h30400393; // 0x08: addi x7, x0, 772    (btns addr)
        dut.imem.mem[3]  = 32'h00000013; // 0x0C: nop
        dut.imem.mem[4]  = 32'h0002A403; // 0x10 (PC=16): lw x8, 0(x5)    (read sw)
        dut.imem.mem[5]  = 32'hFE040EE3; // 0x14 (PC=20): beq x8, x0, -4  (wait loop -> 0x10)
        dut.imem.mem[6]  = 32'h00832023; // 0x18: sw   x8, 0(x6)      (led = count)
        dut.imem.mem[7]  = 32'h00800513; // 0x1C: addi x10, x0, 8     (delay count)
        dut.imem.mem[8]  = 32'h0003A583; // 0x20: lw   x11, 0(x7)     (read btns)
        dut.imem.mem[9]  = 32'h00058463; // 0x24: beq  x11, x0, +8    (if btns==0 -> 0x2C)
        dut.imem.mem[10] = 32'h00000E63; // 0x28: beq  x0, x0, +28    (abort -> 0x44)
        dut.imem.mem[11] = 32'hFFF50513; // 0x2C: addi x10, x10, -1   (delay--)
        dut.imem.mem[12] = 32'h00050463; // 0x30: beq  x10, x0, +8    (if delay==0 -> 0x38)
        dut.imem.mem[13] = 32'hFE0006E3; // 0x34: beq  x0, x0, -20    (delay loop -> 0x20)
        dut.imem.mem[14] = 32'hFFF40413; // 0x38: addi x8, x8, -1     (count--)
        dut.imem.mem[15] = 32'h00040463; // 0x3C: beq  x8, x0, +8     (if count==0 -> 0x44)
        dut.imem.mem[16] = 32'hFC000CE3; // 0x40: beq  x0, x0, -40    (next count -> 0x18)
        dut.imem.mem[17] = 32'h00032023; // 0x44: sw   x0, 0(x6)      (led = 0)
        dut.imem.mem[18] = 32'hFC0006E3; // 0x48: beq  x0, x0, -56    (back to 0x10)

        // ---- idle ----
        #11 rst = 0;
        #100;
        check(led, 0, "LEDs idle (sw=0)");
        check((dut.pc == 16 || dut.pc == 20), 1, "PC in wait loop");

        // ---- countdown from 3 ----
        @(negedge clk); sw = 16'd3;
        wait_led(16'd3, 100, "LEDs show 3");
        wait_led(16'd2, 200, "LEDs show 2");
        wait_led(16'd1, 200, "LEDs show 1");
        wait_led(16'd0, 200, "LEDs show 0");
        sw = 16'd0;                              // stop restarting
        #200;
        check(led, 0, "LEDs idle again");
        check((dut.pc == 16 || dut.pc == 20), 1, "PC back in loop");

        // ---- abort with button ----
        @(negedge clk); sw = 16'd5;
        wait_led(16'd5, 100, "LEDs show 5");
        wait_led(16'd4, 200, "LEDs show 4");
        @(negedge clk); btns = 16'd1; sw = 16'd0;   // press abort, release switches
        #300;
        check(led, 0, "LEDs cleared by abort");
        check((dut.pc == 16 || dut.pc == 20), 1, "PC idle after abort");
        btns = 16'd0;

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d FAILED", errors);
        #50 $finish;
    end
endmodule