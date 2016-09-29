# Classification of occluded images in neural networks and humans
##### Kreiman Lab, Harvard Medical School

Constraints:
* only train on whole images, test on occluded ones
* use the same classifier on top of all the different feature extractors


## Troubleshooting
### libsvm compilation fails on Linux
To resolve the error 
`cc1plus: error: unrecognized command line option "-std=c++11"`
when compiling libsvm inside Matlab, 
compile outside Matlab by typing `make matlab`.