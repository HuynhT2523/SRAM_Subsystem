// RESET
always @(negedge n_hreset) begin
    assert (htrans == 2'b00 && hready == 1'b1 && hresp == 1'b0)
        $info("[%0t] PASS reset !!!", $time);
    else 
        $error("[%0t] FAIL reset !!!", $time);
end

property reset_keep_prop;
    @(posedge hclk)
    (!n_hreset) |-> (hready == 1'b1 && hresp == 1'b0);
endproperty

reset_keep_prop_chk : assert property (reset_keep_prop);
  
// HREADY
property hready_wait_state_prop;
    @(posedge hclk) disable iff(!n_hreset)
    (!hready && $past(!hresp)) |-> (!hresp);
endproperty
  
hready_wait_state_prop_chk: assert property (hready_wait_state_prop);
  
property hready_prop;
    @(posedge hclk) disable iff (!n_hreset)
    (hsel && (htrans == 2'b10)) |=> if(hresp)  ##1 (hready && hsel) else (hready && hsel);
endproperty

hready_prop_chk: assert property (hready_prop);
  
// HRESP & HREADY
property hresp_hready_prop;
    @(posedge hclk) disable iff(!n_hreset)
    ($rose(hresp)) |-> (!hready ##1 hready);
endproperty
  
hresp_hready_prop_chk: assert property (hresp_hready_prop);
  
// HRESP when HSIZE > 3'b010
property hresp_after_invalid_hsize;
    @(posedge hclk) disable iff (!n_hreset)
    (hsel && (htrans == 2'b10) && (hsize > 3'b010)) |-> (hresp && !hready) ##1 (hresp && hready);
endproperty

assert_hresp_after_invalid_hsize: assert property (hresp_after_invalid_hsize);