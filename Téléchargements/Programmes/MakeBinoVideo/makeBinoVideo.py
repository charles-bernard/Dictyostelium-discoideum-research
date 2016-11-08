#!/usr/bin/python

# Author:	Charles Bernard
# Contact:	charles.bernard@cri-paris.org

### Mosaic Structure ####
#########################
# | 001_001 | 000_001 | #
# | 001_000 | 000_000 | #
#########################
import os
import re
import sys
import cv2

def askDirectory():
	import Tkinter, Tkconstants, tkFileDialog
	root = Tkinter.Tk()
	directory = tkFileDialog.askdirectory(parent=root, initialdir="/", title='Please, select a directory')
	return directory

def extractDate(directory):
	date = re.search('[0-9]{1,4}[/.][0-9]{1,2}[/.][0-9]{1,4}', directory, flags = 0)
	if date:
		return date.group(0)
	return ''

def displayInfo(directory, date):
	print("____________________________________________________________")
	print("Directory:")
	print directory
	print("____________________________________________________________")
	print("Date:")
	print date

def getImgNames():
	directoryContent = os.listdir(os.curdir)
	imgNameRegex = re.compile('^DSCN[0-9]{4}\.JPG')
	imgNames = filter(imgNameRegex.search, directoryContent)
	imgNames.sort()
	return imgNames

def getImgSize(imgPath):
	img = cv2.imread(imgPath)
	imgSize = img.shape
	return imgSize

def makeTimelapseVideo(imgNames, imgSize, date):
	outputDirectory = '0-TimelapseVideo'
	if not os.path.isdir(outputDirectory):
		os.makedirs(outputDirectory)

	videoName = outputDirectory + '/timelapseVideo_' + date + '.avi'
	codec = cv2.VideoWriter_fourcc('M', 'J', 'P', 'G')
	fps = 5.0
	video = cv2.VideoWriter(videoName, codec, fps, (imgSize[1], imgSize[0]))

	print("____________________________________________________________")
	print("Building the timelapse Video:")
	nb_t = len(imgNames)
	for t in range(0, nb_t):
		sys.stdout.write('\r' + 't-(%d/%d)     \t' % (t, nb_t-1))
		sys.stdout.flush()
		img = cv2.imread(imgNames[t])
		video.write(img)
	cv2.destroyAllWindows()
	video.release()
	print

def main():
	directory = askDirectory()
	os.chdir(directory)
	date = extractDate(directory)
	displayInfo(directory, date)

	imgNames = getImgNames()
	imgSize = getImgSize(imgNames[0])

	makeTimelapseVideo(imgNames, imgSize, date)

main()
