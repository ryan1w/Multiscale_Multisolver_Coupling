#**********************************************************************
##**********************************************************************
## Define all the variables
## ndim                     : dimension of the system
## kBT                      : normalized temperature
## seed                     : seed for random number generator
## rc                       : cutoff radius
## skin                     : surround skin for neighbor list
##
## a0                       : coefficient for conservative force
## gamma_r                  : friction coefficient
##
## xlo xhi ylo yhi zlo zhi  : size of the cubic computational box
## nden                     : number denstiy
## Ntype                    : number of types of particles
## mass                     : mass of particle type 1
## scale_lb                 : scale of lattice to box
## Npart                    : number of particles
##
## relax                    : timestep for relax the system
## ntime                    : total number of timestep for the simulation
## dt                       : timestep
## thermo                   : frequency for screen print
## dump                     : timestep for write_out
##
## gx			    : driving force
##
## Nevery                   : Nevery for fix/ave
## Nrepeat                  : Nrepeat for fix/ave
## Nfreq                    : Nfreq for fix/ave
##**********************************************************************
variable  ndim      equal 3
variable  kBT       equal 1.0
variable  seed      equal 2654868
variable  rc        equal 1.0
variable  skin      equal 0.3*${rc}

variable  a0        equal 25
variable  sigma     equal 3.0
variable  gamma     equal ${sigma}^2/(2*${kBT})

variable  xlo       equal 0.0
variable  xhi       equal 30.0
variable  ylo       equal 0.0
variable  yhi       equal 30.0
variable  zlo       equal 0.0
variable  zhi       equal 10.0

variable  nden      equal 3.0
variable  Ntype     equal 1
variable  mass      equal 1.0
variable  scale_lb  equal ${nden}/1.0
variable  Npart     equal round((${xhi}-${xlo})*(${yhi}-${ylo})*(${zhi}-${zlo})*${nden})

variable  relax     equal 5000
variable  ntime     equal 5000
variable  dt        equal 0.001
variable  thermo    equal 1000
variable  dump      equal 2000

variable  gx        equal 0.02

variable  Nevery    equal 2
variable  Nrepeat   equal round(0.25*${ntime}/${Nevery})
variable  Nfreq     equal round(0.5*${ntime})
variable  bin       equal 40
#**********************************************************************
## End of the definition of variables
##**********************************************************************

##**********************************************************************
## Start of defining the particle system
##**********************************************************************
units           lj
dimension       ${ndim}
boundary        p p p
neighbor        ${skin} bin
neigh_modify    every 1 delay 0 check yes

##**********************************************************************
## Use the atom_style: atomic
##**********************************************************************
atom_style      atomic
comm_modify vel yes

##**********************************************************************
## Generate the particles by random
##**********************************************************************
region    sim_box  block ${xlo} ${xhi} ${ylo} ${yhi} ${zlo} ${zhi} units box
create_box     ${Ntype} sim_box
create_atoms   ${Ntype} random ${Npart} ${seed} NULL

##**********************************************************************
# use the pair_style: dpd or lj/cut
# dpd requires 3 parameters : kBT cut_off seed
##**********************************************************************
# pair_style      dpd ${kBT} ${rc} ${seed} 2 0
pair_style      lj/cut 2.5

##**********************************************************************
## Define the coefficients for pair-wise interactions
## dpd coefficient requires 5 parameters :
## itype jtype a0 gamma cut_ij
##**********************************************************************
# pair_coeff      1 1 ${a0} ${gamma} ${rc}
# mass            1 ${mass}

pair_coeff      1 1 1.0 1.0 
mass            1 ${mass}

##----------------------------------------------------------------------
## thermodynamics
##----------------------------------------------------------------------
compute        mythermo all temp/partial 0 1 1
thermo         ${thermo}
thermo_modify  temp mythermo
thermo_modify  flush yes

##----------------------------------------------------------------------
## initial the velocity of the particles
##----------------------------------------------------------------------
# velocity       all create ${kBT} ${seed} loop local dist gaussian
velocity       all create 1.0 ${seed}

##----------------------------------------------------------------------
## Integration of particles' position, velocity
##----------------------------------------------------------------------
fix integrate  all nve

# fix	  tmp all temp/rescale 200 1.0 1.0 0.02 1.0

##----------------------------------------------------------------------
## Relax the system
##----------------------------------------------------------------------
minimize 0 0 1000 1000
timestep        ${dt}
run             ${relax}
reset_timestep  0

##----------------------------------------------------------------------
## Apply the driving force
##----------------------------------------------------------------------
# variable        ymid  equal  (${yhi}+${ylo})/2
# variable        fx atom mass*${gx}*((y>${ymid})-(y<${ymid}))
# # variable        fx atom mass*${gx}
fix             reverce_periodic all addforce 1.0 0.0 0.0

##----------------------------------------------------------------------
## Extract the velocity profile
##----------------------------------------------------------------------
variable        delta  equal  (${yhi}-${ylo})/${bin}
compute cc1 	all chunk/atom bin/1d y 0.0 ${delta}
fix 	stat 	all ave/chunk  ${Nevery} ${Nrepeat} ${Nfreq} cc1 vx norm sample file vel.profile

##----------------------------------------------------------------------
## Output and dump simulation data
##----------------------------------------------------------------------
# dump   atom     all atom ${dump} atom.lammpstrj

dump myDump all custom 1000 output.dump id type vx vy vz
##----------------------------------------------------------------------
## Run simulation 
##----------------------------------------------------------------------
timestep       ${dt}
run            ${ntime}

########################################################################
####
#### Input file Ends !
#### 
########################################################################
