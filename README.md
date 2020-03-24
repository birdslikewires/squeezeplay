# SqueezePlay

SqueezePlay software for OpenFrame devices.

## Cloning

This project contains submodules from other Git repositories, so you need to initialise and update those after cloning this.

```
git clone https://github.com/andydvsn/squeezeplay
git -C squeezeplay submodule update --init
```

This checks out the versions last verified to work with this build. To update to whatever the very latest commit happens to be for those submodules, either `cd` into the submodule and:

```
git checkout master
git pull
```
Or to just bltz everything with the latest code:

```
git -C squeezeplay submodule foreach git pull origin master
```

Current submodules are:

* [portaudio](https://app.assembla.com/spaces/portaudio/git/source)
* [zlib](https://github.com/madler/zlib)

## Compiling

With a following wind and a lucky charm you should be able to compile it with this:

```
cd squeezeplay/src
make -f Makefile.linux
```

Good luck.

## Warning

I'm not maintaining this repo with an eye on other platforms.

It is very likely that I'll break things that are unrelated to OpenFrame devices, which are utilising the 'desktop' version of SqueezePlay. If I do manage to something useful feel free to pull it into a repo of your own!