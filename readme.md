# PennSim LC3 ISA Breakout Game

Make sure the starter code is assembled.
```
as starter_code.asm
```

This produces the binary file and the object file. We will load the `.obj` file.
The `lc3os.asm` file is the OS code which defines the TRAPs.

```
as lc3os.asm
```

To load the OS and starter code use `file -> open` or
```
ld lc3os.obj
ld starter_code.obj
```
If successful, should have no error messages and at memory address `x3000` there should be a START instruction.
The memory addresses starting at `xC000` is a memory mapped IO address. The devices output ends as `xFDFF`.
So the addresses `xC000` -> `xFDFF` are mapped to pixels on the video output.
The display is 128x128 pixels.
