module issue();
   fetch f();
   decode d();
   execute e();
   write_back wb();
   commit c();
endmodule

/* This module gets the instruction from the memory
puts the data in instruction queue */
module fetch();
//reg [3:0]previous_pc,current_pc;// this will account for stall  condition
always@(posedge run.clk)
begin
  #8
  $display("FETCH STAGE : \n");
  if(!run.iq_f)
    begin// it only write in intruc      vguhgution queue if iq_f = 0;
       run.instruction_queue[run.instruction_queue_tail] = run.instruction_memory[run.pc];
       $display("        PC : %h \n",run.pc);
       $display("        Fetched : %h \n",run.instruction_queue[run.instruction_queue_tail]);
       run.instruction_queue_no_of_enteries = run.instruction_queue_no_of_enteries + 1;
       $display("        Instruction queue\n");
       $display("        Size : %d ",run.instruction_queue_no_of_enteries);
       run.instruction_queue_tail =  run.instruction_queue_tail + 2'b01;
       $display("        Head : %h ",run.instruction_queue_head);
       $display("        Tail : %h \n",run.instruction_queue_tail);
       if(run.instruction_queue_no_of_enteries == 4)//4 = length of instruction_queue
              run.iq_f = 1'b1; // instruction_queue_is_full --> dont allow write for further instructions
       run.pc = run.pc + 4'b0001;// next instruction to be fetched;
    end
 else
  $display("        Stall , IQ : Full , Next PC = %b \n",run.pc);
end
endmodule

/*this module decodes the signal, add the entry to the ROB,
/and the sends the istruction to appropriate  reservation station */
module decode();

integer i ;
integer k ;
integer j ;
always @(posedge run.clk)
  begin
    #7
     $display("DECODE STAGE : \n");
     //$display("ROB HEAD : %h",run.head);
     //$display("ROB TAIL : %h",run.tail);
      if((run.instruction_queue_no_of_enteries != 0) && (run.rob_no_of_enteries < 8))//ensures instruction queue is not empty and rob is not full
         begin
              case(run.instruction_queue[run.instruction_queue_head][15:12])
                      4'b0000,4'b0001 :
                      begin
                          // check which entry is free and put it in that entry

                          if(run.res1_no_of_enteries < 4)
                                    begin
                                       // updating ROB
                                       $display("        Decoded : %h , Location : RS1 \n",run.instruction_queue[run.instruction_queue_head]);
                                       $display("        R0B  \n");
                                       $display("        1.ROB Head : %h",run.head);
                                       $display("        2.R0B Tail : %h",run.tail);

                                       run.rob_instruction_feild[run.tail] = run.instruction_queue[run.instruction_queue_head];

                                       run.rob_opcode_feild[run.tail] = run.instruction_queue[run.instruction_queue_head][15:12];// last 4 bits are opcode
                                       $display("        3.Opcode : %h",run.rob_opcode_feild[run.tail]);

                                       run.rob_dest_reg_feild[run.tail] = run.instruction_queue[run.instruction_queue_head][11:8];// destination register
                                       $display("        4.Destination Register : %h",run.rob_dest_reg_feild[run.tail] );

                                       run.v_des[run.tail] = 1'b0;// making valid bit 0;
                                       $display("        5.Valid value : %d", run.v_des[run.tail]);

                                       run.commit[run.tail] = 1'b0;
                                       $display("        6.Committed : %d",run.commit[run.tail]);

                                       run.rob_no_of_enteries = run.rob_no_of_enteries + 1;
                                       $display("        7.Rob Size \n: %d",run.rob_no_of_enteries);

                                       // searching for free entry in reservation station
                                       $display("        Reservation Station 1 \n");

                                       i = 0 ;
                                           while(i < 4)
                                                 begin
                                                   if(run.res1_free_entry[i] == 1'b1)begin
                                                   k = i ;
                                                   run.res1_free_entry[k] = 1'b0;
                                                   $display("         1.Index : %d",k);

                                                   run.res1_no_of_enteries = run.res1_no_of_enteries + 1;
                                                   $display("         2.Size : %d",run.res1_no_of_enteries);
                                                   i = 4 ;end
                                                   else
                                                    i = i+1;
                                            end
                                           //updating reservation station
                                           run.res1_instructions[k] = run.instruction_queue[run.instruction_queue_head];
                                           run.res1_opcode[k] = run.instruction_queue[run.instruction_queue_head][15:12];// opcode
                                           $display("         3.Opcode : %h",run.res1_opcode[k]);

                                           run.res1_ready[k] = 1'b0;// make it initially as not ready
                                           // sr1
                                           if(!run.reg_valid[run.instruction_queue[run.instruction_queue_head][7:4]])
                                              begin
                                                  run.res1_sr1_refrence[k] = 1'b0;// take value from ROB
                                                  run.res1_sr1_ref_value[k]= run.reg_rename[run.instruction_queue[run.instruction_queue_head][7:4]];// check refrence in rename register
                                                  $display("         4.Rs1 : Rob [%h] ",run.res1_sr1_ref_value[k]);
                                                  //$display("sr1 : %h",run.res1_sr1_ref_value[k]);
                                              end
                                          else
                                               begin
                                                 run.res1_sr1_refrence[k] = 1'b1; // value in actual register
                                                 run.res1_sr1[k] = run.reg_file[run.instruction_queue[run.instruction_queue_head][7:4]];//  register
                                                 $display("         5.Rs1 : R[%h] ",run.instruction_queue[run.instruction_queue_head][7:4]);
                                               end

                                            //sr2
                                            if(!run.reg_valid[run.instruction_queue[run.instruction_queue_head][3:0]])
                                                 begin
                                                     run.res1_sr2_refrence[k] = 1'b0; // take value from ROB // refrence to ROB
                                                     run.res1_sr2_ref_value[k] = run.reg_rename[run.instruction_queue[run.instruction_queue_head][3:0]];// check refrence in rename register
                                                     $display("         6.Rs2 : Rob [%h] ",run.res1_sr2_ref_value[k]);
                                                     //$display("sr2 : %h",run.res1_sr2_ref_value[k]);
                                                 end
                                            else
                                                  begin
                                                      run.res1_sr2_refrence[k] = 1'b1; //
                                                      run.res1_sr2[k] = run.reg_file[run.instruction_queue[run.instruction_queue_head][3:0]];//  register
                                                      $display("         7.Rs2 : R[%h] ",run.instruction_queue[run.instruction_queue_head][3:0]);
                                                  end
                                        // register renaming for destination register and updating value
                                          run.res1_dest[k] = run.tail;// storing refrence in ROB
                                          $display("         8.Rd : Rob [%h] ",run.res1_dest[k]);

                                          run.reg_rename[run.instruction_queue[run.instruction_queue_head][11:8]] = run.tail;// pointer to ROB
                                        // making valid bit 0; It also symbolises that the register is renamed and the value has to be fetched from R
                                          run.reg_valid[run.instruction_queue[run.instruction_queue_head][11:8]] = 1'b0; // / making valid bit 0; It also symbolises that the register is renamed and the value has to be fetched from taken corresponding to ROB
                                          run.tail = run.tail + 2'b01;

                                         if((run.res1_sr1_refrence[k] == 1'b1 && run.res1_sr2_refrence[k] == 1'b1) && (run.res1_free_entry[k] == 1'b0)) // if both operands are available make it ready
                                             begin
                                               run.res1_ready[k] = 1'b1;

                                             end
                                          else
                                             run.res1_ready[k] = 1'b0;
                                         $display("         9.Ready : %h ",run.res1_ready[k]);

                                         run.res1_issued[k] = 1'b0;// since this enrty is not issued yet
                                         $display("         10.Issued : %h \n",run.res1_issued[k]);
                                        // incrementing head pointer in instruction_queue and dercrementing no. of enteries in instruction_queue
                                         run.instruction_queue_head = run.instruction_queue_head + 2'b01;
                                         run.instruction_queue_no_of_enteries = run.instruction_queue_no_of_enteries - 1;

                              end
                          else
                                $display("        Stall , RS1 : Full\n");
                        end
                       4'b0010,4'b0011 :
                       begin
                           // check which entry is free and put it in that entry
                           if(run.res2_no_of_enteries < 4)
                                     begin
                                       $display("        Decoded : %h , Location : RS2 \n",run.instruction_queue[run.instruction_queue_head]);
                                        // updating ROB
                                        $display("        R0B : \n");
                                        $display("        1.ROB Head : %h",run.head);
                                        $display("        2.ROB Tail : %h",run.tail);
                                        run.rob_instruction_feild[run.tail] = run.instruction_queue[run.instruction_queue_head];

                                        run.rob_opcode_feild[run.tail] = run.instruction_queue[run.instruction_queue_head][15:12];// last 4 bits are opcode
                                        $display("        3.Opcode : %h",run.rob_opcode_feild[run.tail]);

                                        run.rob_dest_reg_feild[run.tail] = run.instruction_queue[run.instruction_queue_head][11:8];// destination register
                                        $display("        4.Destination Register : %h",run.rob_dest_reg_feild[run.tail] );

                                        run.v_des[run.tail] = 1'b0;// making valid bit 0;
                                        $display("        5.Valid value : %d", run.v_des[run.tail]);

                                        run.commit[run.tail] = 1'b0;
                                        $display("        6.Committed : %d",run.commit[run.tail]);

                                        run.rob_no_of_enteries = run.rob_no_of_enteries + 1;
                                        $display("        7.Rob Size : %d  \n",run.rob_no_of_enteries);

                                      // searching for free entry in reservation station
                                      $display("        Reservation Station 2  \n");

                                        i = 0 ;
                                            while(i < 4)
                                                  begin
                                                    if(run.res2_free_entry[i] == 1'b1)begin
                                                    k = i ;
                                                    $display("         1.Index : %d",k);
                                                    run.res2_free_entry[k] = 1'b0;

                                                    run.res2_no_of_enteries = run.res2_no_of_enteries + 1;
                                                    $display("         2.Size : %d",run.res2_no_of_enteries);
                                                    i = 4 ;end
                                                    else
                                                     i = i+1;
                                             end
                                            //updating reservation station
                                            run.res2_instructions[k] = run.instruction_queue[run.instruction_queue_head];
                                            run.res2_opcode[k] = run.instruction_queue[run.instruction_queue_head][15:12];// opcode
                                            $display("         3.Opcode : %h",run.res2_opcode[k]);

                                            run.res2_ready[k] = 1'b0;// make it initially as not ready

                                            // sr1
                                            if(!run.reg_valid[run.instruction_queue[run.instruction_queue_head][7:4]])
                                               begin
                                                   run.res2_sr1_refrence[k] = 1'b0;// take value from ROB
                                                   run.res2_sr1_ref_value[k] = run.reg_rename[run.instruction_queue[run.instruction_queue_head][7:4]];// check refrence in rename register
                                                  $display("         4.Rs1 : Rob [%h] ",run.res2_sr1_ref_value[k]);
                                                end
                                           else
                                                begin
                                                  run.res2_sr1_refrence[k] = 1'b1; // value in actual register
                                                  //$display("sr1 fine");
                                                  run.res2_sr1[k] = run.reg_file[run.instruction_queue[run.instruction_queue_head][7:4]];//  register
                                                  $display("         5.Rs1 : R[%h] ",run.instruction_queue[run.instruction_queue_head][7:4]);

                                                end

                                             //sr2
                                             if(!run.reg_valid[run.instruction_queue[run.instruction_queue_head][3:0]])
                                                  begin
                                                      run.res2_sr2_refrence[k] = 1'b0; // take value from ROB // refrence to ROB
                                                      run.res2_sr2_ref_value[k] = run.reg_rename[run.instruction_queue[run.instruction_queue_head][3:0]];// check refrence in rename register
                                                      $display("         6.Rs2 : Rob[%h] ",run.res2_sr2_ref_value[k]);
                                                      //$display("sr2 : %h",run.res2_sr2_ref_value[k]);
                                                  end
                                             else
                                                   begin
                                                       run.res2_sr2_refrence[k] = 1'b1; // value in actual register // refrence to regiseterfile;
                                                       //$display("sr2 fine");
                                                       run.res2_sr2[k] = run.reg_file[run.instruction_queue[run.instruction_queue_head][3:0]];//  register
                                                       $display("         7.Rs2 : R[%h] ",run.instruction_queue[run.instruction_queue_head][3:0]);
                                                   end
                                            // register renaming and updating values
                                            run.res2_dest[k] = run.tail;
                                            $display("         8.Rd : Rob [%h] ",run.res2_dest[k]);

                                            run.reg_rename[run.instruction_queue[run.instruction_queue_head][11:8]] = run.tail;// pointer to ROB
                                            // making valid bit 0; It also symbolises that the register is renamed and the value has to be fetched from
                                            run.reg_valid[run.instruction_queue[run.instruction_queue_head][11:8]] = 1'b0; // / making valid bit 0; It also symbolises that the register is renamed and the value has to be fetched from taken corresponding to ROB
                                            run.tail = run.tail + 2'b01;

                                             if((run.res2_sr1_refrence[k] == 1'b1 && run.res2_sr2_refrence[k] == 1'b1)&& (run.res2_free_entry[k] == 1'b0)) // if both operands are available make it ready
                                                  begin
                                                    run.res2_ready[k] = 1'b1;
                                                    //$display("This entry is ready");
                                                  end
                                             else
                                                  run.res2_ready[k] = 1'b0;
                                            $display("         9.Ready : %h ",run.res2_ready[k]);
                                           run.res2_issued[k] = 1'b0; // since this entry is not issued yet;
                                           $display("         10.Issued : %h \n",run.res1_issued[k]);

                                         // incrementing head pointer in instruction_queue and dercrementing no. of enteries in instruction_queue
                                          run.instruction_queue_head = run.instruction_queue_head + 2'b01;
                                          run.instruction_queue_no_of_enteries = run.instruction_queue_no_of_enteries - 1;

                               end
                           else
                                 $display("        Stall , RS2 : Full\n");
                         end
                          default: $display("        Unvalid Opcode %h\n",run.instruction_queue[run.instruction_queue_head][15:12]);
                      endcase
                  end
          else
             begin
                if(run.instruction_queue_no_of_enteries == 0)
                      $display("        Stall , IQ : Empty\n");
               else
                 $display("         Stall , ROB : Full\n");
             end

end
endmodule
