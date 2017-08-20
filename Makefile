.SUFFIXES: .inc .f .F
#-----------------------------------------------------------------------
# Makefile for FUJITSU VPP
# the Makefile also works on the VX series if the in the option
# -K is removed from the LINK options
#
# PLEASE READ BEFORE COMPILATION:
# 
# according to our information it is advicable to type
#    sedxcgrad xcspin.F xcgrad.F 
# before starting the makefile. Only in that case inlining will
# be done for xcspin.F and xcgrad.F. 
#
# According to Peter Kaeckell it is adviceable to set
# -DCACHE_SIZE=524287  in the line CPP
# in the INCAR file NBLK should be  set to a large value
# i.e. NBLK = 1024 
# for best performance
#
#-----------------------------------------------------------------------

# all CPP processed fortran files have the extension .f 
SUFFIX=.f

# fortran compiler
FC      = mpifrtpx  
FCL=$(FC)

# C-preprocessor define any of the flags given below
# single_precission     single precission BLAS/LAPACK calls
# vector
# essl                  use ESSL call sequence for DSYGV
# NGXhalf               charge density   reduced in X direction
# NGZhalf               charge density   reduced in Z direction
# wNGXhalf              gamma point only reduced in X direction
# wNGZhalf              gamma point only reduced in Z direction
CPP     = preprocess <$*.F| /lib/cpp -P  -traditional -DHOST=\"VPP\" \
          -DMPI -DMPI_BLOCK=8000 -Duse_collective -DscaLAPACK -DCACHE_SIZE=4000 \
          -DNGZhalf  -DUSE_ERF >$*.f


# general fortran flags
#FFLAGS = -Free -X9  -Z $*.lst -Pl -Aabm -Wv,-md,-Of,-noalias
FFLAGS = -Free -X03   -V -Ec -Qa,d,i,p,t,x  -Cpp -Ccpp
# -Wv    use VP/EX compiler
#    ,md Ouputs all vectorization messages
# -Pl    create listing with nesting level of doloops
# -Ad    single to double precission


# optimization for VPP in Paris
#OFLAG  = -Of,-p,-e -Elepmu
#OFLAG_HIGH = $(OFLAG)
#OBJ_HIGH = none
#OBJ_NOOPT = none
#DEBUG  = -On -Os,-R
##set options for inlining
#INLINE = -Ne,200
OFLAG  = -Aw -O3 -Kfast,openmp -Kopenmp -Ksimd -Kparallel -X03 -Free -Cpp

# options for linking
#LINK    = -Wl,-P,-J
#LIB     = -L. -L../vasp.5.lib -L/usr/local/lib  ../vasp.5.lib/linpack_double.o  ../vasp.5.lib/lapack_double.o -lblasvp -ldmy
#LIB     = -L. -L../vasp.lib -ldmy -L/opt/px/lib -lblasvp -llapackvp -lblasvp 
LINK    = -Kparallel 
LIB     = -L. -L../vasp.5.lib  -SCALAPACK -SSL2BLAMP  \
           ../vasp.5.lib/linpack_double.o  ../vasp.5.lib/lapack_double.o  -ldmy -lmpi \
             -lfjrtcl -lfj90i -lfj90rt -lm 

#FFT3D   = fft3dfurth.o fft3dlib.o
FFT3D   = fft3dfurth.o fftmpi.o  fftmpi_map.o   fft3dlib.o  
#FFT3D   = fft3dfujitsu.o ftflop.o

#-----------------------------------------------------------------------
# general rules and compile lines
#-----------------------------------------------------------------------
BASIC=   symmetry.o symlib.o   lattlib.o  random.o   


SOURCE=  base.o     mpi.o      smart_allocate.o      xml.o  \
         constant.o jacobi.o   main_mpi.o  scala.o   \
         asa.o      lattice.o  poscar.o   ini.o  mgrid.o  xclib.o  vdw_nl.o  xclib_grad.o \
         radial.o   pseudo.o   gridq.o     ebs.o  \
         mkpoints.o wave.o     wave_mpi.o  wave_high.o  spinsym.o \
         $(BASIC)   nonl.o     nonlr.o    nonl_high.o dfast.o    choleski2.o \
         mix.o      hamil.o    xcgrad.o   xcspin.o    potex1.o   potex2.o  \
         constrmag.o cl_shift.o relativistic.o LDApU.o \
         paw_base.o metagga.o  egrad.o    pawsym.o   pawfock.o  pawlhf.o   rhfatm.o  hyperfine.o paw.o   \
         mkpoints_full.o       charge.o   Lebedev-Laikov.o  stockholder.o dipol.o    pot.o \
         dos.o      elf.o      tet.o      tetweight.o hamil_rot.o \
         chain.o    dyna.o     k-proj.o    sphpro.o    us.o  core_rel.o \
         aedens.o   wavpre.o   wavpre_noio.o broyden.o \
         dynbr.o    hamil_high.o  rmm-diis.o reader.o   writer.o   tutor.o xml_writer.o \
         brent.o    stufak.o   fileio.o   opergrid.o stepver.o  \
         chgloc.o   fast_aug.o fock_multipole.o  fock.o  mkpoints_change.o sym_grad.o \
         mymath.o   internals.o npt_dynamics.o   dynconstr.o dimer_heyden.o dvvtrajectory.o subdftd3.o \
         vdwforcefield.o nmr.o      pead.o     subrot.o   subrot_scf.o  paircorrection.o \
         force.o    pwlhf.o    gw_model.o optreal.o  steep.o    davidson.o  david_inner.o \
         electron.o rot.o  electron_all.o shm.o    pardens.o  \
         optics.o   constr_cell_relax.o   stm.o    finite_diff.o elpol.o    \
         hamil_lr.o rmm-diis_lr.o  subrot_cluster.o subrot_lr.o \
         lr_helper.o hamil_lrf.o   elinear_response.o ilinear_response.o \
         linear_optics.o \
         setlocalpp.o  wannier.o electron_OEP.o electron_lhf.o twoelectron4o.o \
         gauss_quad.o m_unirnk.o minimax_tabs.o minimax.o \
         mlwf.o     ratpol.o screened_2e.o wave_cacher.o chi_base.o wpot.o \
         local_field.o ump2.o ump2kpar.o fcidump.o ump2no.o \
         bse_te.o bse.o acfdt.o chi.o sydmat.o \
         lcao_bare.o wnpr.o dmft.o \
         rmm-diis_mlr.o  linear_response_NMR.o wannier_interpol.o linear_response.o  auger.o getshmem.o \
         dmatrix.o

vasp: $(SOURCE) $(FFT3D) $(INC) main.o 
	rm -f vasp
	$(FCL) -o vasp main.o  $(SOURCE)   $(FFT3D) $(LIB) $(LINK)
makeparam: $(SOURCE) $(FFT3D) makeparam.o main.F $(INC)
	$(FCL) -o makeparam  $(LINK) makeparam.o $(SOURCE) $(FFT3D) $(LIB)
zgemmtest: zgemmtest.o base.o random.o $(INC)
	$(FCL) -o zgemmtest $(LINK) zgemmtest.o random.o base.o $(LIB)
dgemmtest: dgemmtest.o base.o random.o $(INC)
	$(FCL) -o dgemmtest $(LINK) dgemmtest.o random.o base.o $(LIB) 
ffttest: base.o smart_allocate.o mpi.o mgrid.o random.o ffttest.o $(FFT3D) $(INC)
	$(FCL) -o ffttest $(LINK) ffttest.o mpi.o mgrid.o random.o smart_allocate.o base.o $(FFT3D) $(LIB)
kpoints: $(SOURCE) $(FFT3D) makekpoints.o main.F $(INC)
	$(FCL) -o kpoints $(LINK) makekpoints.o $(SOURCE) $(FFT3D) $(LIB)

clean:	
	-rm -f *.g *.f *.o *.L *.mod ; touch *.F

main.o: main$(SUFFIX)
	$(FC) $(FFLAGS)$(DEBUG)  $(INCS) -c main$(SUFFIX)
xcgrad.o: xcgrad$(SUFFIX)
	$(FC) $(FFLAGS) $(INLINE)  $(INCS) -c xcgrad$(SUFFIX)
xcspin.o: xcspin$(SUFFIX)
	$(FC) $(FFLAGS) $(INLINE)  $(INCS) -c xcspin$(SUFFIX)

makeparam.o: makeparam$(SUFFIX)
	$(FC) $(FFLAGS)$(DEBUG)  $(INCS) -c makeparam$(SUFFIX)
####	
CC=mpifccpx
getshmem.o: getshmem.c
	$(CC) -c getshmem.c 

makeparam$(SUFFIX): makeparam.F main.F 
#
# MIND: I do not have a full dependency list for the include
# and MODULES: here are only the minimal basic dependencies
# if one strucuture is changed then touch_dep must be called
# with the corresponding name of the structure
#
base.o: base.inc base.F
mgrid.o: mgrid.inc mgrid.F
constant.o: constant.inc constant.F
lattice.o: lattice.inc lattice.F
setex.o: setexm.inc setex.F
pseudo.o: pseudo.inc pseudo.F
mkpoints.o: mkpoints.inc mkpoints.F
wave.o: wave.F
nonl.o: nonl.inc nonl.F
nonlr.o: nonlr.inc nonlr.F

$(OBJ_HIGH):
	$(CPP)
	$(FC) $(FFLAGS) $(OFLAG_HIGH) $(INCS) -c $*$(SUFFIX)
$(OBJ_NOOPT):
	$(CPP)
	$(FC) $(FFLAGS) $(INCS) -c $*$(SUFFIX)

fft3dlib_f77.o: fft3dlib_f77.F
	$(CPP)
	$(F77) $(FFLAGS_F77) -c $*$(SUFFIX)

.F.o:
	$(CPP)
	$(FC) $(FFLAGS) $(OFLAG) $(INCS) -c $*$(SUFFIX)
.F$(SUFFIX):
	$(CPP)
$(SUFFIX).o:
	$(FC) $(FFLAGS) $(OFLAG) $(INCS) -c $*$(SUFFIX)

