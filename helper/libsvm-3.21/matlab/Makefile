# This Makefile is used under Linux

MATLABDIR ?= /opt/matlab-2016a
# for Mac
# MATLABDIR ?= /opt/local/matlab

CXX ?= g++
#CXX = g++-4.1
CFLAGS = -Wall -Wconversion -O3 -fPIC -I$(MATLABDIR)/extern/include -I..

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC="$(CXX)" CXX="$(CXX)" CFLAGS="$(CFLAGS)" CXXFLAGS="$(CFLAGS)"
# comment the following line if you use MATLAB on 32-bit computer
MEX_OPTION += -largeArrayDims
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

all:	matlab

matlab:	binary

octave:
	@echo "please type make under Octave"

binary: libsvmpredict.$(MEX_EXT) libsvmtrain.$(MEX_EXT) libsvmread.$(MEX_EXT) libsvmwrite.$(MEX_EXT)

libsvmpredict.$(MEX_EXT):     libsvmpredict.c ../svm.h ../svm.o svm_model_matlab.o
	$(MEX) $(MEX_OPTION) libsvmpredict.c ../svm.o svm_model_matlab.o

libsvmtrain.$(MEX_EXT):       libsvmtrain.c ../svm.h ../svm.o svm_model_matlab.o
	$(MEX) $(MEX_OPTION) libsvmtrain.c ../svm.o svm_model_matlab.o

libsvmread.$(MEX_EXT):	libsvmread.c
	$(MEX) $(MEX_OPTION) libsvmread.c

libsvmwrite.$(MEX_EXT):	libsvmwrite.c
	$(MEX) $(MEX_OPTION) libsvmwrite.c

svm_model_matlab.o:     svm_model_matlab.c ../svm.h
	$(CXX) $(CFLAGS) -c svm_model_matlab.c

../svm.o: ../svm.cpp ../svm.h
	make -C .. svm.o

clean:
	rm -f *~ *.o *.mex* *.obj ../svm.o
