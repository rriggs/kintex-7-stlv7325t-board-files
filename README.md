# kintex-7-stlv7325t-board-files
Vivado board files for the [Kintex 7 XC7K325T FPGA](https://www.aliexpress.com/item/3256801088848039.html) development board from the *HPC FPGA Board Store* on AliExpress.

![Board image](hpc-xc7k325t/1.0/hpc-xc7k325t.jpg)

To use the board files, follow these simple steps:

 1. Clone the repository.
    `git clone https://github.com/rriggs/kintex-7-stlv7325t-board-files`
 1. Start Vivado and run the following command in the TCL console:
    `set_param board.repoPaths [list "<FULL_PATH_TO>/kintex-7-stlv7325t-board-files"]`
    Note that you must change the `<FULL_PATH_TO>` in the command above to the path where the repository was cloned.
 1. Run `get_boards ali*` in the TCL console to verify that the board files are found.
    You should see `aliexpress.com:hpc_xc7k325t:1.0` printed to the console.
 1. You may need to restart Vivado or correct the path to the `set_param` command to find the board files.

