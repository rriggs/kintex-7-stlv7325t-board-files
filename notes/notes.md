# Notes

These are notes for the creation of the board files for the STLV7325 FPGA
Development board. The goal is to outline the steps required to create the
board files.

Board files are used by Vivado for automation, selecting the correct FPGA
component, and in IP Integrator allowing IP components to be automatically
configured for the various board components. This allows easy configuration
of clocks, GPIOs, network interfaces, DDR RAM, switches, buttons, LEDs, and
many other components.

The documentation of the board file layout is rather sparse. It is relegated
to Appendix A of [Vivado Design Suite User Guide: System-Level Design Entry (UG895)](https://docs.xilinx.com/v/u/2017.3-English/ug895-vivado-system-level-design-entry).

Xilinx now maintains board files on [GitHub](https://github.com/Xilinx/XilinxBoardStore).

There is a [wiki on how to contribute](https://github.com/Xilinx/XilinxBoardStore/wiki/Xilinx-Board-Store-Home).

Much of this work is just adapting what exists in other board files to the
new board and its components. This becomes a bit more challenging when there
are board components which have not been implemented in other board files.

## References

This documents relies on data in the STLV325T schematic, and in the
*XC7K325T_676 FPGA bard GPIO V7.xls* spreadsheet. These are referred
to as either *schematic* or *GPIO spreadsheet* below.

## Preface

This document assumes that you are using Linux, that you are familiar with
FPGA design and with developing projects in Vivado System Integrator, and
that your environment is configured so that Vivado can be found on the PATH.

It also assumes you have a Xilinx JTAG programmer and have a Vivado license
for the FPGA device on the development board.

If you are using Windows, you may need to adjust some paths. But forward
slashes do work in Windows as a path separator and have for decades.

If you have not already sourced the `settings64.sh`, now is the time to
do so. This document assumes that the `vivado` executable can be found
on the PATH.

This document is not designed to help you learn Vivado System Integrator,
FPGA development or how to do anything other than create new board files
for Vivado. It assumes a bit of knowledge on these topics from the reader.

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

## Setup

### Git Repository

The first step in creating the board files is to create a Git repo for hosting
the files. There will be changes and mistakes along the way. Having the work
version controlled will help revert mistakes and allow the project to be
shared with others. I use GitHub to host the Git repo.

https://github.com/rriggs/kintex-7-stlv7325t-board-files

### Board Photo/Image

Take a photograph of the board (or use an existing image) that clearly depicts
the board. It is best if the photo is on a plain white background. The image
must be in JPEG format. An image size of 800x600 pixels works well.

### Licensing

I distribute my board files under the MIT License. I will put separate license
files under directories which contain files which were not authored by me in
order to make it clear that I do not have rights to re-license those items.
Examples are schematics, constraint files and example code from the board
seller.

### Directory Structure

The main board file directory hierarchy looks like this:

 - {board name}
   - {version}
     - {jpeg image file}
     - `board.xml`
     - `part0_pins.xml`
     - `preset.xml`

Note that we will also create constraint files for for the board components
and these will exist at the top level under `constraints`.

 - `constraints`
   - `clock.xdc`
   - ...

The board files are typically copied to the Vivado directory under

    <Vivado Install>/<Vivado_version>/data/boards/board_files/{board_name}/...

You can also tell Vivado where to load the board files from using a TCL
command:

    > set_param board.repoPaths [list "~/kintex-7-stlv7325t-board-files"]

Assuming your Git repo is checked out at `~/kintex-7-stlv7325t-board-files`.

Tcl does not expand the tilde to your home directory in Vivado, so you must
use the full pathname.

You can check that your board file is found by running the TCL command:

    > get_boards
    aliexpress.com:hpc_xc7k325t:1.0  ...

This should work if the XML files are constructed properly. If there is any
sort of error, it is possible that `get_boards` will show the board, but it
will not be visible in Vivado as a board choice. This happened when there
were errors in the XML and when the Xilinx part number was incorrect.

### Validating Board Files

You can validate the board files by running the following Tcl command:

    > validate_board_files hpc-xc7k325t/1.0/
    The board defined in 'hpc-xc7k325t/1.0'  is valid.

This validation only appears to validate that the XML is well formed; that it
conforms to the published XML schemas. It does not validate that the board
files are usable by Vivado.  For example, if the FPGA part number specified
is not a valid Xilinx part, the board files will pass validation, but they
will not be usable in Vivado.

Once a board file is usable by Vivado, creating a project with the board
file allows more detailed validations. Run the command in the Vivado GUI's
Tcl window as changes are made.

So far I have seen no way to get Vivado to apply board file changes without
restarting the GUI.

## Constraints Files

Vivado uses `xdc` constraints files. As we build up the board files, we will
also construct constraints files for the various subsystems.  We are going to
create a separate constraints file for each component group so they can be
easily included into the project as needed.

## XML Files

There are three key XML files that need to be created. This section covers
the minimal file contents to get the board recognized by Vivado with the
correct FPGA part selected. Later sections will go into detail on adding
to these files for full-featured support in Vivado System Integrator.

There are three types of XML files that we will be looking at:

 - board
 - board_part
 - preset
 
 I found XML schema files in `Vivado/2018.3/data/boards/board_schemas` that
 cover all of these.

### board.xml

This is the primary board file. This file describes the board and its various
components.  To start, the only component that is needed is the FPGA device.
This is required by Vivado.

Let's start with the description.

    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <board schema_version="2.1" vendor="aliexpress.com" name="hpc_xc7k325t"
        display_name="STLV7325T FPGA Development Board"
        url="https://www.aliexpress.com/item/3256801088848039.html"
        preset_file="preset.xml">
      <images>
        <image name="hpc-xc7k325t.jpg" display_name="STLV7325T" sub_type="board">
          <description>STLV7325T Board File Image</description>
        </image>
      </images>
      <compatible_board_revisions>
        <revision id="0">1.0</revision>
      </compatible_board_revisions>
      <file_version>1.0</file_version>
      <description>HPC FPGA Store Kintex 7 XC7K325T FPGA Development Board</description>
      ...
    </board>

The `<board>` tag has the following attributes:

 - schema_version -- Always set to "2.1".
 - vendor -- A domain name of the vendor. The vendor does not appear to have
   their own domain, so I use the place where their online store is hosted.
 - name -- this is a short name of the product. I use vendor_part.
 - display_name -- This is what is shown in Vivado when selecting the board.
 - url -- the URL to detailed board information.
 - preset_file -- the Xilinx IP presets. More detail below.

Inside the board tag is an `<images>` tag with one or more image files. There
is typically only one image. The board image is defined using an `<image>`
tag which contains the following attributes:

 - name -- this is the filename of the image. The actual image file must be in
   the same directory as the `board.xml` file.
 - display_name -- this should be a short descriptive name.
 - sub_type -- use `board` here.
 - description -- this should be descriptive text, similar to the `alt`
   attribute on an HTML image.

The `compatible_board_revisions` tag is used for versioning of the board files
and identifying when breaking changes are made. In this case, we start with
1.0 and it is compabity with 1.0.

The `file_version` tag should match the version on the directory structure.
Use semantic versioning here with major and minor version numbers. In general,
minor version increments are for new features and major version increments
are used to indicate breaking changes to existing features.

The `description` tag encloses a detailed board description. I have not see
this used anywhere.

There are two additional sections that require more detailed explanation
that exists where the ellipsis is in the above XML. They are discussed below.

#### Components

The `<components>` section list the various high-level components of the
FPGA board. The most critical component is the FPGA itself.

      <components>
        <component
            name="part0"
            display_name="STLV7325T FPGA Development Board"
            type="fpga"
            part_name="xc7k325tffg676-2"
            pin_map_file="part0_pins.xml"
            vendor="xilinx"
            spec_url="www.aliexpress.com/item/3256801088848039.html">
          <description>FPGA part on the board</description>
        </component>
      </components>

This defines the `part_name` used by Vivado for synthesis. It is critically
important that this is a part name that Vivado knows about and supports. The
parts list in Vivado can be used to verify that it is a known part.

The `pin_map_file` is a filename to a pin mapping file. This is similar to
pin information in a constraints file, and includes pin names and the
IO standard used. More details below.

#### JTAG Chains

The `<jtag_chains>` section lists the JTAG connections on the board.

      <jtag_chains>
        <jtag_chain name="chain1">
          <position name="0" component="part0"/>
        </jtag_chain>
      </jtag_chains>

So far I have only seen this with one `jtag_chain` entry.

### preset.xml

The `preset.xml` file contains configuration information for Xilinx IP
Integrator components. For now we will start with a mostly empty file.

    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <ip_presets schema="1.0">
    </ip_presets>


### part0_pins.xml

The `part0_pins.xml` file contains information about the FPGA's IO pins.
This, too, is basically an empty file to start with.

    <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
    <part_info part_name="xc7k325tff676-2">
        <pins>
        </pins>
    </part_info>

### Validate Board Files

The final step is to validate our board design. Run the following from a
Linux command prompt.

    $ echo "validate_board_files hpc-xc7k325t/1.0" | vivado -mode tcl
    The board defined in 'kintex-7-stlv7325t-board-files/hpc-xc7k325t/1.0'  is valid.


### Summary

At this point, with a basic `board.xml` file and empty `preset.xml` and
`part0_pins.xml` files we can run our first test in Vivado, ensuring that
the board it found and the right part is detected.

Steps:

 1. Start Vivado
 1. At the Tcl Console run the following:
    1. `set_param board.repoPaths [list "<PATH>/kintex-7-stlv7325t-board-files"]`
        - Set the `<PATH>` to the correct path for your environment.
    1. `get_boards`
 1. You should see `aliexpress.com:hpc_xc7k325t:1.0` in the list of boards
    returned.
 1. Click on *Create Project*
 1. Click *Next*
 1. Click *Next*, leaving the project path and name as the default (we are
    not going to actually create the project).
 1. Select *RTL Project* and click *Next*
 1. Select the *Boards* tab in the *Default Part* screen.
 1. In the *Vendor* drop-down, select *aliexpress.com*.
 1. You should see the board listed. Check the image and part information.
 1. Click on *Cancel*.
 
With this we have verified that the board is available to Vivado.

Our next task is to add a few basic components -- clocks, buttons and LEDs
so that we can run *Blinky* on our dev board.

## Clocks, Buttons and LEDs

The board has 4 clocks:
 
 - Y1 -- 200MHz differential
 - Y2 -- 100MHz single-ended
 - Y4 -- 150MHz differential
 - Y5 -- 156.25MHz differential
  
We will add all of these to the board files.

The board also supports another clock at Y3 or an Si5338A arbitrary clock
synthesizer. My board has neither of these populated. And the Si5338A is
currently impossible to source.

The board has 2 user buttons:

 - K2 -- Button 0 (pull-up, NO)
 - K3 -- Button 1 (pull-up, NO)
 
We will add both buttons to the project.

The board has 8 user LEDs, LED0..LED7. There are actually 11 LEDs. There are
3 LEDs that are exposed from the backplate which are linked to LED0..LED2. We
will add all of the LEDs to the board files.

### part0_pins.xml

The first step in this process is to add the pins used by the clocks, buttons
and LEDs to the `part0_pins.xml` file.  We do this by looking at the schematic
and adding each pin.

We will add 7 pins for the clocks (3 differential, 1 single-ended), 2 pins for
the buttons and 8 pins for the LEDs for a total of 17 pins.

#### Clock Pins

Starting with the clock pins we have:

 - SYSCLK_200_P : AB11 : 3V3
 - SYSCLK_200_N : AC11 : 3V3
 - SYSCLK_100   : F17  : 3V3
 - MGTCLK_150_P : F6   : 3V3
 - MGTCLK_150_N : F5   : 3V3
 - MGTCLK_156_P : D6   : 3V3
 - MGTCLK_156_N : D5   : 3V3
 
This is what we need to add for the clock pins:

        <pin index="1" name ="SYSCLK_200_P" iostandard="DIFF_SSTL15" loc="AB11"/>
        <pin index="2" name ="SYSCLK_200_N" iostandard="DIFF_SSTL15" loc="AC11"/>
        <pin index="3" name ="SYSCLK_100" iostandard="LVCMOS33" loc="F17"/>
        <pin index="4" name ="MGTCLK_150_P" iostandard="DIFF_SSTL15" loc="F6"/>
        <pin index="5" name ="MGTCLK_150_N" iostandard="DIFF_SSTL15" loc="F5"/>
        <pin index="6" name ="MGTCLK_156_P" iostandard="DIFF_SSTL15" loc="D6"/>
        <pin index="7" name ="MGTCLK_156_N" iostandard="DIFF_SSTL15" loc="D5"/>

Note that we must always specify the IO standard being used. This information
is available from the schematic, but is easier to glean from the
*GPIO spreadsheet*.

A constraints file for the clocks must also be created. We create the `clock.xdc`
file under the constraints directory.  Here we need to specify the pins used and
set up the clocks with the appropriate period.

    ########### CLOCKS ##########
    #set_property -dict { PACKAGE_PIN AB11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_p]
    #set_property -dict { PACKAGE_PIN AC11 IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_200_n]
    #set_property -dict { PACKAGE_PIN F17  IOSTANDARD LVCMOS33    } [get_ports sysclk_100]
    #set_property -dict { PACKAGE_PIN F6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_p]
    #set_property -dict { PACKAGE_PIN F5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_150_n]
    #set_property -dict { PACKAGE_PIN D6   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_p]
    #set_property -dict { PACKAGE_PIN D5   IOSTANDARD DIFF_SSTL15 } [get_ports sysclk_156_n]

    #create_clock -period  5.000 [get_ports sysclk_200_p]
    #create_clock -period 10.000 [get_ports sysclk_100]
    #create_clock -period  6.667 [get_ports sysclk_150_p]
    #create_clock -period  6.400 [get_ports sysclk_156_p]

This is created with all of the lines commented out. The developer is expected
to uncomment out the lines needed.

#### Button Pins

 - BTN0 : AC16 : 1V5
 - BTN1 : C25  : 2V5
 
Note that these two have different voltage levels.
 
        <pin index="8" name ="BTN0" iostandard="LVCMOS15" loc="AC16"/>
        <pin index="9" name ="BTN1" iostandard="LVCMOS33" loc="C25"/>

One thing to note here (and with the `sysclk_100` above) is that the board
has a jumper which allows the 3.3V banks to be changed to 2.5V. The default
is to use 3.3V, so that is what is set here. There are ways to define this
sort of behavioral switching in the board files. If we get to that, it will
be one of the last things we do.

The `button.xdc` file is just a couple of lines.

    ########### BUTTONS ##########
    set_property -dict { PACKAGE_PIN AC16 IOSTANDARD LVCMOS15 } [get_ports {btn0}]
    set_property -dict { PACKAGE_PIN C24  IOSTANDARD LVCMOS33 } [get_ports {btn1}]


#### LED Pins

We now find the LED pins from the schematic.

 - LED0 : AA2  : 1V5
 - LED1 : AD5  : 1V5
 - LED2 : W10  : 1V5
 - LED3 : Y10  : 1V5
 - LED4 : AE10 : 1V5
 - LED5 : W11  : 1V5
 - LED6 : V11  : 1V5
 - LED7 : Y12  : 1V5

This results in these pin entries.

        <pin index="10" name ="LED0" iostandard="LVCMOS15" loc="AA2"/>
        <pin index="11" name ="LED1" iostandard="LVCMOS15" loc="AD5"/>
        <pin index="12" name ="LED2" iostandard="LVCMOS15" loc="W10"/>
        <pin index="13" name ="LED3" iostandard="LVCMOS15" loc="Y10"/>
        <pin index="14" name ="LED4" iostandard="LVCMOS15" loc="AE10"/>
        <pin index="15" name ="LED5" iostandard="LVCMOS15" loc="W11"/>
        <pin index="16" name ="LED6" iostandard="LVCMOS15" loc="V11"/>
        <pin index="17" name ="LED7" iostandard="LVCMOS15" loc="Y12"/>

Note that we have to maintain the pin index in a monotonically increasing
value. This can be rather painful to maintain if a pin is missed in the
middle of a section.

Finally, our `led.xdc` constraints file looks like this:

    ########### LEDS ##########
    set_property -dict { PACKAGE_PIN AA2  IOSTANDARD LVCMOS15 } [get_ports {led[0]}]
    set_property -dict { PACKAGE_PIN AD5  IOSTANDARD LVCMOS15 } [get_ports {led[1]}]
    set_property -dict { PACKAGE_PIN W10  IOSTANDARD LVCMOS15 } [get_ports {led[2]}]
    set_property -dict { PACKAGE_PIN Y10  IOSTANDARD LVCMOS15 } [get_ports {led[3]}]
    set_property -dict { PACKAGE_PIN AE10 IOSTANDARD LVCMOS15 } [get_ports {led[4]}]
    set_property -dict { PACKAGE_PIN W11  IOSTANDARD LVCMOS15 } [get_ports {led[5]}]
    set_property -dict { PACKAGE_PIN V11  IOSTANDARD LVCMOS15 } [get_ports {led[6]}]
    set_property -dict { PACKAGE_PIN Y12  IOSTANDARD LVCMOS15 } [get_ports {led[7]}]


### preset.xml

We now need to add some presets for these. There are a number of components
that can use the buttons and LEDs: axi\_gpio, iomodule, microblaze\_mcs.
For the clocks, we only care about clk_wiz.

This is going to look like a wall of code. It is unfortunate that this must
be so verbose and repetitive.

      <ip_preset preset_proc_name="sysclk_200_preset">
        <ip vendor="xilinx.com" library="ip" name="clk_wiz" ip_interface="clk_in1_d">
            <user_parameters>
              <user_parameter name="CONFIG.PRIM_IN_FREQ" value="200"/> 
              <user_parameter name="CONFIG.PRIM_SOURCE" value="Differential_clock_capable_pin"/> 
              <user_parameter name="CONFIG.RESET_TYPE" value="ACTIVE_LOW"/>
              <user_parameter name="CONFIG.RESET_PORT" value="resetn"/>
            </user_parameters>
        </ip>
      </ip_preset>

      <ip_preset preset_proc_name="sysclk_100_preset">
        <ip vendor="xilinx.com" library="ip" name="clk_wiz" ip_interface="clk_in1">
            <user_parameters>
              <user_parameter name="CONFIG.PRIM_IN_FREQ" value="100"/> 
              <user_parameter name="CONFIG.PRIM_SOURCE" value="Single_ended_clock_capable_pin"/> 
              <user_parameter name="CONFIG.RESET_TYPE" value="ACTIVE_LOW"/>
              <user_parameter name="CONFIG.RESET_PORT" value="resetn"/>
            </user_parameters>
        </ip>
      </ip_preset>

Push buttons can be configured for axi\_gpio, iomodule and microblaze\_mcs.
There may be other systems that wish to use these buttons. If that happens,
this section can be extended. You will see a lot of repetition and duplication
in the preset.xml file.



Note that the SIZE or WIDTH values here are
set to "2" which is the number of buttons we have.


    <ip_preset preset_proc_name="push_button_preset">
      <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO">
          <user_parameters>
            <user_parameter name="CONFIG.C_GPIO_WIDTH" value="1"/> 
            <user_parameter name="CONFIG.C_ALL_INPUTS" value="1"/> 
	    <user_parameter name="CONFIG.C_ALL_OUTPUTS" value="0"/>
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.C_IS_DUAL" value="1"/> 
            <user_parameter name="CONFIG.C_GPIO2_WIDTH" value="1"/> 
            <user_parameter name="CONFIG.C_ALL_INPUTS_2" value="1"/> 
            <user_parameter name="CONFIG.C_ALL_OUTPUTS_2" value="0"/>
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO1">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI1" value="1"/> 
            <user_parameter name="CONFIG.C_GPI1_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI2" value="1"/> 
            <user_parameter name="CONFIG.C_GPI2_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO3">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI3" value="1"/> 
            <user_parameter name="CONFIG.C_GPI3_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO4">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI4" value="1"/> 
            <user_parameter name="CONFIG.C_GPI4_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO1">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI1" value="1"/> 
            <user_parameter name="CONFIG.GPI1_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI2" value="1"/> 
            <user_parameter name="CONFIG.GPI2_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO3">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI3" value="1"/> 
            <user_parameter name="CONFIG.GPI3_SIZE" value="1"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO4">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI4" value="1"/> 
            <user_parameter name="CONFIG.GPI4_SIZE" value="1"/> 
          </user_parameters>
      </ip>
    </ip_preset>

    <ip_preset preset_proc_name="push_buttons_preset">
      <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO">
          <user_parameters>
            <user_parameter name="CONFIG.C_GPIO_WIDTH" value="2"/> 
            <user_parameter name="CONFIG.C_ALL_INPUTS" value="1"/> 
	        <user_parameter name="CONFIG.C_ALL_OUTPUTS" value="0"/>
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.C_IS_DUAL" value="1"/> 
            <user_parameter name="CONFIG.C_GPIO2_WIDTH" value="2"/> 
            <user_parameter name="CONFIG.C_ALL_INPUTS_2" value="1"/> 
  	    <user_parameter name="CONFIG.C_ALL_OUTPUTS_2" value="0"/>
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO1">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI1" value="1"/> 
            <user_parameter name="CONFIG.C_GPI1_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI2" value="1"/> 
            <user_parameter name="CONFIG.C_GPI2_SIZE" value="2"/> 
           </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO3">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI3" value="1"/> 
            <user_parameter name="CONFIG.C_GPI3_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO4">
          <user_parameters>
            <user_parameter name="CONFIG.C_USE_GPI4" value="1"/> 
            <user_parameter name="CONFIG.C_GPI4_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO1">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI1" value="1"/> 
            <user_parameter name="CONFIG.GPI1_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO2">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI2" value="1"/> 
            <user_parameter name="CONFIG.GPI2_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO3">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI3" value="1"/> 
            <user_parameter name="CONFIG.GPI3_SIZE" value="2"/> 
          </user_parameters>
      </ip>
      <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO4">
          <user_parameters>
            <user_parameter name="CONFIG.USE_GPI4" value="1"/> 
            <user_parameter name="CONFIG.GPI4_SIZE" value="2"/> 
          </user_parameters>
      </ip>
    </ip_preset>

As you can imagine, the LEDs inteface looks very similar.

      <ip_preset preset_proc_name="leds_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO">
            <user_parameters>
              <user_parameter name="CONFIG.C_GPIO_WIDTH" value="8"/> 
              <user_parameter name="CONFIG.C_ALL_OUTPUTS" value="1"/> 
              <user_parameter name="CONFIG.C_ALL_INPUTS" value="0"/>
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.C_IS_DUAL" value="1"/> 
              <user_parameter name="CONFIG.C_GPIO2_WIDTH" value="8"/> 
              <user_parameter name="CONFIG.C_ALL_OUTPUTS_2" value="1"/> 
	      <user_parameter name="CONFIG.C_ALL_INPUTS_2" value="0"/>
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO1">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO1" value="1"/> 
              <user_parameter name="CONFIG.C_GPO1_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO2" value="1"/> 
              <user_parameter name="CONFIG.C_GPO2_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO3">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO3" value="1"/> 
              <user_parameter name="CONFIG.C_GPO3_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO4">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO4" value="1"/> 
              <user_parameter name="CONFIG.C_GPO4_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO1">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO1" value="1"/> 
              <user_parameter name="CONFIG.GPO1_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO2" value="1"/> 
              <user_parameter name="CONFIG.GPO2_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO3">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO3" value="1"/> 
              <user_parameter name="CONFIG.GPO3_SIZE" value="8"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO4">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO4" value="1"/> 
              <user_parameter name="CONFIG.GPO4_SIZE" value="8"/> 
            </user_parameters>
        </ip>
      </ip_preset>

Now, the question should arise -- where do all of these IP names and
interfaces come from and where are the valid values defined? There are two
answers. The simple answer is that these are the set of intefaces and values
used in other board files distributed by Xilinx and other vendors via the
GitHub link listed earlier in this document.

The more complicated answer is that the parameters are documented in the
various Xilinx IP product guides.  For example,
[AXI GPIO v2.0 Product Guide(PG144)](https://docs.xilinx.com/v/u/en-US/pg144-axi-gpio)
lists the *User Parameters* in chapter 4, table 4.1.

There is also a dependency here on *interface* definitions on the FPGA in the
`boards.xml` file below and the presets above. The interface for these pins
are defined as `gpio_rtl` and that requires that the IP uses the `gpio_rtl`
interface. Otherwise system integrator will refuse to connect them. This is
quite a limitation as I see no way to, for example, connect the LEDs to a
`util_vector_logic` block configured as an inverter.

### board.xml

We now need to start adding interfaces, components and connects to the
`board.xml` file. This is where the part pins get mapped to interfaces.

This process is a bit complicated and, in my opinion, not at all well
documented.

#### System Clocks

Let's start by adding the interfaces for the system clocks. These are all
interfaces for the FPGA chip itself, and therefore listed inside that
component. Think of the interface as how one component (the FPGA) talks
to other components on the board.

The interface *type*, in this case `xilinx.com:interface:diff_clock_rtl:1.0`
for the 200MHz differential clock 

      <components>
        <component name="part0" display_name="STLV7325T FPGA Development Board" type="fpga" part_name="xc7k325tffg676-2" pin_map_file="part0_pins.xml" vendor="xilinx" spec_url="www.aliexpress.com/item/3256801088848039.html">
          <description>FPGA part on the board</description>
          <interfaces>
          
            <interface mode="slave" name="sysclk_200" type="xilinx.com:interface:diff_clock_rtl:1.0" of_component="sysclk_200" preset_proc="sysclk_200_preset">
              <parameters>
                <parameter name="frequency" value="200000000"/>
              </parameters>
              <preferred_ips>
                <preferred_ip vendor="xilinx.com" library="ip" name="clk_wiz" order="0"/>
              </preferred_ips>
              <port_maps>
                <port_map logical_port="CLK_P" physical_port="SYSCLK_200_P" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="SYSCLK_200_P"/>
                  </pin_maps>
                </port_map>
                <port_map logical_port="CLK_N" physical_port="SYSCLK_200_N" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="SYSCLK_200_N"/>
                  </pin_maps>
                </port_map>
              </port_maps>
            </interface>

            <interface mode="slave" name="sysclk_100" type="xilinx.com:signal:clock_rtl:1.0" of_component="sysclk_100" preset_proc="sysclk_100_preset">
              <parameters>
                <parameter name="frequency" value="100000000"/>
              </parameters>
              <preferred_ips>
                <preferred_ip vendor="xilinx.com" library="ip" name="clk_wiz" order="0"/>
              </preferred_ips>
              <port_maps>
                <port_map logical_port="CLK" physical_port="SYSCLK_100" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="SYSCLK_100"/>
                  </pin_maps>
                </port_map>
              </port_maps>
            </interface>

            <interface mode="slave" name="mgt_clock_156" type="xilinx.com:interface:diff_clock_rtl:1.0" of_component="mgt_clock_156">
              <parameters>
                <parameter name="type" value="SFP_MGT_CLK"/>
                <parameter name="frequency" value="156250000"/>
              </parameters>
              <preferred_ips>
                <preferred_ip vendor="xilinx.com" library="ip" name="axi_ethernet" order="0"/>
                <preferred_ip vendor="xilinx.com" library="ip" name="clk_wiz" order="1"/>
             </preferred_ips>
              <port_maps>
                <port_map logical_port="CLK_P" physical_port="mgt_clock_156_p" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="MGTCLK_156_P"/>
                  </pin_maps>
                </port_map>
                <port_map logical_port="CLK_N" physical_port="mgt_clock_156_n" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="MGTCLK_156_N"/>
                  </pin_maps>
                </port_map>
              </port_maps>
            </interface>
       
            <interface mode="slave" name="mgt_clock_150" type="xilinx.com:interface:diff_clock_rtl:1.0" of_component="mgt_clock_156">
              <parameters>
                <parameter name="type" value="SATA_MGT_CLK"/>
                <parameter name="frequency" value="150000000"/>
              </parameters>
              <preferred_ips>
                <preferred_ip vendor="xilinx.com" library="ip" name="clk_wiz" order="1"/>
             </preferred_ips>
              <port_maps>
                <port_map logical_port="CLK_P" physical_port="mgt_clock_150_p" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="MGTCLK_150_P"/>
                  </pin_maps>
                </port_map>
                <port_map logical_port="CLK_N" physical_port="mgt_clock_150_n" dir="in">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="MGTCLK_150_N"/>
                  </pin_maps>
                </port_map>
              </port_maps>
            </interface>
     
          </interfaces>
        </component>
        ...
      </components>

Here we have added 4 slave interfaces to the FPGA, a differential 200MHz
clock, a single-ended 100MHz clock, plus the two MGT clocks. Note that the
`preset_proc` name corresponds to the entry in the `preset.xml` file.  And
the physical port names correspond to the names of the pins in the
`part0_pins.xml` file.

Next we need to add the components for these. We add these where the elipsis
are in the XML above.

        <component name="sysclk_200" display_name="200MHz system differential clock" type="chip" sub_type="system_clock" major_group="Clock Sources">
          <description>2.5V LVDS differential 200 MHz oscillator used as system clock on the board</description>
          <parameters>
            <parameter name="frequency" value="200000000"/>
          </parameters>
        </component>

        <component name="sysclk_100" display_name="100MHz system single-ended clock" type="chip" sub_type="system_clock" major_group="Clock Sources">
          <description>2.5V single-ended 100 MHz oscillator used as system clock on the board</description>
          <parameters>
            <parameter name="frequency" value="100000000"/>
          </parameters>
        </component>

        <component name="mgt_clock_156" display_name="SFP 156.25MHz MGT CLOCK" type="chip" sub_type="mgt_clock" major_group="Clock Sources">
          <description>Ethernet 156.25 MHz MGT Clock</description>
          <parameters>
            <parameter name="frequency" value="156250000"/>
          </parameters>
        </component>

        <component name="mgt_clock_150" display_name="SATA 150MHz MGT CLOCK" type="chip" sub_type="mgt_clock" major_group="Clock Sources">
          <description>SATA MHz MGT Clock</description>
          <parameters>
            <parameter name="frequency" value="156250000"/>
          </parameters>
        </component>

The `major_group` attribute will group these together in the user interface.

The next step is to connect these together. Below the `<components>` section
we add a `<connections>` section.

      <connections>
        <connection name="part0_sysclk200" component1="part0" component2="sysclk_200">
          <connection_map name="part0_sysclk200" typical_delay="5" c1_st_index="1" c1_end_index="2" c2_st_index="0" c2_end_index="1"/>
        </connection>
        <connection name="part0_sysclk133" component1="part0" component2="sysclk_100">
          <connection_map name="part0_sysclk100" typical_delay="5" c1_st_index="3" c1_end_index="3" c2_st_index="0" c2_end_index="0"/>
        </connection>
      </connections>

These connections map connections from one component to another. The
`c1_st_index` (start index) and `c1_end_index` correspond to the index in the
`part0_pins.xml` file. The c2 versions of these correspond to somthing, but
that is not clearly defined anywhere. Virtual pins on the components?

At this point we can create a project in Vivado, open a block design, go to
the *Board* tab and see the four clocks we have defined. These can be added to
a block design

#### Buttons

Like with the clocks, we need to add the interface to the FPGA part, the
components representing the buttons, and the connections. One design decision
we are going to make here is that we are going to make BTN0 the reset button.

This leads to a complication. What if we don't want a reset button and need
two push buttons. In that case we define overlapping interfaces and components.
Vivado will detect this and refuse to add conflicting components.

        <interface mode="slave" name="reset_button" type="xilinx.com:signal:reset_rtl:1.0" of_component="reset_button">
          <parameters>
            <parameter name="rst_polarity" value="0"/>
          </parameters>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="proc_sys_reset" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="RST" physical_port="BTN0" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="BTN0"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
 
        <interface mode="master" name="push_button" type="xilinx.com:interface:gpio_rtl:1.0" of_component="push_button" preset_proc="push_button_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_gpio" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TRI_I" physical_port="push_button_tri_i" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="BTN1"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

        <interface mode="master" name="push_buttons" type="xilinx.com:interface:gpio_rtl:1.0" of_component="push_buttons" preset_proc="push_buttons_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_gpio" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TRI_I" physical_port="push_buttons_tri_i" dir="in" left="1" right="0">
              <pin_maps>
                <pin_map port_index="0" component_pin="BTN0"/>
                <pin_map port_index="1" component_pin="BTN1"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

Here we have added a reset and single GPIO button, as well as a pair of GPIO
buttons. Vivado will allow you to add the reset and/or single button, or the
pair of buttons, but not resources which conflict.

Now add the components for these buttons.

        <component name="reset_button" display_name="System Reset" type="chip" sub_type="system_reset" major_group="Reset">
          <description>Push Button K2, Active Low</description>
        </component>

        <component name="push_button" display_name="Push buttons" type="chip" sub_type="push_button" major_group="General Purpose Input or Output">
          <description>Push Button K3, Active Low</description>
        </component>

        <component name="push_buttons" display_name="Push buttons" type="chip" sub_type="push_button" major_group="General Purpose Input or Output">
          <description>Push Buttons K2, K3 Active Low</description>
        </component>

And then the connections. Note the overlapping connections here.

        <connection name="part0_reset_button" component1="part0" component2="reset_button">
          <connection_map name="part0_reset" typical_delay="5" c1_st_index="8" c1_end_index="8" c2_st_index="0" c2_end_index="0"/>
        </connection>
        <connection name="part0_push_button" component1="part0" component2="push_button">
          <connection_map name="part0_push_button" typical_delay="9" c1_st_index="9" c1_end_index="9" c2_st_index="0" c2_end_index="0"/>
        </connection>
        <connection name="part0_push_buttons" component1="part0" component2="push_buttons">
          <connection_map name="part0_push_buttons" typical_delay="5" c1_st_index="8" c1_end_index="9" c2_st_index="0" c2_end_index="1"/>
        </connection>

#### LEDs

And finally for this step we add the 8/3 LEDs.

The interface is fairly straight-forward.

            <interface mode="master" name="leds" type="xilinx.com:interface:gpio_rtl:1.0" of_component="leds" preset_proc="leds_preset">
              <preferred_ips>
                <preferred_ip vendor="xilinx.com" library="ip" name="axi_gpio" order="0"/>
              </preferred_ips>
              <port_maps>
                <port_map logical_port="TRI_O" physical_port="leds_tri_o" dir="out" left="7" right="0">
                  <pin_maps>
                    <pin_map port_index="0" component_pin="LED0"/>
                    <pin_map port_index="1" component_pin="LED1"/>
                    <pin_map port_index="2" component_pin="LED2"/>
                    <pin_map port_index="3" component_pin="LED3"/>
                    <pin_map port_index="4" component_pin="LED4"/>
                    <pin_map port_index="5" component_pin="LED5"/>
                    <pin_map port_index="6" component_pin="LED6"/>
                    <pin_map port_index="7" component_pin="LED7"/>
                  </pin_maps>
                </port_map>
              </port_maps>
            </interface>

As is the component.

        <component name="leds" display_name="Board LEDs" type="chip" sub_type="led" major_group="General Purpose Input or Output">
          <description>LEDs 7 to 0, Active Low; 2 to 0 are also visible externally.</description>
        </component>

And the connection map.

    <connection name="part0_leds" component1="part0" component2="leds">
      <connection_map name="part0_leds" typical_delay="5" c1_st_index="10" c1_end_index="17" c2_st_index="0" c2_end_index="7"/>
    </connection>

### Blinky

At this point our board files are ready for us to create a Blinky in Vivado
System Integrator.

Here are the steps.

 1. Create a directory called `projects`
 1. `$ cd projects`
 1. Start Vivado
 1. Select *Create Project*
 1. Select *Next* in the *New Project* window
 1. Use the defaults for the project name and click *Next*
 1. Select *RTL Project* and click *Next*
 1. Select the *Boards* tab, filter on vendor "aliexpress.com", select the *STLV7325T FPGA Development Board*, and click *Next*
 1. In Vivado, under *IP Integrator*, select *Create Block Design*
 1. Use the default name in the *Create Block Design* window and click *OK*
 1. In the *BLOCK DESIGN* window, select the *Board* tab
 1. Drag the *200MHz system differential clock* to the *Diagram* window
 1. Notice that a *Clocking Wizard* was created and connected to the clock pins; click *OK* in the *Auto Connect* window
 1. Double-click the *Clocking Wizard* block
 1. In the *Output Clocks* tab, disable the *Reset* input
 1. Change the *clk_out1* output frequency to *250MHz* then click *OK*
 1. Add an *Accumulator* IP block to the block design and double click to customize it
 1. Change the *Input Type* to `unsigned`, the *Input Width* to `1` bit, and the *Output Width* to `32` bits
 1. In the *Control* tab, enable *Synchonous Clear (SCLR)* and disable *Bypass* then click *OK*
 1. Click *Run Connection Automation* in the green bar at the top of the *Diagram* window and click *OK*
 1. Note the following changes:
    1. A *Processor System Reset* was added
    1. The *locked* signal from the *Clocking Wizard* was connected to the *dcm_locked* pin of the *Reset* block
    1. The *peripheral reset* signal was connected to the *SCLR* of the *Accumulator*
    1. The *clk_out1* pin was connected to both the *Accumulator* and the *Reset* blocks
 1. Click *Run Connection Automation* again and click *OK*
 1. Note the following changes:
    1. The *reset button* was added
    1. This is connected to inverting *ext_reset_in* pin of the *Reset* block
 1. Add a *Constant* IP block to the block design and connect *dout* to *B* on the *Accumulator*
 1. Connect *clk_out1* to *CLK* on the *Accumulator*
 1. Add a *Slice* IP block to the block design and connect *Q* on the *Accumulator* to *Din* on the *Slice*
 1. Double-click the *Slice* block
 1. Change *Din From* to `31` and *Din Down To* to `24` then click *OK*
 1. Add a *Utility Vector Logic* IP block to the block design
 1. Double click the *Utility Vector Logic* block
 1. Change the operation to *not* and click *OK*
 1. Connect the output of the *Slice* block to the input of the *Utility Vector Logic* block
 1. Right click on the ouput pin of the *Utility Vector Logic* block and select *Make External*
 1. Select the newly created port and in the *External Port Properties* window, change the name to `led`
 1. Under the *Sources* tab, add a new constraint source
 1. Find the `led.xdc` file and add it
 1. Under *Design Sources*, right click the `design_1.bd` file and select *Generate HDL Wrapper...* and click *OK* in the dialog
 1. Click *Generate Bitstream* and take a short break
 1. When the bitstream is ready, select *Open Hardware Manager* and connect to the target
    1. Ensure that the JTAG programmer is connected to the board and to the computer
    1. Ensure that the FPGA board has power and is turned on
 1. Select *Program Device*
 1. You should notice that the LEDs on the board are acting as a binary counter and that pressing the button labelled *K2* resets the counter

You can export the block design diagram as an SVG file from the Tcl console.

    write_bd_layout -format svg -orientation portrait -force blinky.svg

## Next Steps

Now that we have a working basic board file. we will add start adding support
for the other components on the board.  The goal is to get UART and Ethernet
supported so we can add a Microblaze microcontroller, then RAM and other
components so we can support Linux on the Microblaze.

At that point is should be possible to also get a RISC-V core supported:
https://github.com/eugene-tarassov/vivado-risc-v

The KC705 board uses the same FPGA as this board.

Lastly we want to supoprt HDMI, SATA, PCIA, and the board connectors.

 * UART
 * I2C EEPROM
 * QSPI Flash
 * SD Card
 * Ethernet ports
 * DDR RAM (SODIMM)
 * SFP+ ports
 * HDMI
 * SATA
 * PCIe
 * 0.1" Connectors
 * 0.8mm Board-to-Board connector (80-pin)
 * FMC-LPC Connector
 

## UART

In this section we are going to add the USB serial interface to our board
files and a `uart.xdc` constraints file. The UART is provided by a CH340G
USB to TTL RS232 chip.

 - UART_TX : M25  : 3V3
 - UART_RX : L25  : 3V3

The CTS/RTS and DTR/DSR pins on the CH340G are not connected.

### Pins

        <pin index="18" name ="UART_TX" iostandard="LVCMOS33" loc="M25"/>
        <pin index="19" name ="UART_RX" iostandard="LVCMOS33" loc="L25"/>

### Constraints

    ########### UART ##########
    set_property -dict { PACKAGE_PIN M25  IOSTANDARD LVCMOS33 } [get_ports {uart_tx}]
    set_property -dict { PACKAGE_PIN L25  IOSTANDARD LVCMOS33 } [get_ports {uart_rx}]

### Presets

  <ip_preset preset_proc_name="usb_uart_preset">
    <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="UART">
        <user_parameters>
          <user_parameter name="CONFIG.C_USE_UART_RX" value="1"/> 
          <user_parameter name="CONFIG.C_USE_UART_TX" value="1"/> 
        </user_parameters>
    </ip>
    <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="UART">
        <user_parameters>
          <user_parameter name="CONFIG.USE_UART_RX" value="1"/> 
          <user_parameter name="CONFIG.USE_UART_TX" value="1"/> 
        </user_parameters>
    </ip>
  </ip_preset>

### Board

#### Interface

        <interface mode="master" name="usb_uart" type="xilinx.com:interface:uart_rtl:1.0" of_component="usb_uart" preset_proc="usb_uart_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_uartlite" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TxD" physical_port="uart_tx" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="UART_TX"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RxD" physical_port="uart_rx" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="UART_RX"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

#### Component

        <component name="usb_uart" display_name="USB UART" type="chip" sub_type="uart" major_group="Miscellaneous" part_name="CH340G" vendor="Nanjing Qinheng Microelectronics Co., Ltd.">
          <description>USB-to-UART Bridge, which allows a connection to a host computer with a USB port</description>
        </component>

#### Connection

        <connection name="part0_usb_uart" component1="part0" component2="usb_uart">
          <connection_map name="part0_usb_uart" typical_delay="5" c1_st_index="18" c1_end_index="19" c2_st_index="0" c2_end_index="1"/>
        </connection>

### Hello, World!

We should test our new UART interface by creating a Microblaze project with
a UART and run a "Hello World" application on the systems, connecting to the
UART with a serial terminal application like CuteCom.

## I2C EEPROM

There is a small AT24C04 4kb (512 byte) I2C EEPROM on the board. This can be
used to store non-volatile board-specific information that will survive
reprogramming of the FPGA. This is useful for things like MAC addresses or
encryption keys.

Like the USB UART earlier, this requires only two pins.

### Pins

        <pin index="20" name ="EEPROM_SCL" iostandard="LVCMOS33" loc="U19"/>
        <pin index="21" name ="EEPROM_SDA" iostandard="LVCMOS33" loc="U20"/>

### Constraints

    ########### I2C EEPROM ##########
    set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS33 } [get_ports {eeprom_scl}]
    set_property -dict { PACKAGE_PIN U20  IOSTANDARD LVCMOS33 } [get_ports {eeprom_sda}]

### Presets

None

### Board

#### Interface

        <interface mode="master" name="iic_eeprom" type="xilinx.com:interface:iic_rtl:1.0" of_component="iic_eeprom">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_iic" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="SDA_I" physical_port="sda_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_O" physical_port="sda_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_T" physical_port="sda_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_I" physical_port="scl_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_O" physical_port="scl_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_T" physical_port="scl_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="EEPROM_SCL"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

#### Component

        <component name="iic_eeprom" display_name="IIC 24C04 EEPROM" type="chip" sub_type="memory" major_group="External Memory">
          <description>I2C 24C04 EEPROM</description>
        </component>

#### Connection

        <connection name="part0_iic_eeprom" component1="part0" component2="iic_eeprom">
          <connection_map name="part0_iic_eeprom" typical_delay="5" c1_st_index="20" c1_end_index="21" c2_st_index="0" c2_end_index="1"/>
        </connection>

## QSPI Flash

The QSPI Flash chip is used to store the FPGA bitstream and memory contents,
and may include things like bootloaders and root filesystems for embedded
Linux.

### Pins

        <pin index="22" name ="QSPI_D0"  iostandard="LVCMOS33" loc="B24"/>
        <pin index="23" name ="QSPI_D1"  iostandard="LVCMOS33" loc="A25"/>
        <pin index="24" name ="QSPI_D2"  iostandard="LVCMOS33" loc="B22"/>
        <pin index="25" name ="QSPI_D3"  iostandard="LVCMOS33" loc="A22"/>
        <pin index="26" name ="QSPI_CS"  iostandard="LVCMOS33" loc="C23"/>
        <pin index="27" name ="QSPI_CLK" iostandard="LVCMOS33" loc="C8"/>

### Constraints

    ########### QSPI FLASH ##########
    set_property -dict { PACKAGE_PIN B24  IOSTANDARD LVCMOS33 } [get_ports {qspi_d0}]
    set_property -dict { PACKAGE_PIN A25  IOSTANDARD LVCMOS33 } [get_ports {qspi_d1}]
    set_property -dict { PACKAGE_PIN B22  IOSTANDARD LVCMOS33 } [get_ports {qspi_d2}]
    set_property -dict { PACKAGE_PIN A22  IOSTANDARD LVCMOS33 } [get_ports {qspi_d3}]
    set_property -dict { PACKAGE_PIN C23  IOSTANDARD LVCMOS33 } [get_ports {qspi_cs}]
    set_property -dict { PACKAGE_PIN C8   IOSTANDARD LVCMOS33 } [get_ports {qspi_clk}]

### Presets

      <ip_preset preset_proc_name="qspi_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_quad_spi">
          <user_parameters>
            <user_parameter name="CONFIG.C_SPI_MEMORY" value="2"/>
            <user_parameter name="CONFIG.C_SPI_MODE" value="2"/>
            <user_parameter name="CONFIG.C_C_SCK_RATIO" value="2"/>
            <user_parameter name="CONFIG.C_USE_STARTUP" value="1"/>
            <user_parameter name="CONFIG.C_USE_STARTUP_INT" value="1"/>
          </user_parameters>
        </ip>
      </ip_preset>

### Board

#### Interface

        <interface mode="master" name="qspi_flash" type="xilinx.com:interface:spi_rtl:1.0" of_component="qspi_flash" preset_proc="qspi_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_quad_spi" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="IO0_I" physical_port="spi_io0_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D0"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO0_O" physical_port="spi_io0_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D0"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO0_T" physical_port="spi_io0_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D0"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO1_I" physical_port="spi_io1_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D1"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO1_O" physical_port="spi_io1_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D1"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO1_T" physical_port="spi_io1_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D1"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO2_I" physical_port="spi_io2_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D2"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO2_O" physical_port="spi_io2_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D2"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO2_T" physical_port="spi_io2_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D2"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO3_I" physical_port="spi_io3_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D3"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO3_O" physical_port="spi_io3_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D3"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO3_T" physical_port="spi_io3_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_D3"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SS_I" physical_port="spi_ss_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CS"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SS_O" physical_port="spi_ss_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CS"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SS_T" physical_port="spi_ss_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CS"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCK_I" physical_port="spi_clk_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CLK"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCK_O" physical_port="spi_clk_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CLK"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCK_T" physical_port="spi_clk_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="QSPI_CLK"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

#### Component

        <component name="qspi_flash" display_name="QSPI Flash" type="chip" sub_type="memory_flash_qspi" major_group="External Memory" part_name="N25Q256-3.3V">
          <description>256Mb (32MB) of nonvolatile storage that can be used for configuration or data storage</description>
        </component>

#### Connection

        <connection name="part0_qspi_flash" component1="part0" component2="qspi_flash">
          <connection_map name="part0_qspi_flash" typical_delay="5" c1_st_index="22" c1_end_index="27" c2_st_index="0" c2_end_index="5"/>
        </connection>

## SD Card

The board has an SD Card connector, along with a 4-bit SDIO interface. However,
there are no free AXI SDIO controller IPs available. So for now we need to
use SPI mode, which is what the board's SD Card test application does. This is
quite slow compared to SDIO.

### Pins

We are going to define the pins in the pins file using SDIO pin names.
We just need to be careful with the ordering, since the *connection map*
requires consecutive pins, otherwise we have to define custom pins.
        
        <pin index="28" name ="SD_D0"  iostandard="LVCMOS33" loc="N16"/>
        <pin index="29" name ="SD_D1"  iostandard="LVCMOS33" loc="U16"/>
        <pin index="30" name ="SD_CMD" iostandard="LVCMOS33" loc="U21"/>
        <pin index="31" name ="SD_CLK" iostandard="LVCMOS33" loc="N21"/>
        <pin index="32" name ="SD_D2"  iostandard="LVCMOS33" loc="N22"/>
        <pin index="33" name ="SD_D3"  iostandard="LVCMOS33" loc="P19"/>

### Constraints

For the constraints, we will define two overlapping interfaces with different
pin names. The user can choose which to uncomment.

    ########### SD CARD ##########
    # SDIO Interface
    #set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 } [get_ports {sd_d0}]
    #set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {sd_d1}]
    #set_property -dict { PACKAGE_PIN N22  IOSTANDARD LVCMOS33 } [get_ports {sd_d2}]
    #set_property -dict { PACKAGE_PIN P19  IOSTANDARD LVCMOS33 } [get_ports {sd_d3}]
    #set_property -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 } [get_ports {sd_cmd}]
    #set_property -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 } [get_ports {sd_clk}]

    # SPI Interface
    #set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 } [get_ports {sd_do}]
    #set_property -dict { PACKAGE_PIN P19  IOSTANDARD LVCMOS33 } [get_ports {sd_cs}]
    #set_property -dict { PACKAGE_PIN U21  IOSTANDARD LVCMOS33 } [get_ports {sd_di}]
    #set_property -dict { PACKAGE_PIN N21  IOSTANDARD LVCMOS33 } [get_ports {sd_clk}]

### Presets

      <ip_preset preset_proc_name="qspi_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_quad_spi">
          <user_parameters>
            <user_parameter name="CONFIG.C_SPI_MEMORY" value="2"/>
            <user_parameter name="CONFIG.C_SPI_MODE" value="0"/>
            <user_parameter name="CONFIG.C_C_SCK_RATIO" value="2"/>
            <user_parameter name="CONFIG.C_USE_STARTUP" value="1"/>
            <user_parameter name="CONFIG.C_USE_STARTUP_INT" value="1"/>
          </user_parameters>
        </ip>
      </ip_preset>

### Board

#### Interface

The interface is a simple 4-wire SPI interface.

        <interface mode="master" name="sd_card" type="xilinx.com:interface:spi_rtl:1.0" of_component="sd_card" preset_proc="sdcard_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_quad_spi" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="IO0_O" physical_port="sd_do" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="SD_D0"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SS_O" physical_port="sd_ss" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="SD_D1"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="IO1_I" physical_port="sd_di" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="SD_CMD"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCK_O" physical_port="sd_clk" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="SD_CLK"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>


#### Component

        <component name="sd_card" display_name="SD Card" type="chip" sub_type="memory" major_group="External Memory">
          <description>256Mb (32MB) of nonvolatile storage that can be used for configuration or data storage</description>
        </component>

#### Connection

    <connection name="part0_sd_card" component1="part0" component2="sd_card">
      <connection_map name="part0_sd_card" typical_delay="5" c1_st_index="28" c1_end_index="31" c2_st_index="0" c2_end_index="3"/>
    </connection>

## DDR RAM

The last memory interface we need to add is the DDR3 SDRAM. This is a bit
different than the others.  All of this information is defined in a MIG
(Memory Interface Controller) project file.

Luckily, the board came with MIG files as part of its suite of test programs.
The only issue that I ran into was that it was designed for a `NATIVE`
interface, and we need an `AXI` interface for our board package.

For that I just used the configuration from one of the MIG files from the
`hpc-kc7k420t` board.

We do not need to define pins, constraints or connections. These are either
handled by the MIG configuration or directly inferred.

### MIG Project File

These are the AXI configuration parameters I added to the existing MIG.

        <PortInterface>AXI</PortInterface>
        <AXIParameters>
          <C0_C_RD_WR_ARB_ALGORITHM>RD_PRI_REG</C0_C_RD_WR_ARB_ALGORITHM>
          <C0_S_AXI_ADDR_WIDTH>30</C0_S_AXI_ADDR_WIDTH>
          <C0_S_AXI_DATA_WIDTH>128</C0_S_AXI_DATA_WIDTH>
          <C0_S_AXI_ID_WIDTH>4</C0_S_AXI_ID_WIDTH>
          <C0_S_AXI_SUPPORTS_NARROW_BURST>0</C0_S_AXI_SUPPORTS_NARROW_BURST>
        </AXIParameters>


### Presets

The presets tell Vivado which MIG project file to load. In this case we use
the 1066MHz DDR3 version.  Note that for this version I only include the
1066MHz version. The board files include a MIG file for 1600MHz (PC12800)
DDR3. My board does not have this, so I did not include it.

      <ip_preset preset_proc_name="ddr3_sdram_preset">
        <ip vendor="xilinx.com" library="ip" name="mig_7series">
          <user_parameters>
            <user_parameter name="CONFIG.XML_INPUT_FILE" value="mig_ddr3_1066.prj" value_type="file"/> 
          </user_parameters>
        </ip>
      </ip_preset>

### Board

#### Interface

We must include the preset here for the MIG configuration.

        <interface mode="master" name="ddr3_sdram" type="xilinx.com:interface:ddrx_rtl:1.0" of_component="ddr3_sdram" preset_proc="ddr3_sdram_preset">
          <description>DDR3 board interface, it can use MIG IP for connection. </description>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="mig_7series" order="0"/>
          </preferred_ips>
        </interface>

#### Component

The component needs to specify the DDR type and the size.

        <component name="ddr3_sdram" display_name="DDR3 SDRAM" type="chip" sub_type="ddr" major_group="External Memory" part_name="M471B2874DZ1-CF8" vendor="Samsung">
          <description>1 GB DDR3 memory SODIMM </description>
          <parameters>
            <parameter name="ddr_type" value="ddr3"/>
            <parameter name="size" value="1GB"/>
          </parameters>
        </component>

### Memory Test

Vitis includes a Memory Test example program that should be run at this point
to ensure that DDR3 memory is working correctly.

### Notes

DDR3 memory is needed to test the Ethernet and SFP+ ports.

## Ethernet Ports

Ethernet ports have quite a few signal/pins to map. There are 26 pins per
port. We are going to do both ports here, for a total of 52 pins.

### Notes

The TXCLK pins are not routed on clock-capable pins. This causes some timing
constraint issues when routing.

    [Place 30-574] Poor placement for routing between an IO pin and BUFG. If this sub optimal condition is acceptable for this design, you may use the CLOCK_DEDICATED_ROUTE constraint in the .xdc file to demote this message to a WARNING. However, the use of this override is highly discouraged. These examples can be used directly in the .xdc file to override this clock rule.
	< set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/clock_inst/mii_tx_clk_ibuf] >

	design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/clock_inst/mii_tx_clk_ibuf_i (IBUF.O) is locked to IOB_X0Y213
	 design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/clock_inst/BUFGMUX_SPEED_CLK (BUFGCTRL.I1) is provisionally placed by clockplacer on BUFGCTRL_X0Y15

	The above error could possibly be related to other connected instances. Following is a list of 
	all the related clock rules and their respective instances.

	Clock Rule: rule_cascaded_bufg
	Status: PASS 
	Rule Description: Cascaded bufg (bufg->bufg) must be adjacent and cyclic
	 design_1_i/axi_ethernet_0_refclk/inst/clkout2_buf (BUFG.O) is provisionally placed by clockplacer on BUFGCTRL_X0Y14
	 design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/clock_inst/BUFGMUX_SPEED_CLK (BUFGCTRL.I0) is provisionally placed by clockplacer on BUFGCTRL_X0Y15

	Clock Rule: rule_mmcm_bufg
	Status: PASS 
	Rule Description: An MMCM driving a BUFG must be placed on the same half side (top/bottom) of the device
	 design_1_i/axi_ethernet_0_refclk/inst/mmcm_adv_inst (MMCME2_ADV.CLKFBOUT) is provisionally placed by clockplacer on MMCME2_ADV_X0Y3
	 design_1_i/axi_ethernet_0_refclk/inst/clkf_buf (BUFG.I) is provisionally placed by clockplacer on BUFGCTRL_X0Y0

	Clock Rule: rule_gclkio_mmcm_1load
	Status: PASS 
	Rule Description: An IOB driving a single MMCM must both be in the same clock region if CLOCK_DEDICATED_ROUTE=BACKBONE
	is NOT set
	 design_1_i/axi_ethernet_0_refclk/inst/clkin1_ibufg (IBUF.O) is locked to IOB_X0Y176
	 and design_1_i/axi_ethernet_0_refclk/inst/mmcm_adv_inst (MMCME2_ADV.CLKIN1) is provisionally placed by clockplacer on MMCME2_ADV_X0Y3


There are constraints which can be added to override the errors. But it is
not clear what impact this has.

These pins are optional on the interface. And in the example RTL from the
board developer, this pin is not used. This is a design oversight from what
I can tell. There are clock-capable pins on the bank used for GMII which
are used for GPIO.

The other downside is that this problem is not reported until near the end
of synthesis.

### Pins

One important thing to note here is that, for Ethernet Port A, MDIO and MDC
are on Bank 15 which is on VCCIO and is switchable between 2.5 and 3.3V. It
is questionable whether it is safe to use Ethernet Port A when VCCIO is set
to 3.3V.  All of the other Ethernet pins are on Bank 16 which is at 2.5V.

To discover these sorts of things, you either need to pay very close attention
to the schematic as you are creating the board files, or you will be greeted
with an error by Vivado during sythesis.

> [DRC BIVC-1] Bank IO standard Vcc: Conflicting Vcc voltages in bank 15. For example, the following two ports in this bank have conflicting VCCOs:   mdio_a_mdc (LVCMOS25, requiring VCCO=2.500) and sysclk_100 (LVCMOS33, requiring VCCO=3.300)

Guess which method I used to discover the problem.

        <pin index="34" name ="ETH_A_TXD0"   iostandard="LVCMOS25" loc="G12"/>
        <pin index="35" name ="ETH_A_TXD1"   iostandard="LVCMOS25" loc="E11"/>
        <pin index="36" name ="ETH_A_TXD2"   iostandard="LVCMOS25" loc="G11"/>
        <pin index="37" name ="ETH_A_TXD3"   iostandard="LVCMOS25" loc="C14"/>
        <pin index="39" name ="ETH_A_TXD4"   iostandard="LVCMOS25" loc="D14"/>
        <pin index="39" name ="ETH_A_TXD5"   iostandard="LVCMOS25" loc="C13"/>
        <pin index="40" name ="ETH_A_TXD6"   iostandard="LVCMOS25" loc="C11"/>
        <pin index="41" name ="ETH_A_TXD7"   iostandard="LVCMOS25" loc="D13"/>
        <pin index="42" name ="ETH_A_RXD0"   iostandard="LVCMOS25" loc="H14"/>
        <pin index="43" name ="ETH_A_RXD1"   iostandard="LVCMOS25" loc="J14"/>
        <pin index="44" name ="ETH_A_RXD2"   iostandard="LVCMOS25" loc="J13"/>
        <pin index="45" name ="ETH_A_RXD3"   iostandard="LVCMOS25" loc="H13"/>
        <pin index="46" name ="ETH_A_RXD4"   iostandard="LVCMOS25" loc="B15"/>
        <pin index="47" name ="ETH_A_RXD5"   iostandard="LVCMOS25" loc="A15"/>
        <pin index="48" name ="ETH_A_RXD6"   iostandard="LVCMOS25" loc="B14"/>
        <pin index="49" name ="ETH_A_RXD7"   iostandard="LVCMOS25" loc="A14"/>
        <pin index="50" name ="ETH_A_MDIO"   iostandard="LVCMOS33" loc="K15"/>
        <pin index="51" name ="ETH_A_MDC"    iostandard="LVCMOS33" loc="M16"/>
        <pin index="52" name ="ETH_A_GTXCLK" iostandard="LVCMOS25" loc="F13"/>
        <pin index="53" name ="ETH_A_RESET"  iostandard="LVCMOS25" loc="D11"/>
        <pin index="54" name ="ETH_A_RXCLK"  iostandard="LVCMOS25" loc="D12"/>
        <pin index="55" name ="ETH_A_RXDV"   iostandard="LVCMOS25" loc="G14"/>
        <pin index="56" name ="ETH_A_RXER"   iostandard="LVCMOS25" loc="F14"/>
        <pin index="57" name ="ETH_A_TXEN"   iostandard="LVCMOS25" loc="F12"/>
        <pin index="58" name ="ETH_A_TXER"   iostandard="LVCMOS25" loc="E13"/>
        <pin index="59" name ="ETH_A_TXCLK"  iostandard="LVCMOS25" loc="E12"/>

        <pin index="60" name ="ETH_B_TXD0"   iostandard="LVCMOS25" loc="H11"/>
        <pin index="61" name ="ETH_B_TXD1"   iostandard="LVCMOS25" loc="J11"/>
        <pin index="62" name ="ETH_B_TXD2"   iostandard="LVCMOS25" loc="H9"/>
        <pin index="63" name ="ETH_B_TXD3"   iostandard="LVCMOS25" loc="CJ10"/>
        <pin index="64" name ="ETH_B_TXD4"   iostandard="LVCMOS25" loc="H12"/>
        <pin index="65" name ="ETH_B_TXD5"   iostandard="LVCMOS25" loc="F10"/>
        <pin index="66" name ="ETH_B_TXD6"   iostandard="LVCMOS25" loc="G10"/>
        <pin index="67" name ="ETH_B_TXD7"   iostandard="LVCMOS25" loc="F9"/>
        <pin index="68" name ="ETH_B_RXD0"   iostandard="LVCMOS25" loc="A13"/>
        <pin index="69" name ="ETH_B_RXD1"   iostandard="LVCMOS25" loc="B12"/>
        <pin index="70" name ="ETH_B_RXD2"   iostandard="LVCMOS25" loc="B11"/>
        <pin index="71" name ="ETH_B_RXD3"   iostandard="LVCMOS25" loc="A10"/>
        <pin index="72" name ="ETH_B_RXD4"   iostandard="LVCMOS25" loc="B10"/>
        <pin index="73" name ="ETH_B_RXD5"   iostandard="LVCMOS25" loc="A9"/>
        <pin index="74" name ="ETH_B_RXD6"   iostandard="LVCMOS25" loc="B9"/>
        <pin index="75" name ="ETH_B_RXD7"   iostandard="LVCMOS25" loc="A8"/>
        <pin index="76" name ="ETH_B_MDIO"   iostandard="LVCMOS25" loc="G9"/>
        <pin index="77" name ="ETH_B_MDC"    iostandard="LVCMOS25" loc="H8"/>
        <pin index="78" name ="ETH_B_GTXCLK" iostandard="LVCMOS25" loc="D8"/>
        <pin index="79" name ="ETH_B_RESET"  iostandard="LVCMOS25" loc="J8"/>
        <pin index="80" name ="ETH_B_RXCLK"  iostandard="LVCMOS25" loc="E10"/>
        <pin index="81" name ="ETH_B_RXDV"   iostandard="LVCMOS25" loc="A12"/>
        <pin index="82" name ="ETH_B_RXER"   iostandard="LVCMOS25" loc="D10"/>
        <pin index="83" name ="ETH_B_TXEN"   iostandard="LVCMOS25" loc="F8"/>
        <pin index="84" name ="ETH_B_TXER"   iostandard="LVCMOS25" loc="D9"/>
        <pin index="85" name ="ETH_B_TXCLK"  iostandard="LVCMOS25" loc="C9"/>

### Constraints

For this we create two separate XDC files, one for each port. As noted above,
`eth_a_mdio` and `eth_a_mdc` are on a different bank and therefore may have
a different voltage.

    ########### ETHERNET A ##########
    set_property -dict { PACKAGE_PIN G12  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd0}]
    set_property -dict { PACKAGE_PIN E11  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd1}]
    set_property -dict { PACKAGE_PIN G11  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd2}]
    set_property -dict { PACKAGE_PIN C14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd3}]
    set_property -dict { PACKAGE_PIN D14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd4}]
    set_property -dict { PACKAGE_PIN C13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd5}]
    set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd6}]
    set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txd7}]

    set_property -dict { PACKAGE_PIN H14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd0}]
    set_property -dict { PACKAGE_PIN J14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd1}]
    set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd2}]
    set_property -dict { PACKAGE_PIN H13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd3}]
    set_property -dict { PACKAGE_PIN B15  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd4}]
    set_property -dict { PACKAGE_PIN A15  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd5}]
    set_property -dict { PACKAGE_PIN B14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd6}]
    set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxd7}]

    set_property -dict { PACKAGE_PIN K15  IOSTANDARD LVCMOS33 } [get_ports {eth_a_mdio}]
    set_property -dict { PACKAGE_PIN M16  IOSTANDARD LVCMOS33 } [get_ports {eth_a_mdc}]
    set_property -dict { PACKAGE_PIN F13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_gtxclk}]
    set_property -dict { PACKAGE_PIN D11  IOSTANDARD LVCMOS25 } [get_ports {eth_a_reset}]
    set_property -dict { PACKAGE_PIN C12  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxclk}]
    set_property -dict { PACKAGE_PIN G14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxdv}]
    set_property -dict { PACKAGE_PIN F14  IOSTANDARD LVCMOS25 } [get_ports {eth_a_rxer}]
    set_property -dict { PACKAGE_PIN F12  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txen}]
    set_property -dict { PACKAGE_PIN E13  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txer}]
    set_property -dict { PACKAGE_PIN E12  IOSTANDARD LVCMOS25 } [get_ports {eth_a_txclk}]

    ########### ETHERNET B ##########
    set_property -dict { PACKAGE_PIN H11  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd0}]
    set_property -dict { PACKAGE_PIN J11  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd1}]
    set_property -dict { PACKAGE_PIN H9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd2}]
    set_property -dict { PACKAGE_PIN J10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd3}]
    set_property -dict { PACKAGE_PIN H12  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd4}]
    set_property -dict { PACKAGE_PIN F10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd5}]
    set_property -dict { PACKAGE_PIN G10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd6}]
    set_property -dict { PACKAGE_PIN F9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_txd7}]

    set_property -dict { PACKAGE_PIN A13  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd0}]
    set_property -dict { PACKAGE_PIN B12  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd1}]
    set_property -dict { PACKAGE_PIN B11  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd2}]
    set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd3}]
    set_property -dict { PACKAGE_PIN B10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd4}]
    set_property -dict { PACKAGE_PIN A9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd5}]
    set_property -dict { PACKAGE_PIN B9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd6}]
    set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxd7}]

    set_property -dict { PACKAGE_PIN G9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_mdio}]
    set_property -dict { PACKAGE_PIN H8   IOSTANDARD LVCMOS25 } [get_ports {eth_b_mdc}]
    set_property -dict { PACKAGE_PIN D8   IOSTANDARD LVCMOS25 } [get_ports {eth_b_gtxclk}]
    set_property -dict { PACKAGE_PIN J8   IOSTANDARD LVCMOS25 } [get_ports {eth_b_reset}]
    set_property -dict { PACKAGE_PIN E10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxclk}]
    set_property -dict { PACKAGE_PIN A12  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxdv}]
    set_property -dict { PACKAGE_PIN D10  IOSTANDARD LVCMOS25 } [get_ports {eth_b_rxer}]
    set_property -dict { PACKAGE_PIN F8   IOSTANDARD LVCMOS25 } [get_ports {eth_b_txen}]
    set_property -dict { PACKAGE_PIN D9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_txer}]
    set_property -dict { PACKAGE_PIN C9   IOSTANDARD LVCMOS25 } [get_ports {eth_b_txclk}]

### Presets

### Board

For this we are using the KC705 board as an example. The 88e1111 chip supports
MII, GMII, and RGMII interfaces. The chip is wired for GMII. AXI_Ethernet
requires three interfaces: gmii\_rtl and mdio\_rtl and reset\_rtl.

#### Interface

    <interface mode="master" name="gmii_a" type="xilinx.com:interface:gmii_rtl:1.0">
      <port_maps>
        <port_map logical_port="TXD" physical_port="gmii_txd"/>
        <port_map logical_port="TX_EN" physical_port="gmii_tx_en"/>
        <port_map logical_port="TX_ER" physical_port="gmii_tx_er"/>
        <port_map logical_port="GTX_CLK" physical_port="gmii_gtx_clk"/>
        <port_map logical_port="TX_CLK" physical_port="gmii_tx_clk"/>
        <port_map logical_port="RXD" physical_port="gmii_rxd"/>
        <port_map logical_port="RX_DV" physical_port="gmii_rx_dv"/>
        <port_map logical_port="RX_ER" physical_port="gmii_rx_er"/>
        <port_map logical_port="RX_CLK" physical_port="gmii_rx_clk"/>
        <port_map logical_port="COL" physical_port="gmii_col"/>
        <port_map logical_port="CRS" physical_port="gmii_crs"/>
      </port_maps>
    </interface>


Each `port_map physical_port` must have a unique name. If the names are not
unique, for example PHY A and PHY B both have a physical port named
`gmii_txd`, then the board will validate, it will be loaded and appear
usable in Vivado, but synthesis will fail with "BOARD_PIN not found".


#### Component

#### Connection

## SFP+ Ports

The SFP+ ports are high-speed (10Gbps) network ports. The PHY is on the SFP
module itself, and can be wired or fiber optic.

For this we also need to add the 156.25MHz MGT clock, which is needed by the
Ethernet subsystem. This clock is used for 10G Ethernet.

The SFP+ ports can be configured for either 1000BaseX or SGMII mode in the
axi_ethernet block.

A 125MHz MGT clock is needed to run the SFP+ ports at 1000Base-X or with an
SGMII SFP adapter.  There is no such clock on the board.  You will either
need to install a 125MHz clock at Y3 or install the Si5338 and configure it
for 125MHz to use the SFP+ ports for gigabit Ethernet.

### Important Note

> Because I only have gigabit Ethernet SFP modules and I do not have a 125MHz
> MGT clock available, these SFP ports have not been tested. There is a high
> likelyhood that there are errors here.

### Pins

The I2C pins are connected to banks powered by VCCIO, and we have chosen to
use LVCMOS33 for those banks, we need to use that here.

        <pin index="86" name ="SFP_A_SCL" iostandard="LVCMOS33" loc="C21"/>
        <pin index="87" name ="SFP_A_SDA" iostandard="LVCMOS33" loc="B21"/>
        <pin index="88" name ="SFP_A_TX_N" iostandard="LVDS" loc="H1"/>
        <pin index="89" name ="SFP_A_TX_P" iostandard="LVDS" loc="H2"/>
        <pin index="90" name ="SFP_A_RX_N" iostandard="LVDS" loc="J3"/>
        <pin index="91" name ="SFP_A_RX_P" iostandard="LVDS" loc="J4"/>

        <pin index="92" name ="SFP_B_SCL" iostandard="LVCMOS33" loc="C22"/>
        <pin index="93" name ="SFP_B_SDA" iostandard="LVCMOS33" loc="D21"/>
        <pin index="94" name ="SFP_B_TX_N" iostandard="LVDS" loc="K1"/>
        <pin index="95" name ="SFP_B_TX_P" iostandard="LVDS" loc="K2"/>
        <pin index="96" name ="SFP_B_RX_N" iostandard="LVDS" loc="L3"/>
        <pin index="97" name ="SFP_B_RX_P" iostandard="LVDS" loc="L4"/>


### Constraints

Note again that the I2C pins are on VCCIO. 

    ########### SFP+ A ##########
    set_property -dict { PACKAGE_PIN C21  IOSTANDARD LVCMOS33 } [get_ports {sfp_a_scl}]
    set_property -dict { PACKAGE_PIN B21  IOSTANDARD LVCMOS33 } [get_ports {sfp_a_sda}]
    set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVDS } [get_ports {sfp_a_txn}]
    set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVDS } [get_ports {sfp_a_txp}]
    set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVDS } [get_ports {sfp_a_rxn}]
    set_property -dict { PACKAGE_PIN J4   IOSTANDARD LVDS } [get_ports {sfp_a_rxp}]

    ########### SFP+ B ##########
    set_property -dict { PACKAGE_PIN C22  IOSTANDARD LVCMOS33 } [get_ports {sfp_b_scl}]
    set_property -dict { PACKAGE_PIN D21  IOSTANDARD LVCMOS33 } [get_ports {sfp_b_sda}]
    set_property -dict { PACKAGE_PIN K1   IOSTANDARD LVDS } [get_ports {sfp_b_txn}]
    set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVDS } [get_ports {sfp_b_txp}]
    set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVDS } [get_ports {sfp_b_rxn}]
    set_property -dict { PACKAGE_PIN L4   IOSTANDARD LVDS } [get_ports {sfp_b_rxp}]

### Presets

We need presets for both the 1000BaseX and SGMII interfaces. These can be
expanded in the future to allow for other SFP+ types.

      <ip_preset preset_proc_name="sfp_a_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_ethernet" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.PHY_TYPE" value="1000basex"/> 
          </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="gig_ethernet_pcs_pma" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.Standard" value="1000BASEX"/> 
          </user_parameters>
        </ip>
      </ip_preset>

      <ip_preset preset_proc_name="sfp_a_sgmii_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_ethernet" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.PHY_TYPE" value="SGMII"/> 
          </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="gig_ethernet_pcs_pma" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.Standard" value="SGMII"/> 
          </user_parameters>
        </ip>
      </ip_preset>

      <ip_preset preset_proc_name="sfp_b_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_ethernet" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.PHY_TYPE" value="1000basex"/> 
          </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="gig_ethernet_pcs_pma" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.Standard" value="1000BASEX"/> 
          </user_parameters>
        </ip>
      </ip_preset>

      <ip_preset preset_proc_name="sfp_b_sgmii_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_ethernet" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.PHY_TYPE" value="SGMII"/> 
          </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="gig_ethernet_pcs_pma" ip_interface="sfp">
          <user_parameters>
            <user_parameter name="CONFIG.Standard" value="SGMII"/> 
          </user_parameters>
        </ip>
      </ip_preset>

### Board

The SFP interface consists of two components: the GTX transceivers and the
IIC control interface.

We must also set the `gt_loc` parameter when using GTX transceivers with
the Ethernet IP per *UG895*.  The appropriate location can be found by
looking at the pins in *UG476, 7 Series Transceivers*.

SFP A is at X0Y3.

SFB B is at X0Y2.

#### Interface

        <interface mode="master" name="sfp_a" type="xilinx.com:interface:sfp_rtl:1.0" of_component="phy_sfp_a" preset_proc="sfp_a_preset">
          <parameters>
            <parameter name="gt_loc" value="GTXE2_CHANNEL_X0Y3"/>
          </parameters>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_ethernet" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TXN" physical_port="sfp_a_txn" dir="out" name="sfp_txn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_TXN"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="TXP" physical_port="sfp_a_txp" dir="out" name="sfp_txp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_TXP"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXN" physical_port="sfp_a_rxn" dir="in" name="sfp_rxn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_RXN"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXP" physical_port="sfp_a_rxp" dir="in" name="sfp_rxp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_RXP"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
        
        <interface mode="master" name="sfp_a_sgmii" type="xilinx.com:interface:sgmii_rtl:1.0" of_component="phy_sfp_a" preset_proc="sfp_a_sgmii_preset">
          <parameters>
            <parameter name="gt_loc" value="GTXE2_CHANNEL_X0Y3"/>
          </parameters>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_ethernet" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TXN" physical_port="sfp_a_sgmii_txn" dir="out" name="sfp_txn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_TX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="TXP" physical_port="sfp_a_sgmii_txp" dir="out" name="sfp_txp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_TX_P"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXN" physical_port="sfp_a_sgmii_rxn" dir="in" name="sfp_rxn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_RX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXP" physical_port="sfp_a_sgmii_rxp" dir="in" name="sfp_rxp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_RX_P"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

        <interface mode="master" name="sfp_b" type="xilinx.com:interface:sfp_rtl:1.0" of_component="phy_sfp_b" preset_proc="sfp_b_preset">
          <parameters>
            <parameter name="gt_loc" value="GTXE2_CHANNEL_X0Y2"/>
          </parameters>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_ethernet" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TXN" physical_port="sfp_b_txn" dir="out" name="sfp_txn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_TX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="TXP" physical_port="sfp_b_txp" dir="out" name="sfp_txp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_TX_P"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXN" physical_port="sfp_b_rxn" dir="in" name="sfp_rxn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_RX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXP" physical_port="sfp_b_rxp" dir="in" name="sfp_rxp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_RX_P"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
        
        <interface mode="master" name="sfp_b_sgmii" type="xilinx.com:interface:sgmii_rtl:1.0" of_component="phy_sfp_b" preset_proc="sfp_b_sgmii_preset">
          <parameters>
            <parameter name="gt_loc" value="GTXE2_CHANNEL_X0Y2"/>
          </parameters>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_ethernet" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TXN" physical_port="sfp_b_sgmii_txn" dir="out" name="sfp_txn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_TX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="TXP" physical_port="sfp_b_sgmii_txp" dir="out" name="sfp_txp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_TX_P"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXN" physical_port="sfp_b_sgmii_rxn" dir="in" name="sfp_rxn">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_RX_N"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="RXP" physical_port="sfp_b_sgmii_rxp" dir="in" name="sfp_rxp">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_RX_P"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

        <interface mode="master" name="sfp_a_iic" type="xilinx.com:interface:iic_rtl:1.0" of_component="phy_sfp_a_iic">
          <description>Secondary interface for SFP A to communicate with SFP module. </description>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_iic" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="SDA_I" physical_port="sfp_a_iic_sda_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_O" physical_port="sfp_a_iic_sda_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_T" physical_port="sfp_a_iic_sda_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_I" physical_port="sfp_a_iic_scl_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_O" physical_port="sfp_a_iic_scl_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_T" physical_port="sfp_a_iic_scl_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_A_SCL"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

        <interface mode="master" name="sfp_b_iic" type="xilinx.com:interface:iic_rtl:1.0" of_component="phy_sfp_b_iic">
          <description>Secondary interface for SFP B to communicate with SFP module. </description>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_iic" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="SDA_I" physical_port="sfp_b_iic_sda_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_O" physical_port="sfp_b_iic_sda_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_T" physical_port="sfp_b_iic_sda_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SDA"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_I" physical_port="sfp_b_iic_scl_i" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_O" physical_port="sfp_b_iic_scl_o" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SCL"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_T" physical_port="sfp_b_iic_scl_t" dir="inout">
              <pin_maps>
                <pin_map port_index="0" component_pin="SFP_B_SCL"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>


#### Component



#### Connection

## HDMI

The HDMI interface has the following connections:

 * Three TMDS differential data lines
 * One differential clock line
 * One 5V I2C interface
 * One 3V3 CEC (consumer electronics control) signal
 * One 5V HPD (hot-plug detect) signal

The HDMI interface on the board can be used for either input or output.

The 5V I2C lines are each connected to the FPGA using a level shifter.

The HPD signal, which is nominally a 5V signal, is connected directly to the
FPGA (through an ESD protection network) without any level shifter. This
seems rather unsafe to me.

There are a number of potential IPs to use with the HDMI port. Xilinx defines
an HDMI interface, but there are no IPs which use this interface.  Digilent
has an HDMI interface with example code available. We will use their interface
to configure the board.

The Digilent IP can be found here:

 * https://github.com/Digilent/vivado-library
 
To use this library:

 * Clone the github repo.
 * Add the directory as an IP repository in Vivado.
   * Tools | Settings...
   * Project Settings | IP | Repository
   * Click the "+" icon.
   * Add the path to the cloned repo.
   * You should see a dialog box showing the number of new IPs and Interfaces added.
   * Click "OK" in the pop-up and settings dialog to return to Vivado's main interface.

### Pins

        <pin index="98" name ="HDMI_CEC" iostandard="LVCMOS33" loc="M26"/>
        <pin index="99" name ="HDMI_HPD" iostandard="LVCMOS33" loc="N26"/>
        <pin index="100" name ="HDMI_SCL" iostandard="LVCMOS33" loc="K21"/>
        <pin index="101" name ="HDMI_SDA" iostandard="LVCMOS33" loc="L23"/>
        <pin index="102" name ="HDMI_CLK_P" iostandard="LVDS" loc="R21"/>
        <pin index="103" name ="HDMI_CLK_N" iostandard="LVDS" loc="P21"/>
        <pin index="104" name ="HDMI_DATA_P0" iostandard="TMDS_33" loc="N18"/>
        <pin index="105" name ="HDMI_DATA_P1" iostandard="TMDS_33" loc="M21"/>
        <pin index="106" name ="HDMI_DATA_P2" iostandard="TMDS_33" loc="K25"/>
        <pin index="107" name ="HDMI_DATA_N0" iostandard="TMDS_33" loc="M19"/>
        <pin index="108" name ="HDMI_DATA_N1" iostandard="TMDS_33" loc="M22"/>
        <pin index="109" name ="HDMI_DATA_N2" iostandard="TMDS_33" loc="K26"/> 

### Constraints

    ########### HDMI ##########
    set_property -dict { PACKAGE_PIN M26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_cec}]
    set_property -dict { PACKAGE_PIN N26  IOSTANDARD LVCMOS33 } [get_ports {hdmi_hpd}]
    set_property -dict { PACKAGE_PIN K21  IOSTANDARD LVCMOS33 } [get_ports {hdmi_scl}]
    set_property -dict { PACKAGE_PIN L23  IOSTANDARD LVCMOS33 } [get_ports {hdmi_sda}]
    set_property -dict { PACKAGE_PIN R21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_p}]
    set_property -dict { PACKAGE_PIN P21  IOSTANDARD TMDS_33 } [get_ports {hdmi_clk_n}]
    set_property -dict { PACKAGE_PIN N18  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[0]}]
    set_property -dict { PACKAGE_PIN M19  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[0]}]
    set_property -dict { PACKAGE_PIN M21  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[1]}]
    set_property -dict { PACKAGE_PIN M22  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[1]}]
    set_property -dict { PACKAGE_PIN K25  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_p[2]}]
    set_property -dict { PACKAGE_PIN K26  IOSTANDARD TMDS_33 } [get_ports {hdmi_data_n[2]}]

### Presets

We create an `output_1bit_preset` for this component for use with the CEC and HPD pins.
This preset can be used by other 1-bit GPIO output interfaces.

      <ip_preset preset_proc_name="output_1bit_preset">
        <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO">
            <user_parameters>
              <user_parameter name="CONFIG.C_GPIO_WIDTH" value="1"/> 
              <user_parameter name="CONFIG.C_ALL_OUTPUTS" value="1"/> 
              <user_parameter name="CONFIG.C_ALL_INPUTS" value="0"/>
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="axi_gpio" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.C_IS_DUAL" value="1"/> 
              <user_parameter name="CONFIG.C_GPIO2_WIDTH" value="1"/> 
              <user_parameter name="CONFIG.C_ALL_OUTPUTS_2" value="1"/> 
	      <user_parameter name="CONFIG.C_ALL_INPUTS_2" value="0"/>
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO1">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO1" value="1"/> 
              <user_parameter name="CONFIG.C_GPO1_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO2" value="1"/> 
              <user_parameter name="CONFIG.C_GPO2_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO3">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO3" value="1"/> 
              <user_parameter name="CONFIG.C_GPO3_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="iomodule" ip_interface="GPIO4">
            <user_parameters>
              <user_parameter name="CONFIG.C_USE_GPO4" value="1"/> 
              <user_parameter name="CONFIG.C_GPO4_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO1">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO1" value="1"/> 
              <user_parameter name="CONFIG.GPO1_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO2">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO2" value="1"/> 
              <user_parameter name="CONFIG.GPO2_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO3">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO3" value="1"/> 
              <user_parameter name="CONFIG.GPO3_SIZE" value="1"/> 
            </user_parameters>
        </ip>
        <ip vendor="xilinx.com" library="ip" name="microblaze_mcs" ip_interface="GPIO4">
            <user_parameters>
              <user_parameter name="CONFIG.USE_GPO4" value="1"/> 
              <user_parameter name="CONFIG.GPO4_SIZE" value="1"/> 
            </user_parameters>
        </ip>
      </ip_preset>


### Board

There are 4 interfaces for the HDMI port.

 * HDMI data and clock
 * HPD GPIO
 * CEC GPIO
 * I2C

#### Interface

Here we use the Digilent HDMI (rgb2dvi) interface.

        <interface mode="master" name="hdmi" type="digilentinc.com:interface:tmds_rtl:1.0" of_component="hdmi">
          <description>HDMI Out</description>
          <preferred_ips>
            <preferred_ip vendor="digilentinc.com" library="ip" name="rgb2dvi" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="CLK_P" physical_port="hdmi_clk_p" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_CLK_P"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="CLK_N" physical_port="hdmi_clk_n" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_CLK_N"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="DATA_P" physical_port="hdmi_data_p" dir="out" left="2" right="0">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_DATA_P0"/>
                <pin_map port_index="1" component_pin="HDMI_DATA_P1"/>
                <pin_map port_index="2" component_pin="HDMI_DATA_P2"/>
              </pin_maps>
            </port_map>
            <port_map logical_port="DATA_N" physical_port="hdmi_data_n" dir="out" left="2" right="0">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_DATA_N0"/>
                <pin_map port_index="1" component_pin="HDMI_DATA_N1"/>
                <pin_map port_index="2" component_pin="HDMI_DATA_N2"/>
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
        <interface mode="master" name="hdmi_cec" type="xilinx.com:interface:gpio_rtl:1.0" of_component="hdmi_cec" preset_proc="output_1bit_preset">
          <description>HDMI CEC -- Consumer Electronics Control</description>
          <port_maps>
            <port_map logical_port="TRI_O" physical_port="hdmi_cec" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_CEC"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="TRI_I" physical_port="hdmi_cec" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_CEC"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="TRI_T" physical_port="hdmi_cec" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_CEC"/> 
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
        <interface mode="master" name="hdmi_hpd" type="xilinx.com:interface:gpio_rtl:1.0" of_component="hdmi_hpd" preset_proc="output_1bit_preset">
          <description>HDMI HPD -- Hot-plug Detect</description>
           <port_maps>
            <port_map logical_port="TRI_O" physical_port="hdmi_hpd" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_HPD"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="TRI_I" physical_port="hdmi_hpd" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_HPD"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="TRI_T" physical_port="hdmi_hpd" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_HPD"/> 
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>
        <interface mode="master" name="hdmi_ddc" type="xilinx.com:interface:iic_rtl:1.0" of_component="hdmi" preset_proc="hdmi_preset">
          <description>HDMI DDC -- I2C Display Data Channel</description>
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_iic" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="SDA_I" physical_port="hdmi_ddc_sda" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SDA"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_O" physical_port="hdmi_ddc_sda" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SDA"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="SDA_T" physical_port="hdmi_ddc_sda" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SDA"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_I" physical_port="hdmi_ddc_scl" dir="in">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SCL"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_O" physical_port="hdmi_ddc_scl" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SCL"/> 
              </pin_maps>
            </port_map>
            <port_map logical_port="SCL_T" physical_port="hdmi_ddc_scl" dir="out">
              <pin_maps>
                <pin_map port_index="0" component_pin="HDMI_SCL"/> 
              </pin_maps>
            </port_map>
          </port_maps>
        </interface>

#### Component

There are four trivial component definitions, matching the interfaces above.

    <component name="hdmi" display_name="HDMI" type="chip" sub_type="fixed_io" major_group="HDMI">
      <description>HDMI Output (Requires Digilent's TMDS Interface)</description>
    </component>
    <component name="hdmi_hpd" display_name="HDMI HPD" type="chip" sub_type="fixed_io" major_group="HDMI">
      <description>HDMI HPD -- Hot-plug Detect</description>
    </component> 
    <component name="hdmi_cec" display_name="HDMI CEC" type="chip" sub_type="fixed_io" major_group="HDMI">
      <description>HDMI CEC -- Consumer Electronics Control</description>
    </component>
    <component name="hdmi_ddc" display_name="HDMI DDC" type="chip" sub_type="chip" major_group="HDMI">
      <description>HDMI CEC -- Consumer Electronics Control</description>
    </component>


#### Connection

    <connection name="part0_hdmi" component1="part0" component2="hdmi">
      <connection_map name="part0_hdmi" typical_delay="5" c1_st_index="102" c1_end_index="109" c2_st_index="0" c2_end_index="7"/>
    </connection>

    <connection name="part0_hdmi_cec" component1="part0" component2="hdmi_cec">
      <connection_map name="part0_hdmi_cec" typical_delay="5" c1_st_index="98" c1_end_index="98" c2_st_index="0" c2_end_index="0"/>
    </connection>
    
    <connection name="part0_hdmi_hpd" component1="part0" component2="hdmi_hpd">
      <connection_map name="part0_hdmi_hpd" typical_delay="5" c1_st_index="99" c1_end_index="99" c2_st_index="0" c2_end_index="0"/>
    </connection>

    <connection name="part0_hdmi_ddc" component1="part0" component2="hdmi_ddc">
      <connection_map name="part0_hdmi_ddc" typical_delay="5" c1_st_index="100" c1_end_index="101" c2_st_index="0" c2_end_index="1"/>
    </connection>

### Notes

After days of attemping to make the normal connection process work, I was
unable to do so. I do not know where the problem lies. Bitstream generation
failes with `Unconstrained Logical Port` DRC error for the 8 HDMI ports. The
work-around is to add the `hdmi.xdc` file to the project, commenting out the
I2C, CEC and HPD pins. The pin names in the XDC file match the names expected
by Vivado for the HDMI interface.

Since this is a third-party module, I suspect that there is an error in
Digilent's interface definition, or it is just out of date and needs to be
updated. However it could certainly be something that I am overlooking.

## SATA

### Pins

### Constraints

### Presets

### Board

#### Interface

#### Component

#### Connection

## PCIe

### Pins

### Constraints

### Presets

### Board

#### Interface

#### Component

#### Connection

