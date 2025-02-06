<h1 align="center">x86-64 Assembly console snake game</h1>
<p align="center">
Only for Linux systems
  </p>

![snake game gif](./docs/game-of-life.gif)

## Build

You need to install <a href="https://en.wikipedia.org/wiki/Ncurses">ncurses</a> library.

#### Compile

```
nasm  -g  -f  elf64  -o  snake64.o  snake64.asm
```

#### Link

```
gcc  -g  -o  ./snake64.out  snake64.o  -lncurses
```

## Usage

Make sure the console window has a size of 80x24 characters

## License

MIT - Vlad Koroliuk 2025
