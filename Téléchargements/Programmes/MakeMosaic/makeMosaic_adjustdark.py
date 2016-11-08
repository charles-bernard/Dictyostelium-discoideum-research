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
import numpy
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
	
def getPositionFolders():
	directoryContent = os.listdir(os.curdir)
	positionFolderRegex = re.compile('^[0-9]-Pos(_[0-9]{3}){2}$')
	positionFolders = filter(positionFolderRegex.search, directoryContent)
	positionFolders.sort()
	return positionFolders

def getLastPositions(lastPositionFolder):
	lastPositions = re.findall('[0-9]{3}', lastPositionFolder, flags=0)
	return int(lastPositions[0]), int(lastPositions[1])

def getImgNames(positionFolder):
	positionFolderContent = os.listdir(positionFolder)
	imgNameRegex = re.compile('^img_[0-9]{9}_(PHASE|[GR]FP|Default|PVD)_[0-9]{3}.tif$')
	imgNames = filter(imgNameRegex.search, positionFolderContent)
	imgNames.sort()
	return imgNames

def getImagesSize(imgPath, rowEnd, colEnd):
	img = cv2.imread(imgPath, -1)
	imgSize = img.shape
	mosaicSize = (imgSize[0] * (rowEnd + 1), imgSize[1] * (colEnd + 1))
	return imgSize, mosaicSize

def getChannels(imgNames):
	possibleChannels=['PHASE', 'GFP', 'RFP', 'PVD', 'Default']
	channels = [None] * len(possibleChannels)
	k = 0
	for i in range(0, len(possibleChannels)):
		channelRegex = re.compile(possibleChannels[i])
		regexMatch = filter(channelRegex.search, imgNames)
		if regexMatch:
			channels[k] = possibleChannels[i]
			k += 1
	channels = filter(None, channels)
	return channels

def testInteger(x):
	try:
		int(x)
		return True
	except ValueError:
		return False

def askConfig(mosaicSize, channels):
	#ask channel
	channel = None
	while channel not in channels:
		print("____________________________________________________________")
		print "Please, enter the channel to treat:\n" + ' '.join(channels)
		channel = raw_input("-> ")
	#ask imgReductionFactor
	imgReductionFactor = 'tmp'
	while not testInteger(imgReductionFactor):
		print("____________________________________________________________")
		print("The final size of each mosaic Image will be: %dx%d" % (mosaicSize[1], mosaicSize[0]))
		print("Please, enter the reduction factor you want to apply")
		print("to the mosaics. For instance:")
		print("\tenter '1' if you don't want to reduce the mosaics")
		print("\tenter '4' if you want to reduce 4times the mosaics")
		imgReductionFactor = raw_input("-> ")
	#ask Video
	isVideo = None
	while isVideo != 'y' and isVideo != 'n':
		print("____________________________________________________________")
		print("In addition to the generation of a Mosaic Image")
		print("at every time point, do you want to write a Video")
		print("of the timelapse ? (y/n)")
		isVideo = raw_input("-> ")
	#ask videoReductionFactor
	videoReductionFactor = 1
	isDark = 0
	if isVideo == 'y':
		videoReductionFactor = 'tmp'
		while not testInteger(videoReductionFactor):
			print("____________________________________________________________")
			print("Please, enter the reduction factor you want to apply")
			print("to each image which will compose the video")
			videoReductionFactor = raw_input("-> ")
		isDark = 'tmp'
        while not testInteger(isDark):
            print("____________________________________________________________")
            print("Please, indicate in which light conditions the timelapse")
            print("has been released")
            print("\tenter '0' for microscope illumination")
            print("\tenter '1' for no microscope illumination")
            isDark = raw_input("-> ")
	return channel, int(imgReductionFactor), isVideo, int(videoReductionFactor), int(isDark)

def getChannelImgNames(channel, imgNames):
	channelRegex = re.compile(channel)
	channelImgNames = filter(channelRegex.search, imgNames)
	channelImgNames.sort()
	return channelImgNames

def getLastTimePoint(lastImgName):
	lastTimePoint = re.search('[0-9]{9}', lastImgName, flags = 0)
	return int(lastTimePoint.group(0))

def getTimeSpan(imgNames):
	t0 = re.search('[0-9]{9}', imgNames[0])
	t1 = re.search('[0-9]{9}', imgNames[1])
	tSpan = int(t1.group(0)) - int(t0.group(0))
	return tSpan

def convert_uint16Grayscale_to_RGB(uint16Grayscale, isDark):
	height, width = uint16Grayscale.shape
	uint8RGB = numpy.zeros((height, width, 3), numpy.uint8)
	# linear scaling conversion
	if isDark == 0:
		oldMax = 2 ** 16 - 1
		oldMin = 0
	else:
		oldMax = numpy.amax(uint16Grayscale)
		oldMin = numpy.amin(uint16Grayscale)
	oldRange = oldMax - oldMin
	newMax = 2**8 - 1
	newMin = 0
	newRange = newMax - newMin
	floatGrayscale = uint16Grayscale.astype(float)
	floatGrayscale = (((floatGrayscale - oldMin) * newRange) / oldRange) + newMin
	uint8Grayscale = floatGrayscale.astype(numpy.uint8)
	for i in range(0, 3):
		uint8RGB[:, :, i] = uint8Grayscale
	return uint8RGB

def makeMosaic(positionFolders, channel, date, channelImgNames, imgSize, mosaicSize, rowEnd, colEnd, tEnd, tSpan, imgReductionFactor, isVideo, videoReductionFactor, isDark):
	outputDirectory = '0-Mosaics/' + channel
	if not os.path.isdir(outputDirectory):
		os.makedirs(outputDirectory)

	if imgReductionFactor != 1:
		mosaicReducedSize = (int(round(mosaicSize[0] / float(imgReductionFactor))), int(round(mosaicSize[1] / float(imgReductionFactor))))
	if isVideo == 'y':
		videoName = outputDirectory + '/video_' + channel + '_' + date + '.avi'
		codec = cv2.VideoWriter_fourcc('M','J','P','G')
		fps = 5.0
		if videoReductionFactor == 1:
			videoSize = mosaicSize
		elif videoReductionFactor == imgReductionFactor:
			videoSize = mosaicReducedSize
		else:
			videoSize = (int(round(mosaicSize[0] / float(videoReductionFactor))), int(round(mosaicSize[1] / float(videoReductionFactor))))
		video = cv2.VideoWriter(videoName, codec, fps, (videoSize[1], videoSize[0]))

	print("____________________________________________________________")
	print("Assembling the Mosaics:")
	nb_t = tEnd / tSpan + 1
	op = 1
	nb_op = (rowEnd + 1) * (colEnd + 1) * nb_t
	for t in range(0, nb_t):
		k = 0
		mosaic = numpy.zeros(mosaicSize, numpy.uint16)
		mosaicPath = outputDirectory + '/t_' + '%4d' % (t*tSpan) + '.tif'
		mosaicPath = mosaicPath.replace(" ", "0")
		for col in range(0, colEnd + 1):
			for row in range(0, rowEnd + 1):
				sys.stdout.write('\r' + 't-(%d/%d) | position-(%d/%d)_(%d/%d) | operation-(%d/%d)     \t' \
								 % (t, nb_t-1, col, colEnd, row, rowEnd, op, nb_op))
				sys.stdout.flush()
				img = cv2.imread(positionFolders[k] + '/' + channelImgNames[t], -1)
				mosaic[(mosaicSize[0] - imgSize[0]*(1+row)):(mosaicSize[0] - imgSize[0]*row), \
						(mosaicSize[1] - imgSize[1]*(1+col)):(mosaicSize[1] - imgSize[1]*col)] = img
				op += 1
				k += 1

		if imgReductionFactor != 1:
			reducedMosaic = cv2.resize(mosaic, (mosaicReducedSize[1], mosaicReducedSize[0]), interpolation=cv2.INTER_LANCZOS4)
			cv2.imwrite(mosaicPath, reducedMosaic)
		else:
			cv2.imwrite(mosaicPath, mosaic)

		if isVideo == 'y':
			if videoReductionFactor == 1:
				videoMosaic = convert_uint16Grayscale_to_RGB(mosaic)
			elif videoReductionFactor == imgReductionFactor:
				videoMosaic = convert_uint16Grayscale_to_RGB(reducedMosaic, isDark)
			else:
				videoMosaic = cv2.resize(mosaic, (videoSize[1], videoSize[0]), interpolation=cv2.INTER_LANCZOS4)
				videoMosaic = convert_uint16Grayscale_to_RGB(videoMosaic, isDark)
			video.write(videoMosaic)
	if isVideo == 'y':
		cv2.destroyAllWindows()
		video.release()
	print

def main():
	directory = askDirectory()
	os.chdir(directory)
	date = extractDate(directory)
	displayInfo(directory, date)

	positionFolders = getPositionFolders()
	colEnd, rowEnd = getLastPositions(positionFolders[-1])

	imgNames = getImgNames(positionFolders[-1])
	imgSize, mosaicSize = getImagesSize(positionFolders[0] + '/' + imgNames[0], rowEnd, colEnd)

	channels = getChannels(imgNames)
	channel, imgReductionFactor, isVideo, videoReductionFactor, isDark = askConfig(mosaicSize, channels)
	channelImgNames = getChannelImgNames(channel, imgNames)
	del imgNames, channels

	tEnd = getLastTimePoint(channelImgNames[-1])
	if tEnd > 0:
		tSpan = getTimeSpan(channelImgNames[0:2])
		tEnd = tEnd - (tEnd % tSpan)
	else:
		tSpan = 1

	makeMosaic(positionFolders, channel, date, channelImgNames, imgSize, mosaicSize, rowEnd, colEnd, tEnd, tSpan, imgReductionFactor, isVideo, videoReductionFactor, isDark)

main()
