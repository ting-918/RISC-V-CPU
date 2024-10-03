# RISC-V-CPU (Verilog Programming)
This is an implementation of a Single-Cycle RISC-V CPU using the RV321 instruction set. 
As part of the FPGA Design course experiment, this implementation involved: 
1. Mastering and executing the five stages of instruction execution.
2. Designing the data path selection for each instruction.
3. Implementing 37 instructions from the RV321 instruction set.
4. Utilizing the instruction set to compute Fibonacci sequence.

# The Five Stages of Instruction Execution
**1. Instruction Fetch** <br>
&emsp;At this stage, we need to accomplish the following two tasks: <br>
&emsp;&emsp; (1) Instruction Fetching <br>
&emsp;&emsp;&emsp; **• ID← ROM[PC]** <br>
&emsp;&emsp; (2) Calculating the Next Address <br>
&emsp;&emsp;&emsp; **• PC ← PC+4** <br>
&emsp; For these two parts, we primarily designed the PC component (with the code located at [PC.v](final.srcs/sources_1/new/PC.v))<br><br>
**2. Instruction Decode**<br>
&emsp;The work at this stage primarily involves the following two components:<br>
&emsp; (1) ID (with the code located at [ID.v](final.srcs/sources_1/new/ID.v))<br>
&ensp;&emsp;&emsp; The ID decodes the retrieved instructions, generating corresponding signals such as opcode, func, rs1, rs2, rd, imm12, and imm20.<br>
&ensp;&emsp;&emsp; For details regarding decoding, please refer to **RV321 Instruction Format** as shown in the diagram below.
![RV321 Instruction Format](https://devopedia.org/images/article/110/3808.1535301636.png "RV321 Instruction Format") <br>
&emsp;&emsp;• The signals such as **opcode**, **funct3**, **funct7**, which determine the type of operation, will be passed to the CU for further processing.<br>
&emsp;&emsp;• The signals **rs1**, **rs2**, **rd**, which specify the registers to read (rs1, rs2) and to write (rd) respectively, will be passed to the RegFiles.<br><br>
&emsp; (2) CU (with the code located at [CU.v](final.srcs/sources_1/new/CU.v))<br>
&ensp;&emsp;&emsp;The CU generates different control signals based on the opcode and func signals provided by the ID, enabling the RegFiles, ALU, RAM,<br>
&ensp;&emsp;&emsp;and other components to perform their respective operations.<br><br>
**3. Execution**<br>
&emsp;At this stage, we primarily design the ALU component (with the code located at [ALU.v](final.srcs/sources_1/new/ALU.v)) to perform corresponding operations based on<br>
&emsp;the following received parameters: <br>
&emsp; (1) Parameters **a** and **b**, which serve as data inputs and receive two operands respectively.<br>
&emsp; (2) Parameter **op**, which functions as the operation control input and specifies the type of operation to be executed.<br><br>
**4. Memory Access**<br>
&emsp;Only **Load** instructions (lw, lh, lhu, lb, lbu) and **Store** instructions (sw, sh, sb) enter this stage to access the DataRAM. <br>
&emsp;The DataRAM module primarily performs data read and write operations based on the received parameter:  <br>
&emsp;&emsp;• **write enable signal (we)** <br>
&emsp;&emsp;• **address (a)** <br> 
&emsp;&emsp;• **writing data(d)**.<br>
&emsp;The work at this stage primarily involves the IOmanager component that we design (with the code located at [IOmanager.v](final.srcs/sources_1/new/IOmanager.v))<br><br>
**5. Write-Back**<br>
&emsp;The main task at this stage is to write the target data into the register **rd**, which can be categorized into the following cases:<br>
&emsp;&emsp;• **Load** instruction: Write the data fetched from DataRam (**mdata**) into rd.<br>
&emsp;&emsp;• **Jal** instruction: Write the address of the next instruction (**PC+4**) into rd.<br>
&emsp;&emsp;• Most instructions: Write the ALU computation result (**f**) into rd.<br>
&emsp;The work at this stage primarily involves the RegFiles component that we design (with the code located at [RegFiles.v](final.srcs/sources_1/new/RegFiles.v))<br><br>

# Data Path Design
![RV321 Data Path](https://github.com/ting-918/RISC-V-CPU/blob/444ca13b4deff695e3aaaaa48287d6beb445f575/images/RV32I%20Data%20Path.png "RV321 Data Path") <br>
&emsp;Based on the overall design shown in the diagram above, we ultimately developed the CPU component (with the code located at [CPU.v](final.srcs/sources_1/new/CPU.v)),<br>
&emsp;which integrated each component using the data path. <br>
&emsp;This ensures that signals and parameters are correctly transmitted and received, enabling seamless collaboration between components.<br><br>
# Details of RAM and ROM Configuration <br>
&emsp;(1) RAM<br>
&emsp; ![RAM Configuration](https://github.com/ting-918/RISC-V-CPU/blob/7cee19d3c5c1702b8379068604f5cf14a788931a/images/RAM%20Configuration.png)<br>
&emsp;(2) ROM<br>
&emsp; ![ROM Configuration](https://github.com/ting-918/RISC-V-CPU/blob/15eeb965e85b48c071af3c7a80e25357056d563d/images/ROM%20Configuration.png)<br>
# Result of the Fibonacci Sequence <br>
1. **Coefficient File** <br>
&nbsp;The coefficient file ([ins.coe](/ins/ins.coe)) was written with reference to the machine code ([fibonacci](https://github.com/ting-918/RISC-V-CPU/blob/67e76f72b430befb1b20c471760af4a596c88761/machine%20code/fibonacci)) to implement the Fibonacci <br>
&nbsp;sequence calculation.<br><br>
2. **Simulation Result** <br>
![Simulation Result](https://github.com/ting-918/RISC-V-CPU/blob/cb0f0aec330add52928233191e20794abc1a6933/images/Simulation%20Result.png "Simulation Result")<br><br>
3. **Output on Circuit Board** <br>
&nbsp;To match the circuit board, the original 31-bit peripheral output **result** was modified to a 10-bit data format, <br>
&nbsp;(since the Fibonacci number f(15) = 610 = 1001100010b) corresponding to bits 0 through 9 of the 31-bit **wdata**. <br><br>
&nbsp; The input data **n** is controlled by **R1**, **N4**, **M4**, and **R2** on the circuit board, while the output **result** is displayed <br>
&nbsp; from **K3** to **J2** (from right to left of the circuit board). <br><br>
&nbsp; The final output, f(8) = 0000010101b, is shown in the figure below.<br>
&nbsp; ![Output on Circuit Board](https://github.com/ting-918/RISC-V-CPU/blob/07b3c2b1fa20c9bf61849f44bf8dfb59811bd272/images/Circuit%20Board.png "Output on Circuit Board")<br>
