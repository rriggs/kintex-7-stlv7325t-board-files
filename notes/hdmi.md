# HDMI Example Project

This project will use a stand-alone Microblaze design to drive the Video Test
Pattern Generator to product HDMI output from the Kintex-7 board.

We will start by making a block design and then write a driver application
for the TestPatternGenerator.

This demo was developed using Vivado 2021.2.

If you are using Windows, you may need to adjust some paths. But forward
slashes do work in Windows as a path separator and have for decades.

## Conventions

We will from time to time use Bash or Tcl commands. These are shown in
fixed font.

Tcl commands start with a `> ` prompt, with the expected output on the
following lines.

    > get_boards
    aliexpress.com:hpc_xc7k325t:1.0 ...

Bash commands start with a `$ ` prompt, with the expected output on the
following lines.

    $ echo "validate_board_files hpc-xc7k325t/1.0" | vivado -mode tcl
    ...
    The board defined in 'hpc-xc7k325t/1.0' is valid.

Elipsis are used frequently to show that extraneous text has be removed.
    

## Prerequisites

You will need the following items to run this test:

 1. A computer running Vivado with a license for the Kintex-7 FPGA.
 1. A 12V power supply to power the board.
 1. A JTAG programmer to progam the device.
 1. A mini-USB cable to connect to the serial port.
 1. A 1080p-capable monitor and an HDMI cable.

### Board Files

Clone the board repository to your home directory.

    $ git clone https://github.com/rriggs/kintex-7-stlv7325t-board-files
    
Add the board files to Vivado by running the following command:

    > set_param board.repoPaths [list "~/kintex-7-stlv7325t-board-files"]

This assumes your Git repo is checked out at `~/kintex-7-stlv7325t-board-files`.

Tcl does not expand the tilde to your home directory in Vivado, so you must
use the full pathname.

Now check that the board is found:

    > get_boards ali*
    aliexpress.com:hpc_xc7k325t:1.0

### Digilent Library

We also need to clone Digilent's [vivado-library](https://github.com/Digilent/vivado-library) project from GitHub.

    $ git clone https://github.com/Digilent/vivado-library

<div style="page-break-before: always"></div>

## Block Design

In this section we create the block design for the FPGA board and export
the bitstream file.

 1. Start Vivado
 1. If you have not added the path to the board files, do so now.
 1. Select *Create Project*
 1. Select *Next* in the *New Project* window
 1. Use the `hdmi` for the project name, leave *Create project subdirectory* selected, and click *Next*
 1. Select *RTL Project* with *Do not specify sources at this time* selected, and click *Next*
 1. Select the *Boards* tab, filter on vendor "aliexpress.com", select the *STLV7325T FPGA Development Board*, and click *Next*
 1. Click the *Finish* button.
 1. We are going to add the Digilent IP repository to Vivado
    1. Click the *Settings* icon (a gear).
    1. Select *Project Settings | IP | Repository*
    1. Click the *Plus* icon.
    1. Find and highlight the `vivado-library` directory checked out earlier.
    1. Click the *Select* button.
    1. In the pop-up window, note that it added 64 IPs (maybe more).
    1. Click the *OK* button in the pop-up window.
    1. Click *OK* in the *Settings* window.
 1. In Vivado, under *IP Integrator*, select *Create Block Design*
 1. Use the name `hdmi_microblaze` in the *Create Block Design* window and click *OK*
 1. In the *BLOCK DESIGN* window, select the *Board* tab
 1. Add the 100MHz system clock. This will add a *Clock Wizard* block.
 1. Before running *Connection Automation*, open the *Clock Wizard*.
 1. Switch to the *Output Clocks* tab.
 1. Change the clk_out1 frequency to 148.5MHz
 1. Change the *Reset Type* to *Active Low*.
 1. Click *OK*.
 1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window and then click *OK* to connect the reset button.
 1. Click the *Plus* icon in the the *Diagram* window.
 1. Search for "Video Test Pattern Generator" (TPG) and add it to the block desgin.
 1. Search for "Video Timing Controller" (VTC) and add that to the block design.
 1. Open the *Video Timing Controller* block.
 1. Deselect both "Includ AXI4-lit Interface" and "Enable Detection".
 1. Switch to the *Default/Constant* tab.       
 1. Select "1080p" as the Video Mode and then click "OK".
 1. Search for "AXI4-Stream to Video Out" (SVO) and add that to the block design.
 1. Connect `m_axis_video` of *TPG* to `video_in` of *SVO*.
 1. Connect `vtiming_out` of *VTG* to `timing_in` of *SVO*.
 1. Connect `vtg_cg` of *SVO* to `gen_clken` on the *VTG*.
 1. Connect `sof_state_out` of *SVO* to `sof_state` of the *VTG*.
 1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window, select *All Automation* and then click *OK* to connect the clocks.
 1. Note that this connected a processor system reset.
 1. Search for "Constant" and add that to the block design.
 1. Select the "Constant" block and, in the *Block Properties* window, rename it to "one".
 1. Connect the constant block to the following inputs:
    1. `clken` on the *Video Timing Controller* block
    1. `aclken` on the *AXI4-Stream to Video Out* block
    1. `vid_io_out_ce` on the *AXI4-Stream to Video Out* block
 1. Connect the `aresetn` on the *SVO* to `peripheral_aresetn`.
 1. Connect the `fid` on the *TPG* to the `fid` on the *SVO*.
 1. Add a *MicroBlaze* block to the block design and configure the processor.
    1. Click on *Run Block Automation*.
    1. Select the *Microcontroller* preset.
    1. Change the *Local Memory* to 32KB.
    1. Click *OK*.
    1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window and then click *OK* to connect the AXI slave interface.
    1. Note that this has added an interrupt controller and an concat block for connecting the interrupts.
 1. Add an AXI Timer block to the block design.
 1. Connect the interrupt output of the *AXI Timer* to the interrupt concat block.
 1. Add the USB UART from the Blocks tab as an *AXI Uartlite* device.
 1. Connect the interrupt output of the *AXI Uartlite* to the interrupt concat block.
 1. Double-click the *AXI Uartlite*, switch to the *IP Configuration* tab, change the baud rate to 115200, then click *OK*.
 1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window, select *All Automation* and then click *OK* to connect AXI interfaces.
 1. Add the *HDMI* block from the Blocks tab to the block design. This will add a *RGB to DVI Video Encoder* (Encoder).
 1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window and then click *OK* to connect the PixelClk.
 1. Connect `vid_io_out` from *SVO* to `RGB` on the *Encoder*.
 1. Connect `aRst` on the *Encoder* to `peripheral_reset` on the *Reset Block*.
 1. Double-click the *Encoder* block and change the *MMCM/PLL* setting to *MMCM*.
 1. Verify that the TMDS clock range is set for > 120MHz and click "OK*.
 1. Add the `hdmi.xdc` file from the board repository.
    1. Click on the `Sources` tab.
    1. Click on the `+` icon.
    1. Select the option for *Add or create constraints* and click *Next*
    1. Click the *Add Files* button.
    1. Find the board repository, then find the `constraints` folder, select `hdmi.xdc` and click *OK*.
    1. Click the *Finish* button.
    1. Open the newly added `hdmi.xdc` file in Vivado.
    1. Comment out the first four entries (`hdmi_cec`, `hdmi_hpd`, `hdmi_scl`, and `hdmi_sda`).
    1. Verify that it matches the *Constraints* below.
    1. Save the changes by pressing Ctrl-S.
 1. Create the wrapper script.
    1. Under *Sources|Design Sources* right click on `hdmi_microblaze` and select *Create HDL Wrapper...*.
    1. Verify that *Let Vivada manage wrapper* is selected and click *OK*.
 1. Generate the bitstream.
 1. When the bitstream generation is complete, you can click on *Cancel* in the *Bitstream Generation Completed* pop-up.
 1. Export the hardware design.
    1. Click on *File|Export|Export Hardware...*
    1. Click *Next*.
    1. Select *Include bitstream* and click *Next*.
    1. Use the default values and click *Finish*.

<div style="page-break-before: always"></div>

### Constraints

These are the `hdmi.xdc` constraints.

```xdc
########### HDMI ##########
#set_property -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_cec}]
#set_property -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_hpd}]
#set_property -dict { PACKAGE_PIN K21  IOSTANDARD LVCMOS33 } [get_ports {hdmi_scl}]
#set_property -dict { PACKAGE_PIN L23  IOSTANDARD LVCMOS33 } [get_ports {hdmi_sda}]
set_property -dict { PACKAGE_PIN R21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_p}]
set_property -dict { PACKAGE_PIN P21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_n}]
set_property -dict { PACKAGE_PIN N18  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[0]}]
set_property -dict { PACKAGE_PIN M19  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[0]}]
set_property -dict { PACKAGE_PIN M21  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[1]}]
set_property -dict { PACKAGE_PIN M22  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[1]}]
set_property -dict { PACKAGE_PIN K25  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[2]}]
set_property -dict { PACKAGE_PIN K26  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[2]}]
```
 
### Design

<img src="hdmi.svg" alt="HDMI Block Design" width="800px"/>
 
<div style="page-break-before: always"></div>
 
## Firmware
 
Now that the hardware has been exported, we need to build the firmware that
will run on the Microblaze and configure the test pattern generator.

We are going to assume you do not have an existing Vitis workspace and will
create a new one. If you have an existing one, we assume you are familiar
enough with the tools to work out what to do.

 1. Start Vitis by selecting `Tools | Launch Vitis IDE` in Vivado.
 1. Create a new workspace adjacent to your Vivado project folder called
    `workspace`.
 1. Click on `File|New|Application Project...`
 1. Click *Next* to go to the "Choose your platform" screen.
 1. Click on the *Create a new platform* tab.
 1. Select "Provide your XSA file..." and click on *Browse*.
 1. Navigate to the Vivado `hdmi` project directory, select the `hdmi_microblaze_wrapper.xsa` file, and click *Open*.
 1. Click on *Next*.
 1. Type "hdmi" in the *Application project name* dialog. It will fill in `hdmi_system` in the system project name. Click *Next*.
 1. Select "Standalone" (the default) for the *Operating System* and click *Next*.
 1. Select "Hello World" and click *Finish*.
 1. Double-click the `hdmi_system|hdmi|src|helloworld.c` file.
 1. Replace the contents of the `helloworld.c` file wirh the code from below.
 1. Highlight the "hdmi" folder.
 1. Click the *Build* icon (hammer).

### Program FPGA

We now need to power on the FPGA, connect the programmer, and connect serial and HDMI cables.

 1. Plug the power cable into the FPGA.
 1. Plug in the miniUSB cable to the USB serial port and computer.
 1. Plug in the HDMI cable to the FPGA and monitor.
 1. Turn on the monitor.
 1. Plug the JTAG programmer into the FPGA and connect it to the computer.
 1. Power on the FPGA.
 1. Open a serial terminal. (I use PuTTY.)
 1. Set the baud rate to 115200.
 1. Select the serial port the FPGA is connected to (`/dev/ttyUSB0` for me).
 1. Open the serial console.

And now we will program the FPGA, first with the bitstream, then with the firmware.

 1. Right click on the `hdmi_system` project in the *Explorer* window and select `Program Device`.
 1. Click the *Program* button.
 1. Right clikc on the `hdmi` sub-project in the *Explorer* window and select `Run As|Launch Hardware (Single Application Debug)`
 1. Verify the serial console output matches the output below.
 1. Verify that the color bars are being displayed on the monitor.

And that's it. If you recall from the block design, the test pattern generator
can generate a number of test patterns. Experiment with the code below to
invoke the different test patterns available.

Note that if you do this, you will need to switch to the *Debug* perspective
in Vitis and click the "Disconnect" icon before switching back to the *Design*
perspective to re-launch the firmware.

<div style="page-break-before: always"></div>

### Code

```cxx
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xv_tpg.h"
#include "xvidc.h"

int main()
{
	XV_tpg tpg;
	XV_tpg_Config* ptpg_config;

    init_platform();

    ptpg_config = XV_tpg_LookupConfig(XPAR_V_TPG_0_DEVICE_ID);
    XV_tpg_CfgInitialize(&tpg, ptpg_config, ptpg_config->BaseAddress);

    u32 status, width, height;

    status = XV_tpg_IsReady(&tpg);
    xil_printf("Ready status %lu\r\n", status);

    status = XV_tpg_IsIdle(&tpg);
    xil_printf(" Idle status %lu\r\n", status);

    XV_tpg_Set_height(&tpg, 1080);
    XV_tpg_Set_width(&tpg, 1920);
    XV_tpg_Set_colorFormat(&tpg, XVIDC_CSF_RGB);
    XV_tpg_Set_maskId(&tpg, 0x00);
    XV_tpg_Set_motionSpeed(&tpg, 0x04);
    XV_tpg_Set_bckgndId(&tpg, XTPG_BKGND_COLOR_BARS);
    XV_tpg_EnableAutoRestart(&tpg);
    XV_tpg_Start(&tpg);

    width = XV_tpg_Get_width(&tpg);
    height = XV_tpg_Get_height(&tpg);

    status = XV_tpg_IsDone(&tpg);
    xil_printf(" Done status %lu\r\n", status);

    xil_printf("Resolution is %lux%lu\r\n", width, height);

    print("Successfully displayed color bars\r\n");
    cleanup_platform();
    return 0;
}
```

### Serial Console

```
Ready status 1
 Idle status 1
 Done status 0
Resolution is 1920x1080
Successfully displayed color bars
```


