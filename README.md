# Internship_Dictyostelium-discoideum

This repo is of no use for the general public, just some codes I developped during an Internship and
which might be only useful for people working on timelapse fluorescence microscopy of phototaxis migration.

## BinocularTimelapseManager

Scripts autoit3 to couple:

- the leds via the arduino Manager
- the camera via Snappixx

These scripts are meant to be run under a Windows 
environment, on the computer next to the incubator
	
In order to configure the timelapse, open the 
desired script and change the local variables at
the beginning

Don't forget to compile the script on the according
computer before running it

Which script to be executed ?
- to test if there is a memory effect of the taxis: 
     _**obsolete_PhototaxisLightSwitches.au3**_
- to analyse the reaction time of the slugs when the location of the light source changes: PhototaxisPreciseLightSwitches.au3
- to see what happened if one switches from one led turned on to two leds turned on together: PhototaxisLightSwitches2Leds.au3

## Dictyostomic

Two bash scripts:
-dictype.sh: 
meant to get the info & the expression profile 
		of the genes that are specific to the prespore 
		and to the prestalk celltype.
		The genes are further clustered according to
		their expression profile
	-dictyostomic.sh:
		meant to get the expression profile of a gene
		or a set of genes entered by the user

	The two scripts couple the dictybase database, 	
	transcriptomic data and R via data mining tools
	 
	to run them:
	-open a terminal
	-go to the directory where the script are stored (use cd)
	-enter the desired following command:
		./dictype.sh
		./dictyostomic.sh
		
3. ErasePicturesAfterCulmination
	A bash script:
	-erase_culmination.sh

	This script is meant to erase all the pictures 
	of the timelapse that are recorded after the culmination
	of all the slugs in order to save memory space.

	to run it:
	-open a terminal
	-go to the directory where the script are stored (use cd)
	-enter the desired following command:
		./erase_culmination.sh

4. makeMosaic
	a python 2.7 script:
	-makemosaic.py

	This script is meant to generate an image mosaic
	at each time point of the timelapse and a video 
	of the timelapse.

	warning: works only with images ordered via micromanager 	 
	configured with the flipper on the fly processor

	to run it:
	-open a terminal
	-go to the directory
	-enter the command:
		python makemosaic.py
	
	My standard configuration:
	for PHASE: ImageReductionFactor = 5, isVideo = y, VideoReductionFactor = 10
	for [GR]FP : ImageReductionFactor = 1, isVideo = n

	NB: Recquires the following libraries:
	-numpy
	-cv2 (openCv) version 3.0.0 

	In order to be able to run the program on an other computer:
	install cv2 according to the following tutorial:
	-http://www.pyimagesearch.com/2015/06/22/install-opencv-3-0-and-python-2-7-on-ubuntu/
		

