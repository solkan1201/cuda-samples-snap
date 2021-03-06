#!/bin/bash -e

files=$(cat input_files_from_cuda_samples)

# assumes that the nvidia examples have been put into $SNAPCRAFT_STAGE
cd $SNAPCRAFT_STAGE/NVIDIA_CUDA-9.1_Samples

# handle any artifacts needed for individual targets
mkdir -p $SNAPCRAFT_PART_INSTALL/data/
for dataFile in "$files"; do
    cp $dataFile $SNAPCRAFT_PART_INSTALL/data/
done

mkdir -p $SNAPCRAFT_PART_INSTALL/bin
# only go into directories that match "*_*", i.e. like 0_Simple, 1_Utilities, etc.
for sampleType in $(ls -d *_*); do
    pushd $sampleType > /dev/null
    mkdir -p $SNAPCRAFT_PART_INSTALL/bin/$sampleType
    for sampleProg in $(ls -d *); do
        case "$sampleProg" in 
            common)
                # data directory - not a sample program
                ;;
            simpleGLES|simpleGLES_EGLOutput|simpleGLES_screen|EGLStream_CUDA_CrossGPU|EGLStreams_CUDA_Interop|fluidsGLES|nbody_opengles|nbody_screen)
                # don't build these examples
                # these examples require OpenGL ES, which we don't currently install
                ;;
            cudaDecodeGL)
                # this sample is written poorly and needs to have the libraries moved around as it looks in the wrong place
                #, so for now just don't compile it
                ;;
            *)
                pushd $sampleProg > /dev/null
                # compile the sample program using specific GLPATH
                GLPATH=/usr/lib make
                # copy the sample program to the install directory for this sample
                cp $sampleProg $SNAPCRAFT_PART_INSTALL/bin/$sampleType/$sampleProg
                # make a symbolic link from the bin folder to the sample folder
                pushd $SNAPCRAFT_PART_INSTALL/bin > /dev/null
                ln -s $sampleType/$sampleProg $sampleProg
                popd > /dev/null
                popd > /dev/null
                ;;
        esac
        
    done
    popd > /dev/null
done
