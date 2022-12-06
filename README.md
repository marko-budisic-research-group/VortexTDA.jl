# Vortex TDA
Topological data analysis for vortex-dominated fluid flows.

This repository primarily contains Julia scripts used to process either trajectories of vortex cores or spatial fields (velocity, vorticity, etc.) associated with vortex flows.

# How to use this package

If you want to apply this package to your data (but not necessarily change any of its code), then first you need to add it to your local `julia` environment by running

```
] add https://github.com/marko-budisic-research-group/VortexTDA.jl
```
Since the package is unregistered `] add VortexTDA` will not work.

You need to do this only once per environment (if you added it to the default environment, it's enough to do it once).

Then in your specific script/notebook run 
```
using VortexTDA
```
or
```
import VortexTDA
```
to be able to access the functions.


# How to develop this package

If you want to _develop_ the package, e.g., add a new function, or change its functionality, then instead of `add` as above, you would run
```
] dev https://github.com/marko-budisic-research-group/VortexTDA.jl
```
or
```
using Pkg
Pkg.develop("https://github.com/marko-budisic-research-group/VortexTDA.jl")
```
which may be needed inside a Pluto notebook.

This clones the package from GitHub to your local development folder. By default, for Mac and Linux users this is in `~/.julia/dev/VortexTDA' and for Windows users 

Alternatively, if the code for the package already resides locally, you could run 
```
] dev path/to/local/repository/of/VortexTDA
```

This signals to `julia` that it is supposed to be using the local version of the package instead of looking for it in the official registry. (This also means that if you ever want to `add` this package again, you'd need to first run `] free VortexTDA` )

Now, inside your Julia REPL you would likely want to activate
```
julia> using Revise
```
so that any changes to the package that you're making in an editor appear live in your environment.
