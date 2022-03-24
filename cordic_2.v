module cordic_function1(phase,clk,reset,sin,cos,Error
);
input 	[31:0]	phase;
input		clk;
input		reset;
output	[31:0]	sin;
output	[31:0]	cos;
output  [31:0]	Error;

reg	signed	[31:0]		sin;
reg signed	[31:0]		cos;
reg signed	[31:0]		Error;
reg signed	[31:0]		x[16:0],y[16:0],z[16:0];
reg signed  [31:0]		rot[15:0];
reg         [8:0]      Quadrant;

parameter pipeline = 16;
parameter k = 32'h09b74;		//k=0.607253*2^16 

always@(posedge clk or negedge reset)begin
	if(!reset)begin
		x[0] <= 1'b0;
		y[0] <= 1'b0;
		z[0] <= 1'b0;
		rot[0] <= 32'd2949120;       //45業*2^16
  		rot[1] <= 32'd1740992;       //26.5651業*2^16
 		rot[2] <= 32'd919872;        //14.0362業*2^16
 		rot[3] <= 32'd466944;        //7.1250業*2^16
 		rot[4] <= 32'd234368;        //3.5763業*2^16
 		rot[5] <= 32'd117312;        //1.7899業*2^16
 		rot[6] <= 32'd58688;         //0.8952業*2^16
 		rot[7] <= 32'd29312;         //0.4476業*2^16
 		rot[8] <= 32'd14656;         //0.2238業*2^16
  		rot[9] <= 32'd7360;          //0.1119業*2^16
  		rot[10] <= 32'd3648;          //0.0560業*2^16
		rot[11] <= 32'd1856;          //0.0280業*2^16
		rot[12] <= 32'd896;           //0.0140業*2^16
 		rot[13] <= 32'd448;           //0.0070業*2^16
 		rot[14] <= 32'd256;           //0.0035業*2^16
 		rot[15] <= 32'd128;           //0.0018業*2^16
	end
	else begin
		x[0] <= k;
		y[0] <= 32'd0;
		z[0] <= phase[15:0] << 16;
	end
end

always@(posedge clk or negedge reset)
begin
    if(!reset)
    begin
        x[1] <= 1'b0;                         
        y[1] <= 1'b0;
        z[1] <= 1'b0;
    end
    else if(z[0][31])
    begin
      x[1] <= x[0] + y[0];
      y[1] <= y[0] - x[0];
      z[1] <= z[0] + rot[0];
    end
    else
    begin
      x[1] <= x[0] - y[0];
      y[1] <= y[0] + x[0];
      z[1] <= z[0] - rot[0];
    end
end

genvar gv_i;

generate 
	for(gv_i = 1 ; gv_i <= pipeline-1 ; gv_i = gv_i + 1)
	begin 
		always@(posedge clk or negedge reset)begin
			if(!reset)begin
				x[gv_i+1] <= 1'b0;
				y[gv_i+1] <= 1'b0;
				z[gv_i+1] <= 1'b0;
			end
			else if(z[gv_i][31]) begin
				x[gv_i+1] <= x[gv_i] + (y[gv_i] >>> gv_i);
				y[gv_i+1] <= y[gv_i] - (x[gv_i] >>> gv_i);
				z[gv_i+1] <= z[gv_i] + rot[gv_i];
			end	
			else begin
				x[gv_i+1] <= x[gv_i] - (y[gv_i] >>> gv_i);
				y[gv_i+1] <= y[gv_i] + (x[gv_i] >>> gv_i);
				z[gv_i+1] <= z[gv_i] - rot[gv_i];
			end	
		end
	end
endgenerate

always@(posedge clk or negedge reset)begin
    if(!reset)
    begin
        Quadrant <=	0;
    end
    else if(Quadrant==8'd17)
    begin
    	Quadrant<=0;
    end
    else 
    begin
    	Quadrant <= Quadrant + 1'b1;
    end
end

always@(posedge clk or negedge reset)begin
    if(!reset)
    begin
        cos <= 1'b0;
        sin <= 1'b0;
        Error <= 1'b0;
    end
    else if(Quadrant == 8'd17)
    begin
        Error <= z[16];
        cos <= x[16]; 
        sin <= y[16]; 
    end
end

endmodule
