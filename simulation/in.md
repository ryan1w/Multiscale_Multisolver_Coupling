# MD simulation with GPU code and LJ settings

# settings
variable    prhi equal 36.0
variable    prlo equal 33.0
variable    frhi equal 31.0
variable    frlo equal 30.0

variable	rho equal 0.6
variable	rc equal 2.5

variable	vel equal 2.0

#**********problem setup***********

units		    lj
dimension	    3
boundary        p p f

atom_style	    dpd/atomic/meso
neighbor        3 bin
neigh_modify	delay 0 every 1 check yes

read_data       restart.data

#**********connection*************
pair_style      md/meso ${rc}
pair_coeff      * * 1.0 1.0

#***********group****************
group   flow type 1
group   wall type 2

region pregion block INF INF INF INF 290 320
region fregion block INF INF INF INF 340 350

#**************thermo***********************
compute         mythermo flow temp/meso
thermo_modify   temp mythermo

velocity        flow create 0.1 97287
run_style       mvv/meso

timestep        0.0001
thermo          100

run             1000

velocity        wall set 1.0 0.0 0.0 units box
#**************fix***************************
fix         fix_sol flow solid_bound/meso z rho5rc1s1
fix         fix_wall flow wall/meso d 1.0 f 0 z
fix         integ flow nve/meso

# fix         mui flow mui/meso/gpu mpi://domain1/interface ${prhi} ${prlo} ${frhi} ${frlo} 1.0 

# *****************data gathering*****************
# fix         fix_dump all vprof/meso output md.vprof along z component x every 2000 window 900 nbin 51

#***************run*************************

timestep     0.0001
run		     50000