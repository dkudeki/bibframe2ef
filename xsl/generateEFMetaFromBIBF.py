import sys, os, subprocess, time, datetime, re
import transformBIBF2JSON
import mergeDicts
from datetime import timedelta

if os.name == 'nt':
	SLASH = '\\'
else:
	SLASH = '/'

# Pipeline: transformBIBF2JSON -> mergeDicts -> fillIncompleteResults -> validateEFMetadata
# Inputs:
#	input folder			- Holds BIBFRAME XML version of metadata
#	output folder			- folder where output should be written to
#	number of cores to use	- Optional, defaults to 4 if no input
#	do not validate			- Optional, shortens running time, validation can be run seperately in the future

def printHelp():
	print('Convert a folder of BIBFRAME XML files and turn them into Extracted Features Metadata Files\n\nUsage: \n\tpython generateEFMetaFromBIBF.py input_folder output_folder [--cores=NUMBER | -c=NUMBER] [--fast | -f]\n\nOptions:\n\t--cores=NUMBER | -c=NUMBER:\tNumber of cores that should be used to run the parallel parts of the script\n\t--fast | -f:\tIncrease speed of processing by skipping validation step')
	sys.exit()

def validateInput():
	print(sys.argv)
	option_regex = r"^--cores=[1-9]$|^-c=[1-9]$|^--fast$|^-f$"
	if os.path.exists(sys.argv[1]):
		if len(sys.argv) > 3:
			if re.search(option_regex,sys.argv[3]):
				if len(sys.argv) > 4:
					if re.search(option_regex,sys.argv[4]):
						if not os.path.exists(sys.argv[2]):
							os.mkdir(sys.argv[2])
						return True
					else:
						return False
				if not os.path.exists(sys.argv[2]):
					os.mkdir(sys.argv[2])
				return True
			else:
				return False
		if not os.path.exists(sys.argv[2]):
			os.mkdir(sys.argv[2])
		return True
	else:
		return False

def callPipeline(input_folder,output_folder,core_count,validate):
	transformBIBF2JSON.transformBIBF2JSON(input_folder,output_folder,core_count)
#	mergeDicts.mergeDicts(output_folder)
	print(input_folder,output_folder,core_count,validate)

def generateEFMetaFromBIBF():
	if len(sys.argv) < 3 or len(sys.argv) > 5 or sys.argv[1] == '-h' or sys.argv[1] == '--help':
		printHelp()
	else:
		if validateInput():
			input_folder = sys.argv[1]
			output_folder = sys.argv[2]
			core_count = 4
			validate = True

			if len(sys.argv) > 3:
				core_regex = r"^--cores=[1-9]$|^-c=[1-9]$"
				no_validation_regex = r"^--fast$|^-f$"
				if re.search(no_validation_regex,sys.argv[3]):
					validate = False
				elif re.search(core_regex,sys.argv[3]):
					core_count = int(sys.argv[3][sys.argv[3].rfind('=')+1:])

				if len(sys.argv) > 4:
					if re.search(no_validation_regex,sys.argv[4]):
						validate = False
					elif re.search(core_regex,sys.argv[4]):
						core_count = int(sys.argv[4][sys.argv[4].rfind('=')+1:])

			if input_folder[-1:] != SLASH:
				input_folder += SLASH
			if output_folder[-1:] != SLASH:
				output_folder += SLASH
			if not os.path.exists(output_folder + 'reports'):
				os.mkdir(output_folder + 'reports')

			callPipeline(input_folder,output_folder,core_count,validate)
		else:
			printHelp()

generateEFMetaFromBIBF()