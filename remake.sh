cd ../src_gpu

make clean-all
# make no-user-meso
# make yes-molecule
make yes-user-meso
make meso ARCH=sm_89 DEBUG=1 -j32 

cd ../test_gpu
