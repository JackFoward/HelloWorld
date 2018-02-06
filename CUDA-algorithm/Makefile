#$L$
# Copyright (C) 2017 RidgeRun, LLC (http://www.ridgerun.com)
#$L$

NVCC=nvcc
CXX=g++
CXX_FLAGS=-O3 -Wall
CUDA_INCLUDEPATH=/usr/local/cuda-8.0/include
NVCC_OPTS=-O3 -arch=sm_30 -Xcompiler -Wall -Xcompiler -Wextra -m64 -D_FORCE_INLINES

cuda_mixer: main.o mixer.o
	$(NVCC) -o $@ $^ -L $(NVCC_OPTS)

main.o: main.c
	$(CXX) -c $^ $(CXX_FLAGS) -I $(CUDA_INCLUDEPATH)

mixer.o: mixer.cu
	$(NVCC) -c $^ $(NVCC_OPTS)

.PHONY: clean

clean:
	rm -f *.o cuda_mixer
