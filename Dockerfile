FROM julia:1.10.4

RUN apt-get update \
	&& apt-get install -y --no-install-recommends apt-utils unzip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && export JULIA_DEPOT_PATH="/usr/local/julia/" \
    && julia -e 'using Pkg; Pkg.Registry.add("General"); \
	Pkg.add(url="https://github.com/rikenbit/OnlinePCA.jl"); \
	Pkg.add(url="https://github.com/rikenbit/OnlineNMF.jl"); \
	Pkg.add("PlotlyJS")'
