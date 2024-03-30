# PennSim LC3 ISA Breakout Game

Ensure PennSim.jar is in the same directory as code. If it is not the script will not work
and you will have to manually enter the full directory paths for all files you want to assemble or load.
```
// Run the script
script PennSimScript.script
```

If successful, should have no error messages and at memory address `x3000` 
there should be a START instruction.
The memory addresses starting at `xC000` is a memory mapped IO address.The devices 
output ends as `xFDFF`.
So the addresses `xC000` -> `xFDFF` are mapped to pixels on the video output.
The display is 128x124 pixels.

Results:
![CleanShot 2024-03-29 at 19 37 56@2x](https://github.com/DauntingPear/LC3-Breakout-Lab/assets/82192217/fb52e385-c10b-4db8-babd-a4c27355e39e)
