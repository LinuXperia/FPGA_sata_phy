`timescale 1ns / 1ps
`include "E:\bishe\physata\ipcore_dir\gtxsata.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:42:25 03/28/2015 
// Design Name: 
// Module Name:    PHY_SATA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module physata(
	TILE0_RXN0_IN,
	TILE0_RXP0_IN,
	TILE0_TXN0_OUT,
	TILE0_TXP0_OUT,
	
	CLKIN_IN,
	PHYRESET,
	PHYRDY,
	
	TILE0_RXDATA0_OUT,
	TILE0_RXDISPERR0_OUT,
	TILE0_RXNOTINTABLE0_OUT,
	TILE0_RXBYTEISALIGNED0_OUT,
	
	TILE0_TXCHARISK0_IN,
	TILE0_TXDATA0_IN
    );
	 
input TILE0_RXN0_IN,TILE0_RXP0_IN;
output TILE0_TXN0_OUT,TILE0_TXP0_OUT;
input CLKIN_IN;
input PHYRESET;
output PHYRDY;
output[7:0] TILE0_RXDATA0_OUT;
output TILE0_RXDISPERR0_OUT;
output TILE0_RXNOTINTABLE0_OUT;
output TILE0_RXBYTEISALIGNED0_OUT;
input TILE0_TXCHARISK0_IN;
input[7:0] TILE0_TXDATA0_IN;

reg txcharisk,txcharisk_buf;
reg[7:0] txdata,txdata_buf;
reg phyrdy_flag;
	
wire TILE0_RXDISPERR1_OUT;
wire TILE0_RXNOTINTABLE1_OUT;
wire TILE0_BYTEISALIGNED1_OUT;
wire[7:0] TILE0_RXDATA1_OUT;
wire TILE0_RXELECIDLE0_OUT,TILE0_RXELECIDLE1_OUT;
reg TILE0_RXN1_IN,TILE0_RXP1_IN;
wire[2:0] TILE0_RXSTATUS0_OUT,TILE0_RXSTATUS1_OUT;
reg TILE0_GTXRESET_IN;
wire TILE0_PLLLKDET_OUT;
wire TILE0_RESETDONE0_OUT,TILE0_RESETDONE1_OUT;
wire TILE0_TXCHARISK1_IN;
reg[7:0] TILE0_TXDATA1_IN;
wire TILE0_TXN1_OUT,TILE0_TXP1_OUT;
reg TILE0_TXCOMSTART0_IN,TILE0_TXCOMSTART1_IN;
reg TILE0_TXCOMTYPE0_IN,TILE0_TXCOMTYPE1_IN;
wire TILE0_REFCLKOUT_OUT;

reg DCM_RST_IN;
wire DCM_CLKIN_IBUFG_OUT;
wire DCM_CLK0_OUT;
wire DCM_CLK2X_OUT;
wire DCM_LOCKED_OUT;

reg reset_start,reset_ok;
reg[5:0] reset_state;
reg[10:0] DCM_reset_cnt,GTX_reset_cnt;
reg[31:0] AwaitCOMINIT_Retry_cnt,AwaitCOMWAKE_Retry_cnt,AwaitAlign_3_Retry_cnt;
reg AwaitCOMINIT_elapsed_flag,AwaitCOMWAKE_elapsed_flag,AwaitAlign_3_elapsed_flag;
reg[18:0] HR_state;

reg[3:0] transmit_COM_state;
reg transmit_COM_ok;
reg[1:0] transmit_D10_2_state;
reg transmit_D10_2_ok;
reg[4:0] receive_Alignp_state;
reg receive_Alignp_ok;
reg[4:0] transmit_Alignp_state;
reg transmit_Alignp_ok;
reg[4:0] receive_nonAlignp_state;
reg receive_nonAlignp_ok;
reg[2:0] receive_nonAlignp_cnt;


	assign PHYRDY = phyrdy_flag;

	dcm dcm1(
		.CLKIN_IN(CLKIN_IN), 
		.RST_IN(DCM_RST_IN), 
		.CLKIN_IBUFG_OUT(DCM_CLKIN_IBUFG_OUT), 
		.CLK0_OUT(DCM_CLK0_OUT), 
		.CLK2X_OUT(DCM_CLK2X_OUT), 
		.LOCKED_OUT(DCM_LOCKED_OUT)
		);


    GTXSATA #
    (
        .WRAPPER_SIM_GTXRESET_SPEEDUP   (1),      // Set this to 1 for simulation
        .WRAPPER_SIM_PLL_PERDIV2        (9'h14d)
    )
    gtxsata_i
    (
    
        //_____________________________________________________________________
        //_____________________________________________________________________
        //TILE0  (X0Y0)

        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .TILE0_RXDISPERR0_OUT           (TILE0_RXDISPERR0_OUT),
        .TILE0_RXDISPERR1_OUT           (TILE0_RXDISPERR1_OUT),
        .TILE0_RXNOTINTABLE0_OUT        (TILE0_RXNOTINTABLE0_OUT),
        .TILE0_RXNOTINTABLE1_OUT        (TILE0_RXNOTINTABLE1_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .TILE0_RXBYTEISALIGNED0_OUT     (TILE0_RXBYTEISALIGNED0_OUT),
        .TILE0_RXBYTEISALIGNED1_OUT     (TILE0_RXBYTEISALIGNED1_OUT),
        .TILE0_RXENMCOMMAALIGN0_IN      (0),
        .TILE0_RXENMCOMMAALIGN1_IN      (0),
        .TILE0_RXENPCOMMAALIGN0_IN      (1),
        .TILE0_RXENPCOMMAALIGN1_IN      (1),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .TILE0_RXDATA0_OUT              (TILE0_RXDATA0_OUT),
        .TILE0_RXDATA1_OUT              (TILE0_RXDATA1_OUT),
        .TILE0_RXUSRCLK0_IN             (DCM_CLK0_OUT),
        .TILE0_RXUSRCLK1_IN             (DCM_CLK0_OUT),
        .TILE0_RXUSRCLK20_IN            (DCM_CLK2X_OUT),
        .TILE0_RXUSRCLK21_IN            (DCM_CLK2X_OUT),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .TILE0_RXELECIDLE0_OUT          (TILE0_RXELECIDLE0_OUT),
        .TILE0_RXELECIDLE1_OUT          (TILE0_RXELECIDLE1_OUT),
        .TILE0_RXN0_IN                  (TILE0_RXN0_IN),
        .TILE0_RXN1_IN                  (TILE0_RXN1_IN),
        .TILE0_RXP0_IN                  (TILE0_RXP0_IN),
        .TILE0_RXP1_IN                  (TILE0_RXP1_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .TILE0_RXSTATUS0_OUT            (TILE0_RXSTATUS0_OUT),
        .TILE0_RXSTATUS1_OUT            (TILE0_RXSTATUS1_OUT),
        //------------------- Shared Ports - Tile and PLL Ports --------------------
        .TILE0_CLKIN_IN                 (DCM_CLK0_OUT),
        .TILE0_GTXRESET_IN              (TILE0_GTXRESET_IN),
        .TILE0_PLLLKDET_OUT             (TILE0_PLLLKDET_OUT),
        .TILE0_REFCLKOUT_OUT            (TILE0_REFCLKOUT_OUT),
        .TILE0_RESETDONE0_OUT           (TILE0_RESETDONE0_OUT),
        .TILE0_RESETDONE1_OUT           (TILE0_RESETDONE1_OUT),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TILE0_TXCHARISK0_IN            (txcharisk),
        .TILE0_TXCHARISK1_IN            (TILE0_TXCHARISK1_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TILE0_TXDATA0_IN               (txdata),
        .TILE0_TXDATA1_IN               (TILE0_TXDATA1_IN),
        .TILE0_TXUSRCLK0_IN             (DCM_CLK0_OUT),
        .TILE0_TXUSRCLK1_IN             (DCM_CLK0_OUT),
        .TILE0_TXUSRCLK20_IN            (DCM_CLK2X_OUT),
        .TILE0_TXUSRCLK21_IN            (DCM_CLK2X_OUT),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TILE0_TXN0_OUT                 (TILE0_TXN0_OUT),
        .TILE0_TXN1_OUT                 (TILE0_TXN1_OUT),
        .TILE0_TXP0_OUT                 (TILE0_TXP0_OUT),
        .TILE0_TXP1_OUT                 (TILE0_TXP1_OUT),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .TILE0_TXCOMSTART0_IN           (TILE0_TXCOMSTART0_IN),
        .TILE0_TXCOMSTART1_IN           (TILE0_TXCOMSTART1_IN),
        .TILE0_TXCOMTYPE0_IN            (TILE0_TXCOMTYPE0_IN),
        .TILE0_TXCOMTYPE1_IN            (TILE0_TXCOMTYPE1_IN)


    );
    



	parameter RESET_IDLE        = 6'b00_0001,
				 RESET_DCM_1       = 6'b00_0010,
			    RESET_DCM_2       = 6'b00_0100,
			    RESET_GTX_1       = 6'b00_1000,
			    RESET_GTX_2       = 6'b01_0000,
			    RESET_FINISHED    = 6'b10_0000;
	 
	parameter DCM_RESET_TIME = 10,
				 GTX_RESET_TIME = 10;
	
	parameter HR_IDLE               = 19'b000_0000_0000_0000_0001,
				 HR_RESET_1            = 19'b000_0000_0000_0000_0010,
				 HR_RESET_2            = 19'b000_0000_0000_0000_0100,
				 HR_AwaitCOMINIT       = 19'b000_0000_0000_0000_1000,
				 HR_AwaitNoCOMINIT     = 19'b000_0000_0000_0001_0000,
				 HR_COMWAKE_1          = 19'b000_0000_0000_0010_0000,
				 HR_COMWAKE_2          = 19'b000_0000_0000_0100_0000,
				 HR_AwaitCOMWAKE       = 19'b000_0000_0000_1000_0000,
				 HR_AwaitNoCOMWAKE     = 19'b000_0000_0001_0000_0000,
				 HR_AwaitAlign_1       = 19'b000_0000_0010_0000_0000,
				 HR_AwaitAlign_2       = 19'b000_0000_0100_0000_0000,
				 HR_AwaitAlign_3       = 19'b000_0000_1000_0000_0000,
				 HR_AdjustSpeed        = 19'b000_0001_0000_0000_0000,
				 HR_SendAlign_1        = 19'b000_0010_0000_0000_0000,
				 HR_SendAlign_2        = 19'b000_0100_0000_0000_0000,
				 HR_SendAlign_3        = 19'b000_1000_0000_0000_0000,
				 HR_SendAlign_4        = 19'b001_0000_0000_0000_0000,
				 HR_Ready              = 19'b010_0000_0000_0000_0000,
				 HR_Work			   	  = 19'b100_0000_0000_0000_0000;
				 
	parameter COMRESET  = 0,
				 COMINIT   = 0,
				 COMWAKE   = 1;
				 
	parameter TRANSMIT_COM_1 = 4'b0001,
				 TRANSMIT_COM_2 = 4'b0010,
				 TRANSMIT_COM_3 = 4'b0100,
				 TRANSMIT_COM_4 = 4'b1000;
				 
	parameter TRANSMIT_Alignp_1 = 5'b0_0001,
				 TRANSMIT_Alignp_2 = 5'b0_0010,
				 TRANSMIT_Alignp_3 = 5'b0_0100,
				 TRANSMIT_Alignp_4 = 5'b0_1000,
				 TRANSMIT_Alignp_5 = 5'b1_0000;
				 
	parameter TRANSMIT_D10_2_1 = 2'b01,
				 TRANSMIT_D10_2_2 = 2'b10;
				 
	parameter RECEIVE_Alignp_1 = 5'b0_0001,
				 RECEIVE_Alignp_2 = 5'b0_0010,
				 RECEIVE_Alignp_3 = 5'b0_0100,
				 RECEIVE_Alignp_4 = 5'b0_1000,
				 RECEIVE_Alignp_5 = 5'b1_0000;
				 
	parameter RECEIVE_NonAlignp_1 = 5'b0_0001,
				 RECEIVE_NonAlignp_2 = 5'b0_0010,
				 RECEIVE_NonAlignp_3 = 5'b0_0100,
				 RECEIVE_NonAlignp_4 = 5'b0_1000,
				 RECEIVE_NonAlignp_5 = 5'b1_0000;
				 
	parameter AwaitCOMINIT_RETRY_INTERVAL = 100,
				 AwaitCOMWAKE_RETRY_INTERVAL = 100,
				 AwaitAlign_3_RETRY_INTERVAL = 100;
	
	
	
	//reset start flag
	always@(posedge DCM_CLKIN_IBUFG_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			reset_start <= 1;
		end
		else
		begin
			reset_start <= 0;
		end	
	end
	
	
	//reset state machine
	always@(posedge DCM_CLKIN_IBUFG_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			reset_state <= RESET_IDLE;
		end
		else
		begin
			case(reset_state)
				RESET_IDLE:
				begin
					if(reset_start==1)
					begin
						reset_state<=RESET_DCM_1;
					end
					else
					begin
						reset_state<=RESET_IDLE;
					end
				end
				
				RESET_DCM_1:
				begin
					if(DCM_reset_cnt<DCM_RESET_TIME)
					begin
						reset_state<=RESET_DCM_1;
					end
					else
					begin
						reset_state<=RESET_DCM_2;
					end
				end
				
				RESET_DCM_2:
				begin
					if(DCM_LOCKED_OUT)
					begin
						reset_state<=RESET_GTX_1;
					end
					else
					begin
						reset_state<=RESET_DCM_2;
					end
				end
				
				RESET_GTX_1:
				begin
				if(GTX_reset_cnt<GTX_RESET_TIME)
					begin
						reset_state<=RESET_GTX_1;
					end
					else
					begin
						reset_state<=RESET_GTX_2;
					end
					
				end
				
				RESET_GTX_2:
				begin
					if(TILE0_RESETDONE0_OUT)
					begin
						reset_state<=RESET_FINISHED;
					end
					else
					begin
						reset_state<=RESET_GTX_2;
					end
				end
				
				RESET_FINISHED:
				begin
					reset_state<=RESET_FINISHED;
				end
				
				default:
					reset_state<=RESET_IDLE;
	
			endcase
		end
	end
	
	
	//reset ok flag
	always@(posedge DCM_CLKIN_IBUFG_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			reset_ok<=0;
		end
		else
		begin
			if(reset_state==RESET_FINISHED)
			begin
				reset_ok<=1;
			end
			else
			begin
				reset_ok<=0;
			end
		end
	end
	
	
	//reset time counter
	always@(posedge DCM_CLKIN_IBUFG_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			DCM_reset_cnt<=0;
			GTX_reset_cnt<=0;
		end
		else
		begin
			case(reset_state)
				RESET_IDLE:
				begin
					DCM_reset_cnt<=0;
					GTX_reset_cnt<=0;
				end
				
				RESET_DCM_1:
				begin
					DCM_reset_cnt<=DCM_reset_cnt+1;
				end
				
				RESET_DCM_2:
				begin
					//reset_cnt<=0;
				end
				
				RESET_GTX_1:
				begin
					GTX_reset_cnt<=GTX_reset_cnt+1;
				end
				
				RESET_GTX_2:
				begin
					//reset_cnt<=0;
				end
				
				RESET_FINISHED:
				begin
					//reset_cnt<=0;
				end
				
				default:
				begin
					DCM_reset_cnt<=0;
					GTX_reset_cnt<=0;
				end
				
			endcase
		end
	end
	
	
	//reset port control
	always@(posedge DCM_CLKIN_IBUFG_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			DCM_RST_IN<=0;
			TILE0_GTXRESET_IN<=0;
		end
		else
		begin
			case(reset_state)
				RESET_IDLE:
				begin
					DCM_RST_IN<=0;
					TILE0_GTXRESET_IN<=0;
				end
				
				RESET_DCM_1:
				begin
					DCM_RST_IN<=1;
				end	
				
				RESET_DCM_2:
				begin
					DCM_RST_IN<=0;
				end
				
				RESET_GTX_1:
				begin
					TILE0_GTXRESET_IN<=1;
				end
				
				RESET_GTX_2:
				begin
					TILE0_GTXRESET_IN<=0;
				end
				
				RESET_FINISHED:
				begin
					DCM_RST_IN<=0;
					TILE0_GTXRESET_IN<=0;
				end
				
				default:
				begin
					DCM_RST_IN<=0;
					TILE0_GTXRESET_IN<=0;
				end	
				
			endcase
		end
	end

	
	//data connection control
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			txcharisk<=txcharisk_buf;
			txdata<=txdata_buf;
		end
		else
		begin
			if(phyrdy_flag)
			begin
				txcharisk<=TILE0_TXCHARISK0_IN;
				txdata<=TILE0_TXDATA0_IN;
			end
			else
			begin
				txcharisk<=txcharisk_buf;
				txdata<=txdata_buf;
			end
		end
	end
	
	
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			AwaitCOMINIT_Retry_cnt<=0;
			AwaitCOMINIT_elapsed_flag<=0;
		end
		else
		begin
			if(HR_state==HR_AwaitCOMINIT)
			begin
				if(AwaitCOMINIT_Retry_cnt<AwaitCOMINIT_RETRY_INTERVAL)
				begin
					AwaitCOMINIT_Retry_cnt<=AwaitCOMINIT_Retry_cnt+1;
					AwaitCOMINIT_elapsed_flag<=0;
				end
				else
				begin
					AwaitCOMINIT_elapsed_flag<=1;
				end
			end
			else
			begin
				AwaitCOMINIT_Retry_cnt<=0;
				AwaitCOMINIT_elapsed_flag<=0;
			end
		end
	end
	
	
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			AwaitCOMWAKE_Retry_cnt<=0;
			AwaitCOMWAKE_elapsed_flag<=0;
		end
		else
		begin
			if(HR_state==HR_AwaitCOMWAKE)
			begin
				if(AwaitCOMWAKE_Retry_cnt<AwaitCOMWAKE_RETRY_INTERVAL)
				begin
					AwaitCOMWAKE_Retry_cnt<=AwaitCOMWAKE_Retry_cnt+1;
					AwaitCOMWAKE_elapsed_flag<=0;
				end
				else
				begin
					AwaitCOMWAKE_elapsed_flag<=1;
				end
			end
			else
			begin
				AwaitCOMWAKE_Retry_cnt<=0;
				AwaitCOMWAKE_elapsed_flag<=0;
			end
		end
	end
	
	
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			AwaitAlign_3_Retry_cnt<=0;
			AwaitAlign_3_elapsed_flag<=0;
		end
		else
		begin
			if(HR_state==HR_AwaitAlign_3)
			begin
				if(AwaitAlign_3_Retry_cnt<AwaitAlign_3_RETRY_INTERVAL)
				begin
					AwaitAlign_3_Retry_cnt<=AwaitAlign_3_Retry_cnt+1;
					AwaitAlign_3_elapsed_flag<=0;
				end
				else
				begin
					AwaitAlign_3_elapsed_flag<=1;
				end
			end
			else
			begin
				AwaitAlign_3_Retry_cnt<=0;
				AwaitAlign_3_elapsed_flag<=0;
			end
		end
	end
	
	
	//HR state machine
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			HR_state<=HR_IDLE;
		end
		else
		begin
			case(HR_state)
				HR_IDLE:
				begin
					if(reset_ok==1)
					begin
						HR_state<=HR_RESET_1;
					end
					else
					begin
						HR_state<=HR_IDLE;
					end
				end
				
				HR_RESET_1:
				begin
					HR_state<=HR_RESET_2;
				end
				
				HR_RESET_2:
				begin
					if(transmit_COM_ok==1)
					begin
						HR_state<=HR_AwaitCOMINIT;
					end
					else
					begin
						HR_state<=HR_RESET_2;
					end
				end
				
				HR_AwaitCOMINIT:
				begin
					//if(TILE0_RXSTATUS0_OUT[2]==1)
					if(1)
					begin
						HR_state<=HR_AwaitNoCOMINIT;
					end
					else if(AwaitCOMINIT_elapsed_flag == 0)
					begin
						HR_state<=HR_AwaitCOMINIT;
					end
					else
					begin
						HR_state<=HR_RESET_1;
					end
				end	
				
				HR_AwaitNoCOMINIT:
				begin
					//if(TILE0_RXSTATUS0_OUT[2]==0)
					if(1)
					begin
						HR_state<=HR_COMWAKE_1;
					end
					else
					begin
						HR_state<=HR_AwaitNoCOMINIT;
					end
				end
				
				HR_COMWAKE_1:
				begin
					HR_state<=HR_COMWAKE_2;
				end
				
				HR_COMWAKE_2:
				begin
					if(transmit_COM_ok==1)
					begin
						HR_state<=HR_AwaitCOMWAKE;
					end
					else
					begin
						HR_state<=HR_COMWAKE_2;
					end
				end
				
				HR_AwaitCOMWAKE:
				begin
					//if(TILE0_RXSTATUS0_OUT[1]==1)
					if(1)
					begin
						HR_state<=HR_AwaitNoCOMWAKE;
					end
					else if(AwaitCOMWAKE_elapsed_flag==0)
					begin
						HR_state<=HR_AwaitCOMWAKE;
					end
					else
					begin
						HR_state<=HR_RESET_1;
					end
				end
				
				HR_AwaitNoCOMWAKE:
				begin
					//if(TILE0_RXSTATUS0_OUT[1]==0)
					if(1)
					begin
						HR_state<=HR_AwaitAlign_1;
					end
					else
					begin
						HR_state<=HR_AwaitNoCOMWAKE;
					end
				end
				
				HR_AwaitAlign_1:
				begin
					HR_state<=HR_AwaitAlign_2;
				end
				
				HR_AwaitAlign_2:
				begin
					if(transmit_D10_2_ok==1)
					begin
						HR_state<=HR_AwaitAlign_3;
					end
					else
					begin
						HR_state<=HR_AwaitAlign_2;
					end
				end
				
				HR_AwaitAlign_3:
				begin
					if(receive_Alignp_ok==1)
					begin
						HR_state<=HR_AdjustSpeed;
					end
					else
					begin
						HR_state<=HR_AwaitAlign_3;
					end
				end
				
				HR_AdjustSpeed:
				begin
					HR_state<=HR_SendAlign_1;
				end	
				
				HR_SendAlign_1:
				begin
					HR_state<=HR_SendAlign_2;
				end
				
				HR_SendAlign_2:
				begin
					if(transmit_Alignp_ok==1)
					begin
						HR_state<=HR_SendAlign_3;
					end
					else
					begin
						HR_state<=HR_SendAlign_2;
					end
				end
				
				HR_SendAlign_3:
				begin
					if(receive_nonAlignp_ok==1)
					begin
						HR_state<=HR_SendAlign_4;
					end
					else if(AwaitAlign_3_elapsed_flag==0)
					begin
						HR_state<=HR_SendAlign_3;
					end
					else
					begin
						HR_state<=HR_RESET_1;
					end
				end
				
				HR_SendAlign_4:
				begin
					if(receive_nonAlignp_cnt<6)
					begin
						HR_state<=HR_SendAlign_3;
					end
					else
					begin
						HR_state<=HR_Ready;
					end
				end
				
				HR_Ready:
				begin
					HR_state<=HR_Work;
				end
				
				HR_Work:
				begin
					HR_state<=HR_Work;
				end
				
			endcase
		end
	end
	
	
	//transmit COMRESET and COMWAKE port control
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			transmit_COM_ok<=0;
			transmit_COM_state<=TRANSMIT_COM_1;
		end
		else
		begin
			case(HR_state)
				HR_RESET_1:
				begin
					transmit_COM_ok<=0;
					transmit_COM_state<=TRANSMIT_COM_1;
				end
				
				HR_RESET_2:
				begin
					transmit_COM(COMRESET);
				end
				
				HR_COMWAKE_1:
				begin
					transmit_COM_ok<=0;
					transmit_COM_state<=TRANSMIT_COM_1;
				end
				
				HR_COMWAKE_2:
				begin
					transmit_COM(COMWAKE);
				end
				
			endcase
		end
	end
	

	//transmit D10.2 and receive Alignp port control , transmit Alignp and receive non-Alignp port control
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			transmit_D10_2_ok<=0;
			transmit_D10_2_state<=TRANSMIT_D10_2_1;
			receive_Alignp_ok<=0;
			receive_Alignp_state<=RECEIVE_Alignp_1;
			
			transmit_Alignp_ok<=0;
			transmit_Alignp_state<=TRANSMIT_Alignp_1;
			receive_nonAlignp_ok<=0;
			receive_nonAlignp_state<=RECEIVE_NonAlignp_1;
			receive_nonAlignp_cnt<=0;
		end
		else
		begin
			case(HR_state)
				HR_AwaitAlign_1:
				begin
					transmit_D10_2_ok<=0;
					transmit_D10_2_state<=TRANSMIT_D10_2_1;
				end
				
				HR_AwaitAlign_2:
				begin
					transmit_D10_2();
					receive_Alignp_ok<=0;
					receive_Alignp_state<=RECEIVE_Alignp_1;
				end	
				
				HR_AwaitAlign_3:
				begin
					receive_Alignp();
				end
				
				HR_SendAlign_1:
				begin
					transmit_Alignp_ok<=0;
					transmit_Alignp_state<=TRANSMIT_Alignp_1;
				end
				
				HR_SendAlign_2:
				begin
					transmit_Alignp();
					receive_nonAlignp_ok<=0;
					receive_nonAlignp_state<=RECEIVE_NonAlignp_1;
					receive_nonAlignp_cnt<=0;
				end
				
				HR_SendAlign_3:
				begin
					receive_nonAlignp();
				end
				
				HR_SendAlign_4:
				begin
					receive_nonAlignp_cnt<=receive_nonAlignp_cnt+1;
				end
			endcase
		end
	end
		
	
	//phy ready signal 
	always@(posedge DCM_CLK2X_OUT or posedge PHYRESET)
	begin
		if(PHYRESET)
		begin
			phyrdy_flag<=0;
		end
		else
		begin
			if(HR_state==HR_Ready || HR_state==HR_Work)
			begin
				phyrdy_flag<=1;
			end
			else
			begin
				phyrdy_flag<=0;
			end
		end
	end
	

	//transmit OOB signal
	task transmit_COM;
	input COM_TYPE;
	begin
		case(transmit_COM_state)
			TRANSMIT_COM_1:
			begin
				TILE0_TXCOMTYPE0_IN <= COM_TYPE;
				transmit_COM_state<=TRANSMIT_COM_2;
			end
			
			TRANSMIT_COM_2:
			begin
				TILE0_TXCOMSTART0_IN <= 1;
				transmit_COM_state<=TRANSMIT_COM_3;
			end
			
			TRANSMIT_COM_3:
			begin
				//if(TILE0_RXSTATUS0_OUT[0]==1)
				if(1)
				begin
					TILE0_TXCOMSTART0_IN <= 0;
					transmit_COM_state<=TRANSMIT_COM_4;
				end	
				else
				begin
					transmit_COM_state<=TRANSMIT_COM_3;
				end
			end
			
			TRANSMIT_COM_4:
			begin 
				transmit_COM_ok<=1;
			end
			
		endcase
	end
	endtask
	
	
	//transmit Alignp primitive
	task transmit_Alignp;
	begin
		case(transmit_Alignp_state)
			TRANSMIT_Alignp_1:
			begin
				txcharisk_buf <= 1;
				txdata_buf <= 8'b10111100;
				transmit_Alignp_state<=TRANSMIT_Alignp_2;
			end
			
			TRANSMIT_Alignp_2:
			begin
				txcharisk_buf <= 0;
				txdata_buf <= 8'b01001010;
				transmit_Alignp_state<=TRANSMIT_Alignp_3;
			end
			
			TRANSMIT_Alignp_3:
			begin
				txcharisk_buf <= 0;
				txdata_buf <= 8'b01001010;
				transmit_Alignp_state<=TRANSMIT_Alignp_4;
			end
			
			TRANSMIT_Alignp_4:
			begin
				txcharisk_buf <= 0;
				txdata_buf <= 8'b01111011;
				transmit_Alignp_state<=TRANSMIT_Alignp_5;
			end
			
			TRANSMIT_Alignp_5:
			begin
				transmit_Alignp_ok<=1;
			end
		endcase
	end
	endtask
	
	
	//transmit D10.2 characters
	task transmit_D10_2;
	begin
		case(transmit_D10_2_state)
			TRANSMIT_D10_2_1:
			begin
				txcharisk_buf <= 0;
				txdata_buf <= 8'b01001010;
				transmit_D10_2_state<=TRANSMIT_D10_2_2;
			end
			
			TRANSMIT_D10_2_2:
			begin
				transmit_D10_2_ok<=1;
			end
		endcase
	end
	endtask
	
	
	//receive Alignp primitive
	task receive_Alignp;
	begin
		case(receive_Alignp_state)
			RECEIVE_Alignp_1:
			begin
				//if(TILE0_RXDATA0_OUT == 8'b10111100)
				if(1)
				begin
					receive_Alignp_state<=RECEIVE_Alignp_2;
				end
				else
				begin
					receive_Alignp_state<=RECEIVE_Alignp_1;
				end
			end
			
			RECEIVE_Alignp_2:
			begin
				//if(TILE0_RXDATA0_OUT == 8'b01001010)
				if(1)
				begin
					receive_Alignp_state<=RECEIVE_Alignp_3;
				end
				else
				begin
					receive_Alignp_state<=RECEIVE_Alignp_1;
				end
			end
			
			RECEIVE_Alignp_3:
			begin
				//if(TILE0_RXDATA0_OUT == 8'b01001010)
				if(1)
				begin
					receive_Alignp_state<=RECEIVE_Alignp_4;
				end
				else
				begin
					receive_Alignp_state<=RECEIVE_Alignp_1;
				end
			end
			
			RECEIVE_Alignp_4:
			begin
				//if(TILE0_RXDATA0_OUT == 8'b01111011)
				if(1)
				begin
					receive_Alignp_state<=RECEIVE_Alignp_5;
				end
				else
				begin
					receive_Alignp_state<=RECEIVE_Alignp_1;
				end
			end
			
			RECEIVE_Alignp_5:
			begin
				receive_Alignp_ok<=1;
			end
			
		endcase
	end
	endtask
	
	
	//receive non-Alignp primitive
	task receive_nonAlignp;
	begin
		case(receive_nonAlignp_state)
			RECEIVE_NonAlignp_1:
			begin
				receive_nonAlignp_state<=RECEIVE_NonAlignp_2;
			end
			
			RECEIVE_NonAlignp_2:
			begin
				receive_nonAlignp_state<=RECEIVE_NonAlignp_3;
			end
			
			RECEIVE_NonAlignp_3:
			begin
				receive_nonAlignp_state<=RECEIVE_NonAlignp_4;
			end
			
			RECEIVE_NonAlignp_4:
			begin
				receive_nonAlignp_state<=RECEIVE_NonAlignp_5;
			end
			
			RECEIVE_NonAlignp_5:
			begin
				receive_nonAlignp_ok<=1;
			end
			 
		endcase
	end
	endtask
	
	
endmodule
