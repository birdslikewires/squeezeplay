# SqueezePlay

SqueezePlay software optimised for OpenFrame devices.

## Cloning

This project contains submodules from other Git repositories, so you need to initialise and update those after cloning this.

```
git clone https://github.com/andydvsn/squeezeplay
git -C squeezeplay submodule update --init --recursive
```

Current submodules are:

* [portaudio](https://app.assembla.com/spaces/portaudio/git/source)

## Compiling

With a following wind and a lucky charm you should be able to compile it with this:

```
cd squeezeplay/src
make -f Makefile.linux
```

Good luck.