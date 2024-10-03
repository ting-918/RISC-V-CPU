onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib insROM_opt

do {wave.do}

view wave
view structure
view signals

do {insROM.udo}

run -all

quit -force
