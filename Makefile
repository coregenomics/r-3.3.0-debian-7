R-3.3.0.simg : Singularity
	sudo singularity build $@ $<

R-3.3.0-spack.simg : Singularity.spack
	sudo singularity build $@ $<
