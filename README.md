# Research at the Kreiman Lab, Harvard Medical School

Projects:

* pattern completion: recognize occluded images after training on whole images


## Troubleshooting
### libsvm compilation fails on Linux
To resolve the error 
`cc1plus: error: unrecognized command line option "-std=c++11"`
when compiling libsvm inside Matlab, 
compile outside Matlab by typing `make matlab`.