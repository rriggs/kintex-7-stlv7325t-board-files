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
this section can be extended. Note that the SIZE or WIDTH values here are
set to "2" which is the number of buttons we have.

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
              <user_parameter name="CONFIG.GPI3_SIZE" value="3"/> 
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
            
          </interfaces>
        </component>
        ...
      </components>

Here we have added two slave interfaces to the FPGA, a differential 200MHz
clock and a single-ended 100MHz clock. Note that the `preset_proc` name
corresponds to the entry in the `preset.xml` file.  And the physical port
names correspond to the names of the pins in the `part0_pins.xml` file.

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
the *Board* tab and see the two clocks we have defined. These can be added to
the block design

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
 
        <interface mode="master" name="push_button" type="xilinx.com:interface:gpio_rtl:1.0" of_component="push_button" preset_proc="push_buttons_preset">
          <preferred_ips>
            <preferred_ip vendor="xilinx.com" library="ip" name="axi_gpio" order="0"/>
          </preferred_ips>
          <port_maps>
            <port_map logical_port="TRI_I" physical_port="BTN1" dir="in">
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


