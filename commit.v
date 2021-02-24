module commit();// update the register file and write the values back
  always @(posedge run.clk)
  begin
    $display("\n");
    $display("\n");
    $display("\nCycle : ",($time-10)/20,"  \n");
    $display("COMMITT STAGE : \n",);
      if((run.v_des[run.head] == 1'b1) && (run.commit[run.head] == 1'b0))// start committing
      begin
          $display("        Instruction : %h , Committed\n", run.rob_instruction_feild[run.head]);
          if(run.reg_rename[run.rob_dest_reg_feild[run.head]] == run.head)
            begin
              // update register file;
                  run.reg_file[run.rob_dest_reg_feild[run.head]]  = run.rob_dest_reg_value[run.head];
                  run.reg_valid[run.rob_dest_reg_feild[run.head]] = 1'b1;
                  $display("         Register File");
                  $display("         R[%h] : %h\n",run.rob_dest_reg_feild[run.head] , run.rob_dest_reg_value[run.head]);

            end
            run.commit[run.head] = 1'b1;
            run.v_des[run.head] = 1'b0;
            run.head = run.head + 2'b01;
            run.rob_no_of_enteries = run.rob_no_of_enteries - 1;
            $display("         ROB\n");
            $display("         1.Head : %h" , run.head);
            $display("         2.Committed : %h",run.commit[run.head]);
            $display("         3.Size : %h\n",run.rob_no_of_enteries);

      end

      else
      begin
       if(run.rob_no_of_enteries == 0)
         $display("        Rob : Empty\n");
      else
         $display("        Instruction : %h , Waiting for Values\n" , run.rob_instruction_feild[run.head]);
      end
  end
endmodule
