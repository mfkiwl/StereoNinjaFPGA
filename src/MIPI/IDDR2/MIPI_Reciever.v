module MIPI_Reciever
#(parameter
	mipi_frec=456,
	iddr_ratio=4
		)
(input sys_clk,reset,lane0_d,mipi_clk,mipi_clk_8,lane1_d,inout lane0_p,lane0_n,lane1_p,lane1_n,output[31:0] data_o,output[31:0] adress_out,
										output ram_clk,output reg debug0,debug1,debug3,debug2,output termination,rec_data_o,output[31:0] cX,cY);
    
	wire stop_clk, rec_data;
	wire[7:0] lane0byte,lane1byte;	 	
    SoTFSM #(.mipi_frec(mipi_frec)) RxFSM (.rec_data(rec_data),.clk100MHz(sys_clk),.reset(reset),.lane0_p(lane0_p),.lane0_n(lane0_n),.lane1_p(lane1_p),.lane1_n(lane1_n),.stop_rx(stop_clk),.term(termination),.debug0(debug0));
	wire[3:0]q_o_0,q_o_1;
	wire[1:0] ov_fl_0,ov_fl_1;
	wire even,sync;
	//assign debug1=even;
	wire sync_mipi_clk,sync_mipi_clk_2,sync_mipi_clk_4,sync_mipi_clk_8;
	//assign debug2=termination_r;


	ECLKSYNCB SYNC(.ECLKI(mipi_clk),.STOP(stop_clk),.ECLKO(sync_mipi_clk));	
	CLKDIVF div2 (.CLKI(sync_mipi_clk),.RST(reset),.CDIVX(sync_mipi_clk_2));
	CLKDIVF div4 (.CLKI(sync_mipi_clk_2),.RST(reset),.CDIVX(sync_mipi_clk_4));
	CLKDIVF div8 (.CLKI(sync_mipi_clk_4),.RST(reset),.CDIVX(sync_mipi_clk_8));

	/*wire mipi_clk_2,mipi_clk_4,mipi_clk_8;
	CLKDIVF div21 (.CLKI(mipi_clk),.RST(reset),.CDIVX(mipi_clk_2));
	CLKDIVF div41 (.CLKI(mipi_clk_2),.RST(reset),.CDIVX(mipi_clk_4));
	CLKDIVF div81 (.CLKI(mipi_clk_4),.RST(reset),.CDIVX(mipi_clk_8));
	*/
	


    IDDR2 lane0 (.lane(lane0_d),.sync_mipi_clk(sync_mipi_clk),.sync_mipi_clk_2(sync_mipi_clk_2),.reset(reset),.stop(stop_clk),.even(even),.sync(sync),.q_o(q_o_0),.ov_fl(ov_fl_0));
	IDDR2 lane1 (.lane(lane1_d),.sync_mipi_clk(sync_mipi_clk),.sync_mipi_clk_2(sync_mipi_clk_2),.reset(reset),.stop(stop_clk),/*.even(even),.sync(sync),*/.q_o(q_o_1),.ov_fl(ov_fl_1));
	
	wire[7:0] byte_e_0,byte_ue_0,byte_e_1,byte_ue_1;
	Byte_Arrange BA0 (.reset(reset),.stop(stop_clk),.mipi_clk_2(sync_mipi_clk_2),.q_o(q_o_0),.ov_fl(ov_fl_0),.byte_e(byte_e_0),.byte_ue(byte_ue_0));
	Byte_Arrange BA1 (.reset(reset),.stop(stop_clk),.mipi_clk_2(sync_mipi_clk_2),.q_o(q_o_1),.ov_fl(ov_fl_1),.byte_e(byte_e_1),.byte_ue(byte_ue_1));
	
	
	wire[7:0] byte_o_0,byte_o_1;
	Byte_Alligner BAL0(.reset(reset),.stop(stop_clk),.mipi_clk_2(sync_mipi_clk_2),.sync(sync),.even(even),.byte_e(byte_e_0),.byte_ue(byte_ue_0),.byte_o(byte_o_0));
	Byte_Alligner BAL1(.reset(reset),.stop(stop_clk),.mipi_clk_2(sync_mipi_clk_2),.sync(sync),.even(even),.byte_e(byte_e_1),.byte_ue(byte_ue_1),.byte_o(byte_o_1));	
	

	wire [31:0] data;
	wire valid;
	wire[5:0] type_w;
	wire[15:0] wordcount;
	DATA_Encoder DE (.even(even),.mipi_clk_4(sync_mipi_clk_4),.reset(reset),.stop(stop_clk),.sync(sync),.byte_in0(byte_o_0),.data(data),.type_o(type_w),.wordcount(wordcount),.byte_in1(byte_o_1),.valid(valid));
	
	
	Protocoll Prot (.debug(debug2),.debug1(debug3),.mipi_clk_8(sync_mipi_clk_8),.stop(stop_clk),.reset(reset),.valid(valid),.type_i(type_w),.wordcount(wordcount),.data_o(data_o),.data(data),.rec_data(rec_data),.adress_o(adress_out),.cX(cX),.cY(cY));
	assign rec_data_o=rec_data;
	assign debug1=rec_data;
	//assign debug2=rec_data;
	//assign debug3=stop_clk;
	assign ram_clk=sync_mipi_clk_8;
endmodule

module IDDR2 (input lane,sync_mipi_clk,sync_mipi_clk_2,input reset,stop,output[3:0] q_o,output[1:0] ov_fl,output even,output sync);
	wire[3:0] ddr;
	reg sync_r,even_r;
	reg[3:0] q_o_r;
	reg[1:0] ov_fl_r;
	reg[1:0] ov_fl_r1;
	reg[7:0] syncbyte=0;
	assign sync=sync_r&(!stop);
	assign even=even_r;
	assign ov_fl=ov_fl_r;
	assign q_o=q_o_r;	
	wire[7:0] detect_e,detect_ue;	
	assign detect_e=syncbyte^8'b10111000;
	assign detect_ue=((8'b00111111)&syncbyte)^8'b00101110;
	wire delay_lane;	
	//DELAYG#(.DEL_MODE("ECLK_CENTERED")) delay(.A(lane),.Z(delay_lane));
	IDDRX2F IDDR (.D(lane),.ECLK(sync_mipi_clk),.SCLK(sync_mipi_clk_2),.RST(reset||stop),.Q0(ddr[0]),.Q1(ddr[1]),.Q2(ddr[2]),.Q3(ddr[3]));	
	always @(posedge sync_mipi_clk_2) begin
		if(reset||stop)begin
			sync_r<=0;
			even_r<=0;
			ov_fl_r<=0;						
			q_o_r<=0;
			syncbyte=0;
		end else begin				
			syncbyte={ddr,syncbyte[7:4]};			
			sync_r<=(detect_e==0||detect_ue==0)?1:sync_r;
			if(detect_e==0&&sync_r==0)begin
				even_r<=1;
			end
			if (detect_ue==0&&sync_r==0) begin
				even_r<=0;
			end
			q_o_r<=ddr;
			ov_fl_r<=q_o_r[3:2];			
		end
	end
endmodule







module Byte_Arrange(input reset,stop,mipi_clk_2,input[3:0] q_o,input[1:0] ov_fl,output[7:0] byte_e,output[7:0]byte_ue);
	reg[7:0] byte0_r,byte1_r;
	assign byte_e=byte0_r;
	assign byte_ue=byte1_r;	
	always @(posedge mipi_clk_2) begin
		if(reset||stop)begin
			byte0_r<=0;
			byte1_r<=0;
		end else begin				
			byte0_r<={q_o,byte0_r[7:4]};
			byte1_r<={q_o[1:0],ov_fl,byte1_r[7:4]};		
		end
end
endmodule

module Byte_Alligner(input reset,stop,mipi_clk_2,sync,even,input[7:0] byte_e,input[7:0] byte_ue,output[7:0] byte_o);
	reg[7:0] byte_o_r;
	assign byte_o=byte_o_r;	//////////////////////////SYNC
	reg[7:0]counter;
	reg[7:0] byte_o_r_old;
	reg[15:0] byte_o_r_s;
	wire[7:0] byte_o_eu;
	assign byte_o_eu=(even)?byte_e:byte_ue;
	always @(posedge mipi_clk_2) begin
		if(reset||stop)begin
			byte_o_r<=0;
			byte_o_r_old<=8'b10111000;			
			counter<=0;		
			byte_o_r_s<=0;	
		end else begin			
			if(sync)begin
				counter<=(counter>=1)?0:counter+1;				
				//byte_o_r_s<={byte_o_eu[3:0],byte_o_r_s[15:4]};
				`ifdef VERILATOR
					byte_o_r<=(counter[0]==1)?byte_o_eu:byte_o_r;///////////////////////change to ==0 for real worls!!!!!!!!!!!!!!!!!!!!!!!!
				`else	
					byte_o_r<=(counter[0]==0)?byte_o_eu:byte_o_r;///////////////////////change to ==0 for real worls!!!!!!!!!!!!!!!!!!!!!!!!
				`endif 
				//byte_o_r<=(counter[0]==0)?byte_o_eu:byte_o_r;///////////////////////change to ==0 for real worls!!!!!!!!!!!!!!!!!!!!!!!!
				//byte_o_r<=(byte_o_r_s[7:0]==byte_o_r_old)?byte_o_eu:byte_o_r;///////////////////////sync funktion
				//byte_o_r_old<=(byte_o_r_s[7:0]==byte_o_r_old)?byte_o_r_s[15:8]:byte_o_r_old;///////////////////////sync funktion
				//byte_o_r<=byte_o_eu;				
			end
		end
	end
endmodule


module DATA_Encoder(input mipi_clk_4,reset,stop,even,sync,input[7:0] byte_in0,byte_in1,output[31:0]data,output valid,output[5:0] type_o,output[15:0] wordcount);
	reg[31:0] out_r,out_r_old;
	reg valid_r,start;
	assign valid=valid_r&&(!stop);	
	reg[31:0] counter;
	wire[31:0] regheader;
	assign regheader=out_r;
	wire[7:0] ecc;
	reg [31:0] data_r;
	reg[5:0] type_o_r;
	reg[15:0] wordcount_r;
	assign data=data_r;
	assign type_o=type_o_r;
	assign wordcount=wordcount_r;
	assign ecc[0]=regheader[0]^regheader[1]^regheader[2]^regheader[4]^regheader[5]^regheader[7]^regheader[10]^regheader[11]^regheader[13]^regheader[16]^
		regheader[20]^regheader[21]^regheader[22]^regheader[23];
	assign ecc[1]=regheader[0]^regheader[1]^regheader[3]^regheader[4]^regheader[6]^regheader[8]^regheader[10]^regheader[12]^regheader[14]^regheader[17]^
		regheader[20]^regheader[21]^regheader[22]^regheader[23];
	assign ecc[2]=regheader[0]^regheader[2]^regheader[3]^regheader[5]^regheader[6]^regheader[9]^regheader[11]^regheader[12]^regheader[15]^regheader[18]^
		regheader[20]^regheader[21]^regheader[22];
	assign ecc[3]=regheader[1]^regheader[2]^regheader[3]^regheader[7]^regheader[8]^regheader[9]^regheader[13]^regheader[14]^regheader[15]^regheader[19]^
		regheader[20]^regheader[21]^regheader[23];
	assign ecc[4]=regheader[4]^regheader[5]^regheader[6]^regheader[7]^regheader[8]^regheader[9]^regheader[16]^regheader[17]^regheader[18]^regheader[19]^
		regheader[20]^regheader[22]^regheader[23];
	assign ecc[5]=regheader[10]^regheader[11]^regheader[12]^regheader[13]^regheader[14]^regheader[15]^regheader[16]^regheader[17]^regheader[18]^regheader[19]^
		regheader[21]^regheader[22]^regheader[23];	
	assign ecc[6]=0;
	assign ecc[7]=0;
	wire[7:0] syndrom;
	assign syndrom=ecc^regheader[31:24];
	
	wire[23:0] correction;
	wire[31:0] regheader_correct;

	assign correction[0]=syndrom==8'h07;
	assign correction[1]=syndrom==8'h0B;
	assign correction[2]=syndrom==8'h0D;
	assign correction[3]=syndrom==8'h0E;
	assign correction[4]=syndrom==8'h13;
	assign correction[5]=syndrom==8'h15;
	assign correction[4]=syndrom==8'h16;
	assign correction[7]=syndrom==8'h19;
	assign correction[8]=syndrom==8'h1A;
	assign correction[9]=syndrom==8'h1C;
	assign correction[10]=syndrom==8'h23;
	assign correction[11]=syndrom==8'h25;
	assign correction[12]=syndrom==8'h26;
	assign correction[13]=syndrom==8'h29;
	assign correction[14]=syndrom==8'h2A;
	assign correction[15]=syndrom==8'h2C;
	assign correction[16]=syndrom==8'h31;
	assign correction[17]=syndrom==8'h32;
	assign correction[18]=syndrom==8'h34;
	assign correction[19]=syndrom==8'h38;
	assign correction[20]=syndrom==8'h1F;
	assign correction[21]=syndrom==8'h2F;
	assign correction[22]=syndrom==8'h37;
	assign correction[23]=syndrom==8'h3B;
	
	assign regheader_correct=regheader^ {8'h00,correction};


	always @(posedge mipi_clk_4) begin
		if(reset||stop)begin
			out_r<=0;
			out_r_old<=0;
			valid_r<=0;		
			start=0;
			counter<=0;
			data_r<=0;
			type_o_r<=0;
			wordcount_r<=0;
		end else begin			
			if(sync)begin
				out_r_old<=out_r;
				out_r<={byte_in1,byte_in0,out_r[31:16]};
				valid_r<=(ecc==regheader_correct[31:24]&&regheader_correct!=0)?1:valid_r;
				start=(ecc==regheader_correct[31:24]&&regheader_correct!=0)?1:start;
				type_o_r<=(ecc==regheader_correct[31:24]&&regheader_correct!=0)?regheader_correct[5:0]:type_o_r;
				wordcount_r<=(ecc==regheader_correct[31:24]&&regheader_correct!=0)?regheader_correct[23:8]:wordcount_r;				
				if(start)begin
					counter<=counter+1;
					if(counter[0]==0&&counter[1]==1)begin
						counter<=1;						
						data_r<=out_r;
					end else begin
						counter<=counter+1;
					end
				end	
			end
		end
	end
endmodule


module SoTFSM
	#(parameter
		mipi_frec=350
	 )
	 (input clk100MHz,reset,rec_data,lane0_p,lane0_n,lane1_p,lane1_n,stop_tran,
	output stop_rx,term,debug0,debug1);
	///////////////////States for long and short Packet Recieve
	localparam reg[7:0] TIMEOUT=0;
	localparam reg[7:0] LP11=1;
	localparam reg[7:0] LP01=2;
	localparam reg[7:0] LP00=3;
	localparam reg[7:0] SYNC=4;
	localparam reg[7:0] HEADER=5;
	localparam reg[7:0] DATA=6;	
	///////////////////Const for Timing 
	localparam integer Tlpx=2;//50ns -> nearest =40ns
	localparam[31:0]  Timeout=(2700*50/mipi_frec);//time for one Line*1,5
	localparam  Tdterm=(2*50/mipi_frec);
	localparam  Thssettle=1+(3*50/mipi_frec);
	///////////////////
	reg[7:0] state_mipi=TIMEOUT;	
	reg stop_rx_r,term_r,debug0_r,debug1_r;
	assign stop_rx=stop_rx_r;
	assign term=term_r;
	assign debug0=debug0_r;
	assign debug1=debug1_r;	

	integer timer_tou,timer_term,timer_hs;	
	///////////////////////////////////////////////FSM
	always @(posedge clk100MHz) begin
		if(reset==1) begin
			state_mipi<=TIMEOUT;
			timer_tou<=0;
			timer_term<=0;
			timer_hs<=0;			
			term_r<=0;
			stop_rx_r<=1;
		end else begin
			case (state_mipi)
				TIMEOUT: begin
					state_mipi<=(lane0_p==1 && lane0_n==1 &&lane1_p==1 &&lane1_n==1)?LP11:TIMEOUT; 				
					timer_tou<=0;
					timer_term<=0;
					timer_hs<=0;			
					term_r<=0;
					debug0_r<=0;
					stop_rx_r<=1;	
				end
				LP11:begin					
					state_mipi<=(lane0_p==0 && lane0_n==1 &&lane1_p==0 &&lane1_n==1)?LP01:LP11;	
					debug0_r<=0;
					stop_rx_r<=1;	
				end
				LP01:begin
					if(timer_tou>=Timeout) begin
						state_mipi<=TIMEOUT;
					end else begin
						if(lane0_p==0 && lane0_n==0 &&lane1_p==0 &&lane1_n==0)begin
							state_mipi<=LP00;
							timer_tou<=0;
							timer_hs<=0;					 
						end					
					end						
					timer_tou<=timer_tou+1;
					timer_term<=timer_term+1;	
					stop_rx_r<=1;			
				end
				LP00:begin
					stop_rx_r<=1;	
					if(timer_term>=Tdterm) begin					
						term_r<=1;					
					end 
					if(timer_hs>=Thssettle) begin
						state_mipi<=SYNC;
						timer_tou<=0;	
						stop_rx_r<=0;
					end
					if(timer_tou>=Timeout)begin
						state_mipi<=TIMEOUT;
					end
					timer_tou<=timer_tou+1;
					timer_term<=timer_term+1;
					timer_hs<=timer_hs+1;					
				end
				SYNC:begin		
					debug0_r<=1;
					if(timer_tou>=Timeout)begin
						state_mipi<=TIMEOUT;
						stop_rx_r<=1;					
					end				
					timer_tou<=timer_tou+1;
					if(rec_data==1)begin
						state_mipi<=HEADER;
						timer_tou<=0;
					end				
				end	
				HEADER:begin					
					timer_tou<=timer_tou+1;
					if(rec_data==0||timer_tou>Timeout)begin
						state_mipi<=TIMEOUT;
						term_r<=0;
						//stop_rx_r<=1;	
					end	
				end		
				default: begin
				end
			endcase		
		end	   
	end
endmodule

module Protocoll(input mipi_clk_8,stop,reset,valid,input[5:0] type_i,input[15:0] wordcount,input[31:0] data,output[31:0] data_o,output[31:0]adress_o,output rec_data,output reg debug,output reg debug1,output[31:0] cX,cY);
	reg rec_data_r,state,valid_old;
	reg[31:0] counter,count_val,data_o_r,counter_addr,cX_r,cY_r;
	assign data_o=data_o_r;
	assign rec_data=rec_data_r&&(!stop);	
	assign adress_o=counter_addr;
	assign cX=cX_r;
	assign cY=cY_r;
	reg[15:0] c='hffff;//crc code
	wire[15:0] c_calk;
	wire[31:0] d;//recieved data
	assign d=data;
	////////////////////////////////////////////////////////CRC Sum
	assign c_calk[0]=d[21]^d[10]^c [10]^d[28]^d[6]^c [6]^d[24]^d[13]^c [13]^d[20]^d[5]^c [5]^d[12]^c [12]^d[4]^c [4]^d[0]^c [0];
	assign c_calk[1]=d[22]^d[11]^c [11]^d[0]^c [0]^d[29]^d[7]^c [7]^d[25]^d[14]^c[14]^d[21]^d[6]^c [6]^d[13]^c [13]^d[5]^c [5]^d[1]^c [1];
	assign c_calk[2]=d[23]^d[12]^c [12]^d[1]^c [1]^d[30]^d[8]^c [8]^d[26]^d[15]^c [15]^d[22]^d[7]^c [7]^d[14]^c [14]^d[6]^c [6]^d[2]^c [2];
	assign c_calk[3]=d[24]^d[13]^c [13]^d[2]^c [2]^d[31]^d[9]^c [9]^d[27]^d[16]^d[23]^d[8]^c [8]^d[15]^c [15]^d[0]^c [0]^d[7]^c [7]^d[3]^c [3];
	assign c_calk[4]=d[20]^d[16]^d[12]^c [12]^d[8]^c [8]^d[0]^c [0]^d[25]^d[14]^c [14]^d[3]^c [3]^d[21]^d[17]^d[6]^c [6]^d[13]^c [13]^d[9]^c [9]^d[5]^c [5]^d[1]^c [1];
	assign c_calk[5]=d[21]^d[17]^d[13]^c [13]^d[9]^c [9]^d[1]^c [1]^d[26]^d[15]^c [15]^d[4]^c [4]^d[22]^d[0]^c [0]^d[18]^d[7]^c [7]^d[14]^c [14]^d[10]^c [10]^d[6]^c [6]^d[2]^c [2];
	assign c_calk[6]=d[22]^d[18]^d[14]^c [14]^d[10]^c [10]^d[2]^c [2]^d[27]^d[16]^d[5]^c [5]^d[23]^d[1]^c [1]^d[19]^d[8]^c [8]^d[15]^c [15]^d[11]^c [11]^d[7]^c [7]^d[3]^c [3];
	assign c_calk[7]=d[23]^d[19]^d[15]^c [15]^d[11]^c [11]^d[3]^c [3]^d[28]^d[17]^d[6]^c [6]^d[24]^d[2]^c [2]^d[20]^d[9]^c [9]^d[16]^d[12]^c [12]^d[8]^c [8]^d[4]^c [4]^d[0]^c [0];
	assign c_calk[8]=d[24]^d[20]^d[16]^d[12]^c [12]^d[4]^c [4]^d[29]^d[18]^d[7]^c [7]^d[25]^d[3]^c [3]^d[21]^d[10]^c [10]^d[17]^d[13]^c [13]^d[9]^c [9]^d[5]^c [5]^d[1]^c [1];
	assign c_calk[9]=d[25]^d[21]^d[17]^d[13]^c [13]^d[5]^c [5]^d[30]^d[19]^d[8]^c [8]^d[26]^d[4]^c [4]^d[22]^d[11]^c [11]^d[18]^d[14]^c [14]^d[10]^c [10]^d[6]^c [6]^d[2]^c [2];
	assign c_calk[10]=d[26]^d[22]^d[18]^d[14]^c [14]^d[6]^c [6]^d[31]^d[20]^d[9]^c [9]^d[27]^d[5]^c [5]^d[23]^d[12]^c [12]^d[19]^d[15]^c [15]^d[11]^c [11]^d[0]^c [0]^d[7]^c [7]^d[3]^c [3];
	assign c_calk[11]=d[27]^d[16]^d[5]^c [5]^d[23]^d[1]^c [1]^d[19]^d[8]^c [8]^d[15]^c [15]^d[0]^c [0]^d[7]^c [7];
	assign c_calk[12]=d[28]^d[17]^d[6]^c [6]^d[24]^d[2]^c [2]^d[20]^d[9]^c [9]^d[16]^d[1]^c [1]^d[8]^c [8]^d[0]^c [0];
	assign c_calk[13]=d[29]^d[18]^d[7]^c [7]^d[25]^d[3]^c [3]^d[21]^d[10]^c [10]^d[17]^d[2]^c [2]^d[9]^c [9]^d[1]^c [1];
	assign c_calk[14]=d[30]^d[19]^d[8]^c [8]^d[26]^d[4]^c [4]^d[22]^d[11]^c [11]^d[18]^d[3]^c [3]^d[10]^c [10]^d[2]^c [2];
	assign c_calk[15]=d[31]^d[20]^d[9]^c [9]^d[27]^d[5]^c [5]^d[23]^d[12]^c [12]^d[19]^d[4]^c [4]^d[11]^c [11]^d[3]^c [3];			
	//////////////////////////////////////////////
	always @(posedge mipi_clk_8) begin
		if(reset)begin
			rec_data_r<=0;
			state<=0;
			data_o_r<=0;
			counter_addr<=0;
			valid_old<=0;
			cX_r<=0;
			cY_r<=0;
			debug<=0;
			//counter<=0;
			//count_val<=0;			
		end	else begin
			valid_old<=valid;			
			case (state)
				0:begin
					c<='hffff;	
					if(((valid==1&&valid_old==0)&&(type_i=='h00||type_i=='h01))||counter_addr>76799)begin
						counter_addr<=0;								
						cX_r<=0;
						cY_r<=0;	
						debug<=1;					
					end		
					if((valid==1&&valid_old==0)&&type_i=='h2a&&wordcount=='h0280)begin
						state<=1;
						count_val<=160;
						cY_r<=cY_r+640;
						cX_r<=0;
						debug<=0;
						debug1<=0;											
					end														
				end 
				1:begin						
					if(counter<count_val)begin
						cX_r<=cX_r+1;
						counter<=counter+1;
						rec_data_r<=1;						
						counter_addr<=counter_addr+1;
						data_o_r<=data;
						c<=c_calk;						
					end else begin
						rec_data_r<=0;
						state<=0;
						counter<=0;
						if(c==data[15:0])begin
							debug1<=1;
						end							
					end
				end
				default:begin					
				end 
			endcase
		end
	end
endmodule
