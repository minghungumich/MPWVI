module apb_aes_reg_top #(
  parameter int APB_ADDR_WIDTH = 12
) (
  input  logic                      HCLK,
  input  logic                      HRESETn,
  input  logic [APB_ADDR_WIDTH-1:0] PADDR,
  input  logic               [31:0] PWDATA,
  input  logic                      PWRITE,
  input  logic                      PSEL,
  input  logic                      PENABLE,
  output logic               [31:0] PRDATA,
  output logic                      PREADY,
  output logic                      PSLVERR,

  output aes_reg_pkg::aes_reg2hw_t  reg2hw,
  input  aes_reg_pkg::aes_hw2reg_t  hw2reg
);

  import aes_reg_pkg::* ;

  localparam int AW = 8;
  localparam int DW = 32;
  localparam int DBW = DW / 8;

  // register signals
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;

  logic           addrmiss, wr_err;

  logic [DW-1:0]  reg_rdata_next;
  logic           reg_busy;

  logic clk_i, rst_ni, rst_shadowed_ni;

  // Convert APB protocol to internal signals
  assign reg_we    = PSEL && PENABLE && PWRITE;
  assign reg_re    = PSEL && PENABLE && !PWRITE;
  assign reg_addr  = PADDR[AW-1:0];
  assign reg_wdata = PWDATA;
  assign reg_be    = '1;
  assign PRDATA    = reg_rdata;
  assign PREADY    = '1;
  assign PSLVERR   = '0;

  assign reg_rdata = reg_rdata_next;
  assign reg_error = '0;

  assign clk_i = HCLK;
  assign rst_ni = HRESETn;
  assign rst_shadowed_ni = HRESETn;


  // Define SW related signals
  // Format: <reg>_<field>_{wd|we|qs}
  //        or <reg>_{wd|we|qs} if field == 1 or 0
  logic alert_test_we;
  logic alert_test_recov_ctrl_update_err_wd;
  logic alert_test_fatal_fault_wd;
  logic key_share0_0_we;
  logic [31:0] key_share0_0_wd;
  logic key_share0_1_we;
  logic [31:0] key_share0_1_wd;
  logic key_share0_2_we;
  logic [31:0] key_share0_2_wd;
  logic key_share0_3_we;
  logic [31:0] key_share0_3_wd;
  logic key_share0_4_we;
  logic [31:0] key_share0_4_wd;
  logic key_share0_5_we;
  logic [31:0] key_share0_5_wd;
  logic key_share0_6_we;
  logic [31:0] key_share0_6_wd;
  logic key_share0_7_we;
  logic [31:0] key_share0_7_wd;
  logic key_share1_0_we;
  logic [31:0] key_share1_0_wd;
  logic key_share1_1_we;
  logic [31:0] key_share1_1_wd;
  logic key_share1_2_we;
  logic [31:0] key_share1_2_wd;
  logic key_share1_3_we;
  logic [31:0] key_share1_3_wd;
  logic key_share1_4_we;
  logic [31:0] key_share1_4_wd;
  logic key_share1_5_we;
  logic [31:0] key_share1_5_wd;
  logic key_share1_6_we;
  logic [31:0] key_share1_6_wd;
  logic key_share1_7_we;
  logic [31:0] key_share1_7_wd;
  logic iv_0_we;
  logic [31:0] iv_0_wd;
  logic iv_1_we;
  logic [31:0] iv_1_wd;
  logic iv_2_we;
  logic [31:0] iv_2_wd;
  logic iv_3_we;
  logic [31:0] iv_3_wd;
  logic data_in_0_we;
  logic [31:0] data_in_0_wd;
  logic data_in_1_we;
  logic [31:0] data_in_1_wd;
  logic data_in_2_we;
  logic [31:0] data_in_2_wd;
  logic data_in_3_we;
  logic [31:0] data_in_3_wd;
  logic data_out_0_re;
  logic [31:0] data_out_0_qs;
  logic data_out_1_re;
  logic [31:0] data_out_1_qs;
  logic data_out_2_re;
  logic [31:0] data_out_2_qs;
  logic data_out_3_re;
  logic [31:0] data_out_3_qs;
  logic ctrl_shadowed_re;
  logic ctrl_shadowed_we;
  logic [1:0] ctrl_shadowed_operation_qs;
  logic [1:0] ctrl_shadowed_operation_wd;
  logic [5:0] ctrl_shadowed_mode_qs;
  logic [5:0] ctrl_shadowed_mode_wd;
  logic [2:0] ctrl_shadowed_key_len_qs;
  logic [2:0] ctrl_shadowed_key_len_wd;
  logic ctrl_shadowed_sideload_qs;
  logic ctrl_shadowed_sideload_wd;
  logic [2:0] ctrl_shadowed_prng_reseed_rate_qs;
  logic [2:0] ctrl_shadowed_prng_reseed_rate_wd;
  logic ctrl_shadowed_manual_operation_qs;
  logic ctrl_shadowed_manual_operation_wd;
  logic ctrl_shadowed_force_zero_masks_qs;
  logic ctrl_shadowed_force_zero_masks_wd;
  logic ctrl_aux_shadowed_re;
  logic ctrl_aux_shadowed_we;
  logic ctrl_aux_shadowed_qs;
  logic ctrl_aux_shadowed_wd;
  logic ctrl_aux_regwen_we;
  logic ctrl_aux_regwen_qs;
  logic ctrl_aux_regwen_wd;
  logic trigger_we;
  logic trigger_start_wd;
  logic trigger_key_iv_data_in_clear_wd;
  logic trigger_data_out_clear_wd;
  logic trigger_prng_reseed_wd;
  logic status_idle_qs;
  logic status_stall_qs;
  logic status_output_lost_qs;
  logic status_output_valid_qs;
  logic status_input_ready_qs;
  logic status_alert_recov_ctrl_update_err_qs;
  logic status_alert_fatal_fault_qs;


  // Register instances
  // R[alert_test]: V(True)
  //   F[recov_ctrl_update_err]: 0:0
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_recov_ctrl_update_err (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_recov_ctrl_update_err_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.alert_test.recov_ctrl_update_err.qe),
    .q      (reg2hw.alert_test.recov_ctrl_update_err.q),
    .qs     ()
  );

  //   F[fatal_fault]: 1:1
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_fatal_fault (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_fatal_fault_wd),
    .d      ('0),
    .qre    (),
    .qe     (reg2hw.alert_test.fatal_fault.qe),
    .q      (reg2hw.alert_test.fatal_fault.q),
    .qs     ()
  );


  // Subregister 0 of Multireg key_share0
  // R[key_share0_0]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_0 (
    .re     (1'b0),
    .we     (key_share0_0_we),
    .wd     (key_share0_0_wd),
    .d      (hw2reg.key_share0[0].d),
    .qre    (),
    .qe     (reg2hw.key_share0[0].qe),
    .q      (reg2hw.key_share0[0].q),
    .qs     ()
  );


  // Subregister 1 of Multireg key_share0
  // R[key_share0_1]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_1 (
    .re     (1'b0),
    .we     (key_share0_1_we),
    .wd     (key_share0_1_wd),
    .d      (hw2reg.key_share0[1].d),
    .qre    (),
    .qe     (reg2hw.key_share0[1].qe),
    .q      (reg2hw.key_share0[1].q),
    .qs     ()
  );


  // Subregister 2 of Multireg key_share0
  // R[key_share0_2]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_2 (
    .re     (1'b0),
    .we     (key_share0_2_we),
    .wd     (key_share0_2_wd),
    .d      (hw2reg.key_share0[2].d),
    .qre    (),
    .qe     (reg2hw.key_share0[2].qe),
    .q      (reg2hw.key_share0[2].q),
    .qs     ()
  );


  // Subregister 3 of Multireg key_share0
  // R[key_share0_3]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_3 (
    .re     (1'b0),
    .we     (key_share0_3_we),
    .wd     (key_share0_3_wd),
    .d      (hw2reg.key_share0[3].d),
    .qre    (),
    .qe     (reg2hw.key_share0[3].qe),
    .q      (reg2hw.key_share0[3].q),
    .qs     ()
  );


  // Subregister 4 of Multireg key_share0
  // R[key_share0_4]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_4 (
    .re     (1'b0),
    .we     (key_share0_4_we),
    .wd     (key_share0_4_wd),
    .d      (hw2reg.key_share0[4].d),
    .qre    (),
    .qe     (reg2hw.key_share0[4].qe),
    .q      (reg2hw.key_share0[4].q),
    .qs     ()
  );


  // Subregister 5 of Multireg key_share0
  // R[key_share0_5]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_5 (
    .re     (1'b0),
    .we     (key_share0_5_we),
    .wd     (key_share0_5_wd),
    .d      (hw2reg.key_share0[5].d),
    .qre    (),
    .qe     (reg2hw.key_share0[5].qe),
    .q      (reg2hw.key_share0[5].q),
    .qs     ()
  );


  // Subregister 6 of Multireg key_share0
  // R[key_share0_6]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_6 (
    .re     (1'b0),
    .we     (key_share0_6_we),
    .wd     (key_share0_6_wd),
    .d      (hw2reg.key_share0[6].d),
    .qre    (),
    .qe     (reg2hw.key_share0[6].qe),
    .q      (reg2hw.key_share0[6].q),
    .qs     ()
  );


  // Subregister 7 of Multireg key_share0
  // R[key_share0_7]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_7 (
    .re     (1'b0),
    .we     (key_share0_7_we),
    .wd     (key_share0_7_wd),
    .d      (hw2reg.key_share0[7].d),
    .qre    (),
    .qe     (reg2hw.key_share0[7].qe),
    .q      (reg2hw.key_share0[7].q),
    .qs     ()
  );


  // Subregister 0 of Multireg key_share1
  // R[key_share1_0]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_0 (
    .re     (1'b0),
    .we     (key_share1_0_we),
    .wd     (key_share1_0_wd),
    .d      (hw2reg.key_share1[0].d),
    .qre    (),
    .qe     (reg2hw.key_share1[0].qe),
    .q      (reg2hw.key_share1[0].q),
    .qs     ()
  );


  // Subregister 1 of Multireg key_share1
  // R[key_share1_1]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_1 (
    .re     (1'b0),
    .we     (key_share1_1_we),
    .wd     (key_share1_1_wd),
    .d      (hw2reg.key_share1[1].d),
    .qre    (),
    .qe     (reg2hw.key_share1[1].qe),
    .q      (reg2hw.key_share1[1].q),
    .qs     ()
  );


  // Subregister 2 of Multireg key_share1
  // R[key_share1_2]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_2 (
    .re     (1'b0),
    .we     (key_share1_2_we),
    .wd     (key_share1_2_wd),
    .d      (hw2reg.key_share1[2].d),
    .qre    (),
    .qe     (reg2hw.key_share1[2].qe),
    .q      (reg2hw.key_share1[2].q),
    .qs     ()
  );


  // Subregister 3 of Multireg key_share1
  // R[key_share1_3]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_3 (
    .re     (1'b0),
    .we     (key_share1_3_we),
    .wd     (key_share1_3_wd),
    .d      (hw2reg.key_share1[3].d),
    .qre    (),
    .qe     (reg2hw.key_share1[3].qe),
    .q      (reg2hw.key_share1[3].q),
    .qs     ()
  );


  // Subregister 4 of Multireg key_share1
  // R[key_share1_4]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_4 (
    .re     (1'b0),
    .we     (key_share1_4_we),
    .wd     (key_share1_4_wd),
    .d      (hw2reg.key_share1[4].d),
    .qre    (),
    .qe     (reg2hw.key_share1[4].qe),
    .q      (reg2hw.key_share1[4].q),
    .qs     ()
  );


  // Subregister 5 of Multireg key_share1
  // R[key_share1_5]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_5 (
    .re     (1'b0),
    .we     (key_share1_5_we),
    .wd     (key_share1_5_wd),
    .d      (hw2reg.key_share1[5].d),
    .qre    (),
    .qe     (reg2hw.key_share1[5].qe),
    .q      (reg2hw.key_share1[5].q),
    .qs     ()
  );


  // Subregister 6 of Multireg key_share1
  // R[key_share1_6]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_6 (
    .re     (1'b0),
    .we     (key_share1_6_we),
    .wd     (key_share1_6_wd),
    .d      (hw2reg.key_share1[6].d),
    .qre    (),
    .qe     (reg2hw.key_share1[6].qe),
    .q      (reg2hw.key_share1[6].q),
    .qs     ()
  );


  // Subregister 7 of Multireg key_share1
  // R[key_share1_7]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_7 (
    .re     (1'b0),
    .we     (key_share1_7_we),
    .wd     (key_share1_7_wd),
    .d      (hw2reg.key_share1[7].d),
    .qre    (),
    .qe     (reg2hw.key_share1[7].qe),
    .q      (reg2hw.key_share1[7].q),
    .qs     ()
  );


  // Subregister 0 of Multireg iv
  // R[iv_0]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_iv_0 (
    .re     (1'b0),
    .we     (iv_0_we),
    .wd     (iv_0_wd),
    .d      (hw2reg.iv[0].d),
    .qre    (),
    .qe     (reg2hw.iv[0].qe),
    .q      (reg2hw.iv[0].q),
    .qs     ()
  );


  // Subregister 1 of Multireg iv
  // R[iv_1]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_iv_1 (
    .re     (1'b0),
    .we     (iv_1_we),
    .wd     (iv_1_wd),
    .d      (hw2reg.iv[1].d),
    .qre    (),
    .qe     (reg2hw.iv[1].qe),
    .q      (reg2hw.iv[1].q),
    .qs     ()
  );


  // Subregister 2 of Multireg iv
  // R[iv_2]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_iv_2 (
    .re     (1'b0),
    .we     (iv_2_we),
    .wd     (iv_2_wd),
    .d      (hw2reg.iv[2].d),
    .qre    (),
    .qe     (reg2hw.iv[2].qe),
    .q      (reg2hw.iv[2].q),
    .qs     ()
  );


  // Subregister 3 of Multireg iv
  // R[iv_3]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_iv_3 (
    .re     (1'b0),
    .we     (iv_3_we),
    .wd     (iv_3_wd),
    .d      (hw2reg.iv[3].d),
    .qre    (),
    .qe     (reg2hw.iv[3].qe),
    .q      (reg2hw.iv[3].q),
    .qs     ()
  );


  // Subregister 0 of Multireg data_in
  // R[data_in_0]: V(False)
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0)
  ) u_data_in_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (data_in_0_we),
    .wd     (data_in_0_wd),

    // from internal hardware
    .de     (hw2reg.data_in[0].de),
    .d      (hw2reg.data_in[0].d),

    // to internal hardware
    .qe     (reg2hw.data_in[0].qe),
    .q      (reg2hw.data_in[0].q),

    // to register interface (read)
    .qs     ()
  );


  // Subregister 1 of Multireg data_in
  // R[data_in_1]: V(False)
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0)
  ) u_data_in_1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (data_in_1_we),
    .wd     (data_in_1_wd),

    // from internal hardware
    .de     (hw2reg.data_in[1].de),
    .d      (hw2reg.data_in[1].d),

    // to internal hardware
    .qe     (reg2hw.data_in[1].qe),
    .q      (reg2hw.data_in[1].q),

    // to register interface (read)
    .qs     ()
  );


  // Subregister 2 of Multireg data_in
  // R[data_in_2]: V(False)
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0)
  ) u_data_in_2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (data_in_2_we),
    .wd     (data_in_2_wd),

    // from internal hardware
    .de     (hw2reg.data_in[2].de),
    .d      (hw2reg.data_in[2].d),

    // to internal hardware
    .qe     (reg2hw.data_in[2].qe),
    .q      (reg2hw.data_in[2].q),

    // to register interface (read)
    .qs     ()
  );


  // Subregister 3 of Multireg data_in
  // R[data_in_3]: V(False)
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0)
  ) u_data_in_3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (data_in_3_we),
    .wd     (data_in_3_wd),

    // from internal hardware
    .de     (hw2reg.data_in[3].de),
    .d      (hw2reg.data_in[3].d),

    // to internal hardware
    .qe     (reg2hw.data_in[3].qe),
    .q      (reg2hw.data_in[3].q),

    // to register interface (read)
    .qs     ()
  );


  // Subregister 0 of Multireg data_out
  // R[data_out_0]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_out_0 (
    .re     (data_out_0_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.data_out[0].d),
    .qre    (reg2hw.data_out[0].re),
    .qe     (),
    .q      (reg2hw.data_out[0].q),
    .qs     (data_out_0_qs)
  );


  // Subregister 1 of Multireg data_out
  // R[data_out_1]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_out_1 (
    .re     (data_out_1_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.data_out[1].d),
    .qre    (reg2hw.data_out[1].re),
    .qe     (),
    .q      (reg2hw.data_out[1].q),
    .qs     (data_out_1_qs)
  );


  // Subregister 2 of Multireg data_out
  // R[data_out_2]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_out_2 (
    .re     (data_out_2_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.data_out[2].d),
    .qre    (reg2hw.data_out[2].re),
    .qe     (),
    .q      (reg2hw.data_out[2].q),
    .qs     (data_out_2_qs)
  );


  // Subregister 3 of Multireg data_out
  // R[data_out_3]: V(True)
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_out_3 (
    .re     (data_out_3_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.data_out[3].d),
    .qre    (reg2hw.data_out[3].re),
    .qe     (),
    .q      (reg2hw.data_out[3].q),
    .qs     (data_out_3_qs)
  );


  // R[ctrl_shadowed]: V(True)
  //   F[operation]: 1:0
  prim_subreg_ext #(
    .DW    (2)
  ) u_ctrl_shadowed_operation (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_operation_wd),
    .d      (hw2reg.ctrl_shadowed.operation.d),
    .qre    (reg2hw.ctrl_shadowed.operation.re),
    .qe     (reg2hw.ctrl_shadowed.operation.qe),
    .q      (reg2hw.ctrl_shadowed.operation.q),
    .qs     (ctrl_shadowed_operation_qs)
  );

  //   F[mode]: 7:2
  prim_subreg_ext #(
    .DW    (6)
  ) u_ctrl_shadowed_mode (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_mode_wd),
    .d      (hw2reg.ctrl_shadowed.mode.d),
    .qre    (reg2hw.ctrl_shadowed.mode.re),
    .qe     (reg2hw.ctrl_shadowed.mode.qe),
    .q      (reg2hw.ctrl_shadowed.mode.q),
    .qs     (ctrl_shadowed_mode_qs)
  );

  //   F[key_len]: 10:8
  prim_subreg_ext #(
    .DW    (3)
  ) u_ctrl_shadowed_key_len (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_key_len_wd),
    .d      (hw2reg.ctrl_shadowed.key_len.d),
    .qre    (reg2hw.ctrl_shadowed.key_len.re),
    .qe     (reg2hw.ctrl_shadowed.key_len.qe),
    .q      (reg2hw.ctrl_shadowed.key_len.q),
    .qs     (ctrl_shadowed_key_len_qs)
  );

  //   F[sideload]: 11:11
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_shadowed_sideload (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_sideload_wd),
    .d      (hw2reg.ctrl_shadowed.sideload.d),
    .qre    (reg2hw.ctrl_shadowed.sideload.re),
    .qe     (reg2hw.ctrl_shadowed.sideload.qe),
    .q      (reg2hw.ctrl_shadowed.sideload.q),
    .qs     (ctrl_shadowed_sideload_qs)
  );

  //   F[prng_reseed_rate]: 14:12
  prim_subreg_ext #(
    .DW    (3)
  ) u_ctrl_shadowed_prng_reseed_rate (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_prng_reseed_rate_wd),
    .d      (hw2reg.ctrl_shadowed.prng_reseed_rate.d),
    .qre    (reg2hw.ctrl_shadowed.prng_reseed_rate.re),
    .qe     (reg2hw.ctrl_shadowed.prng_reseed_rate.qe),
    .q      (reg2hw.ctrl_shadowed.prng_reseed_rate.q),
    .qs     (ctrl_shadowed_prng_reseed_rate_qs)
  );

  //   F[manual_operation]: 15:15
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_shadowed_manual_operation (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_manual_operation_wd),
    .d      (hw2reg.ctrl_shadowed.manual_operation.d),
    .qre    (reg2hw.ctrl_shadowed.manual_operation.re),
    .qe     (reg2hw.ctrl_shadowed.manual_operation.qe),
    .q      (reg2hw.ctrl_shadowed.manual_operation.q),
    .qs     (ctrl_shadowed_manual_operation_qs)
  );

  //   F[force_zero_masks]: 16:16
  prim_subreg_ext #(
    .DW    (1)
  ) u_ctrl_shadowed_force_zero_masks (
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_force_zero_masks_wd),
    .d      (hw2reg.ctrl_shadowed.force_zero_masks.d),
    .qre    (reg2hw.ctrl_shadowed.force_zero_masks.re),
    .qe     (reg2hw.ctrl_shadowed.force_zero_masks.qe),
    .q      (reg2hw.ctrl_shadowed.force_zero_masks.q),
    .qs     (ctrl_shadowed_force_zero_masks_qs)
  );


  // R[ctrl_aux_shadowed]: V(False)
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1)
  ) u_ctrl_aux_shadowed (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),

    // from register interface
    .re     (ctrl_aux_shadowed_re),
    .we     (ctrl_aux_shadowed_we & ctrl_aux_regwen_qs),
    .wd     (ctrl_aux_shadowed_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.ctrl_aux_shadowed.q),

    // to register interface (read)
    .qs     (ctrl_aux_shadowed_qs),

    // Shadow register error conditions
    .err_update  (reg2hw.ctrl_aux_shadowed.err_update),
    .err_storage (reg2hw.ctrl_aux_shadowed.err_storage)
  );


  // R[ctrl_aux_regwen]: V(False)
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1)
  ) u_ctrl_aux_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (ctrl_aux_regwen_we),
    .wd     (ctrl_aux_regwen_wd),

    // from internal hardware
    .de     (1'b0),
    .d      ('0),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (ctrl_aux_regwen_qs)
  );


  // R[trigger]: V(False)
  //   F[start]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h0)
  ) u_trigger_start (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (trigger_we),
    .wd     (trigger_start_wd),

    // from internal hardware
    .de     (hw2reg.trigger.start.de),
    .d      (hw2reg.trigger.start.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.start.q),

    // to register interface (read)
    .qs     ()
  );

  //   F[key_iv_data_in_clear]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h1)
  ) u_trigger_key_iv_data_in_clear (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (trigger_we),
    .wd     (trigger_key_iv_data_in_clear_wd),

    // from internal hardware
    .de     (hw2reg.trigger.key_iv_data_in_clear.de),
    .d      (hw2reg.trigger.key_iv_data_in_clear.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.key_iv_data_in_clear.q),

    // to register interface (read)
    .qs     ()
  );

  //   F[data_out_clear]: 2:2
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h1)
  ) u_trigger_data_out_clear (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (trigger_we),
    .wd     (trigger_data_out_clear_wd),

    // from internal hardware
    .de     (hw2reg.trigger.data_out_clear.de),
    .d      (hw2reg.trigger.data_out_clear.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.data_out_clear.q),

    // to register interface (read)
    .qs     ()
  );

  //   F[prng_reseed]: 3:3
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h1)
  ) u_trigger_prng_reseed (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (trigger_we),
    .wd     (trigger_prng_reseed_wd),

    // from internal hardware
    .de     (hw2reg.trigger.prng_reseed.de),
    .d      (hw2reg.trigger.prng_reseed.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.trigger.prng_reseed.q),

    // to register interface (read)
    .qs     ()
  );


  // R[status]: V(False)
  //   F[idle]: 0:0
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_idle (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.idle.de),
    .d      (hw2reg.status.idle.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_idle_qs)
  );

  //   F[stall]: 1:1
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_stall (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.stall.de),
    .d      (hw2reg.status.stall.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_stall_qs)
  );

  //   F[output_lost]: 2:2
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_output_lost (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.output_lost.de),
    .d      (hw2reg.status.output_lost.d),

    // to internal hardware
    .qe     (),
    .q      (reg2hw.status.output_lost.q),

    // to register interface (read)
    .qs     (status_output_lost_qs)
  );

  //   F[output_valid]: 3:3
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_output_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.output_valid.de),
    .d      (hw2reg.status.output_valid.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_output_valid_qs)
  );

  //   F[input_ready]: 4:4
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_input_ready (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.input_ready.de),
    .d      (hw2reg.status.input_ready.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_input_ready_qs)
  );

  //   F[alert_recov_ctrl_update_err]: 5:5
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_alert_recov_ctrl_update_err (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.alert_recov_ctrl_update_err.de),
    .d      (hw2reg.status.alert_recov_ctrl_update_err.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_alert_recov_ctrl_update_err_qs)
  );

  //   F[alert_fatal_fault]: 6:6
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0)
  ) u_status_alert_fatal_fault (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),

    // from register interface
    .we     (1'b0),
    .wd     ('0),

    // from internal hardware
    .de     (hw2reg.status.alert_fatal_fault.de),
    .d      (hw2reg.status.alert_fatal_fault.d),

    // to internal hardware
    .qe     (),
    .q      (),

    // to register interface (read)
    .qs     (status_alert_fatal_fault_qs)
  );



  logic [33:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == AES_ALERT_TEST_OFFSET);
    addr_hit[ 1] = (reg_addr == AES_KEY_SHARE0_0_OFFSET);
    addr_hit[ 2] = (reg_addr == AES_KEY_SHARE0_1_OFFSET);
    addr_hit[ 3] = (reg_addr == AES_KEY_SHARE0_2_OFFSET);
    addr_hit[ 4] = (reg_addr == AES_KEY_SHARE0_3_OFFSET);
    addr_hit[ 5] = (reg_addr == AES_KEY_SHARE0_4_OFFSET);
    addr_hit[ 6] = (reg_addr == AES_KEY_SHARE0_5_OFFSET);
    addr_hit[ 7] = (reg_addr == AES_KEY_SHARE0_6_OFFSET);
    addr_hit[ 8] = (reg_addr == AES_KEY_SHARE0_7_OFFSET);
    addr_hit[ 9] = (reg_addr == AES_KEY_SHARE1_0_OFFSET);
    addr_hit[10] = (reg_addr == AES_KEY_SHARE1_1_OFFSET);
    addr_hit[11] = (reg_addr == AES_KEY_SHARE1_2_OFFSET);
    addr_hit[12] = (reg_addr == AES_KEY_SHARE1_3_OFFSET);
    addr_hit[13] = (reg_addr == AES_KEY_SHARE1_4_OFFSET);
    addr_hit[14] = (reg_addr == AES_KEY_SHARE1_5_OFFSET);
    addr_hit[15] = (reg_addr == AES_KEY_SHARE1_6_OFFSET);
    addr_hit[16] = (reg_addr == AES_KEY_SHARE1_7_OFFSET);
    addr_hit[17] = (reg_addr == AES_IV_0_OFFSET);
    addr_hit[18] = (reg_addr == AES_IV_1_OFFSET);
    addr_hit[19] = (reg_addr == AES_IV_2_OFFSET);
    addr_hit[20] = (reg_addr == AES_IV_3_OFFSET);
    addr_hit[21] = (reg_addr == AES_DATA_IN_0_OFFSET);
    addr_hit[22] = (reg_addr == AES_DATA_IN_1_OFFSET);
    addr_hit[23] = (reg_addr == AES_DATA_IN_2_OFFSET);
    addr_hit[24] = (reg_addr == AES_DATA_IN_3_OFFSET);
    addr_hit[25] = (reg_addr == AES_DATA_OUT_0_OFFSET);
    addr_hit[26] = (reg_addr == AES_DATA_OUT_1_OFFSET);
    addr_hit[27] = (reg_addr == AES_DATA_OUT_2_OFFSET);
    addr_hit[28] = (reg_addr == AES_DATA_OUT_3_OFFSET);
    addr_hit[29] = (reg_addr == AES_CTRL_SHADOWED_OFFSET);
    addr_hit[30] = (reg_addr == AES_CTRL_AUX_SHADOWED_OFFSET);
    addr_hit[31] = (reg_addr == AES_CTRL_AUX_REGWEN_OFFSET);
    addr_hit[32] = (reg_addr == AES_TRIGGER_OFFSET);
    addr_hit[33] = (reg_addr == AES_STATUS_OFFSET);
  end

  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;

  // Check sub-word write is permitted
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(AES_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(AES_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(AES_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(AES_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(AES_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(AES_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(AES_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(AES_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(AES_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(AES_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(AES_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(AES_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(AES_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(AES_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(AES_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(AES_PERMIT[15] & ~reg_be))) |
               (addr_hit[16] & (|(AES_PERMIT[16] & ~reg_be))) |
               (addr_hit[17] & (|(AES_PERMIT[17] & ~reg_be))) |
               (addr_hit[18] & (|(AES_PERMIT[18] & ~reg_be))) |
               (addr_hit[19] & (|(AES_PERMIT[19] & ~reg_be))) |
               (addr_hit[20] & (|(AES_PERMIT[20] & ~reg_be))) |
               (addr_hit[21] & (|(AES_PERMIT[21] & ~reg_be))) |
               (addr_hit[22] & (|(AES_PERMIT[22] & ~reg_be))) |
               (addr_hit[23] & (|(AES_PERMIT[23] & ~reg_be))) |
               (addr_hit[24] & (|(AES_PERMIT[24] & ~reg_be))) |
               (addr_hit[25] & (|(AES_PERMIT[25] & ~reg_be))) |
               (addr_hit[26] & (|(AES_PERMIT[26] & ~reg_be))) |
               (addr_hit[27] & (|(AES_PERMIT[27] & ~reg_be))) |
               (addr_hit[28] & (|(AES_PERMIT[28] & ~reg_be))) |
               (addr_hit[29] & (|(AES_PERMIT[29] & ~reg_be))) |
               (addr_hit[30] & (|(AES_PERMIT[30] & ~reg_be))) |
               (addr_hit[31] & (|(AES_PERMIT[31] & ~reg_be))) |
               (addr_hit[32] & (|(AES_PERMIT[32] & ~reg_be))) |
               (addr_hit[33] & (|(AES_PERMIT[33] & ~reg_be)))));
  end
  assign alert_test_we = addr_hit[0] & reg_we & !reg_error;

  assign alert_test_recov_ctrl_update_err_wd = reg_wdata[0];

  assign alert_test_fatal_fault_wd = reg_wdata[1];
  assign key_share0_0_we = addr_hit[1] & reg_we & !reg_error;

  assign key_share0_0_wd = reg_wdata[31:0];
  assign key_share0_1_we = addr_hit[2] & reg_we & !reg_error;

  assign key_share0_1_wd = reg_wdata[31:0];
  assign key_share0_2_we = addr_hit[3] & reg_we & !reg_error;

  assign key_share0_2_wd = reg_wdata[31:0];
  assign key_share0_3_we = addr_hit[4] & reg_we & !reg_error;

  assign key_share0_3_wd = reg_wdata[31:0];
  assign key_share0_4_we = addr_hit[5] & reg_we & !reg_error;

  assign key_share0_4_wd = reg_wdata[31:0];
  assign key_share0_5_we = addr_hit[6] & reg_we & !reg_error;

  assign key_share0_5_wd = reg_wdata[31:0];
  assign key_share0_6_we = addr_hit[7] & reg_we & !reg_error;

  assign key_share0_6_wd = reg_wdata[31:0];
  assign key_share0_7_we = addr_hit[8] & reg_we & !reg_error;

  assign key_share0_7_wd = reg_wdata[31:0];
  assign key_share1_0_we = addr_hit[9] & reg_we & !reg_error;

  assign key_share1_0_wd = reg_wdata[31:0];
  assign key_share1_1_we = addr_hit[10] & reg_we & !reg_error;

  assign key_share1_1_wd = reg_wdata[31:0];
  assign key_share1_2_we = addr_hit[11] & reg_we & !reg_error;

  assign key_share1_2_wd = reg_wdata[31:0];
  assign key_share1_3_we = addr_hit[12] & reg_we & !reg_error;

  assign key_share1_3_wd = reg_wdata[31:0];
  assign key_share1_4_we = addr_hit[13] & reg_we & !reg_error;

  assign key_share1_4_wd = reg_wdata[31:0];
  assign key_share1_5_we = addr_hit[14] & reg_we & !reg_error;

  assign key_share1_5_wd = reg_wdata[31:0];
  assign key_share1_6_we = addr_hit[15] & reg_we & !reg_error;

  assign key_share1_6_wd = reg_wdata[31:0];
  assign key_share1_7_we = addr_hit[16] & reg_we & !reg_error;

  assign key_share1_7_wd = reg_wdata[31:0];
  assign iv_0_we = addr_hit[17] & reg_we & !reg_error;

  assign iv_0_wd = reg_wdata[31:0];
  assign iv_1_we = addr_hit[18] & reg_we & !reg_error;

  assign iv_1_wd = reg_wdata[31:0];
  assign iv_2_we = addr_hit[19] & reg_we & !reg_error;

  assign iv_2_wd = reg_wdata[31:0];
  assign iv_3_we = addr_hit[20] & reg_we & !reg_error;

  assign iv_3_wd = reg_wdata[31:0];
  assign data_in_0_we = addr_hit[21] & reg_we & !reg_error;

  assign data_in_0_wd = reg_wdata[31:0];
  assign data_in_1_we = addr_hit[22] & reg_we & !reg_error;

  assign data_in_1_wd = reg_wdata[31:0];
  assign data_in_2_we = addr_hit[23] & reg_we & !reg_error;

  assign data_in_2_wd = reg_wdata[31:0];
  assign data_in_3_we = addr_hit[24] & reg_we & !reg_error;

  assign data_in_3_wd = reg_wdata[31:0];
  assign data_out_0_re = addr_hit[25] & reg_re & !reg_error;
  assign data_out_1_re = addr_hit[26] & reg_re & !reg_error;
  assign data_out_2_re = addr_hit[27] & reg_re & !reg_error;
  assign data_out_3_re = addr_hit[28] & reg_re & !reg_error;
  assign ctrl_shadowed_re = addr_hit[29] & reg_re & !reg_error;
  assign ctrl_shadowed_we = addr_hit[29] & reg_we & !reg_error;

  assign ctrl_shadowed_operation_wd = reg_wdata[1:0];

  assign ctrl_shadowed_mode_wd = reg_wdata[7:2];

  assign ctrl_shadowed_key_len_wd = reg_wdata[10:8];

  assign ctrl_shadowed_sideload_wd = reg_wdata[11];

  assign ctrl_shadowed_prng_reseed_rate_wd = reg_wdata[14:12];

  assign ctrl_shadowed_manual_operation_wd = reg_wdata[15];

  assign ctrl_shadowed_force_zero_masks_wd = reg_wdata[16];
  assign ctrl_aux_shadowed_re = addr_hit[30] & reg_re & !reg_error;
  assign ctrl_aux_shadowed_we = addr_hit[30] & reg_we & !reg_error;

  assign ctrl_aux_shadowed_wd = reg_wdata[0];
  assign ctrl_aux_regwen_we = addr_hit[31] & reg_we & !reg_error;

  assign ctrl_aux_regwen_wd = reg_wdata[0];
  assign trigger_we = addr_hit[32] & reg_we & !reg_error;

  assign trigger_start_wd = reg_wdata[0];

  assign trigger_key_iv_data_in_clear_wd = reg_wdata[1];

  assign trigger_data_out_clear_wd = reg_wdata[2];

  assign trigger_prng_reseed_wd = reg_wdata[3];

  // Read data return
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end

      addr_hit[1]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[2]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[3]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[4]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[5]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[6]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[7]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[8]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[9]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[10]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[11]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[12]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[13]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[14]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[15]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[16]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[17]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[18]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[19]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[20]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[21]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[22]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[23]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[24]: begin
        reg_rdata_next[31:0] = '0;
      end

      addr_hit[25]: begin
        reg_rdata_next[31:0] = data_out_0_qs;
      end

      addr_hit[26]: begin
        reg_rdata_next[31:0] = data_out_1_qs;
      end

      addr_hit[27]: begin
        reg_rdata_next[31:0] = data_out_2_qs;
      end

      addr_hit[28]: begin
        reg_rdata_next[31:0] = data_out_3_qs;
      end

      addr_hit[29]: begin
        reg_rdata_next[1:0] = ctrl_shadowed_operation_qs;
        reg_rdata_next[7:2] = ctrl_shadowed_mode_qs;
        reg_rdata_next[10:8] = ctrl_shadowed_key_len_qs;
        reg_rdata_next[11] = ctrl_shadowed_sideload_qs;
        reg_rdata_next[14:12] = ctrl_shadowed_prng_reseed_rate_qs;
        reg_rdata_next[15] = ctrl_shadowed_manual_operation_qs;
        reg_rdata_next[16] = ctrl_shadowed_force_zero_masks_qs;
      end

      addr_hit[30]: begin
        reg_rdata_next[0] = ctrl_aux_shadowed_qs;
      end

      addr_hit[31]: begin
        reg_rdata_next[0] = ctrl_aux_regwen_qs;
      end

      addr_hit[32]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
        reg_rdata_next[2] = '0;
        reg_rdata_next[3] = '0;
      end

      addr_hit[33]: begin
        reg_rdata_next[0] = status_idle_qs;
        reg_rdata_next[1] = status_stall_qs;
        reg_rdata_next[2] = status_output_lost_qs;
        reg_rdata_next[3] = status_output_valid_qs;
        reg_rdata_next[4] = status_input_ready_qs;
        reg_rdata_next[5] = status_alert_recov_ctrl_update_err_qs;
        reg_rdata_next[6] = status_alert_fatal_fault_qs;
      end

      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end

  // shadow busy
  logic shadow_busy;
  logic rst_done;
  logic shadow_rst_done;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rst_done <= '0;
    end else begin
      rst_done <= 1'b1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_shadowed_ni) begin
    if (!rst_shadowed_ni) begin
      shadow_rst_done <= '0;
    end else begin
      shadow_rst_done <= 1'b1;
    end
  end

  // both shadow and normal resets have been released
  assign shadow_busy = ~(rst_done & shadow_rst_done);

  // register busy
  logic reg_busy_sel;
  assign reg_busy = reg_busy_sel | shadow_busy;
  always_comb begin
    reg_busy_sel = '0;
    unique case (1'b1)
      default: begin
        reg_busy_sel  = '0;
      end
    endcase
  end


  // Unused signal tieoff

  // wdata / byte enable are not always fully used
  // add a blanket unused statement to handle lint waivers
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;


endmodule : apb_aes_reg_top
