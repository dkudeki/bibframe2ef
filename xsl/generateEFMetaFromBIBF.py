import sys, os, subprocess, time, datetime, re
import transformBIBF2JSON
import mergeDicts
import fillIncompleteResults
import validateEFMetadata
from datetime import timedelta

if os.name == 'nt':
	SLASH = '\\'
else:
	SLASH = '/'

# Pipeline: transformBIBF2JSON -> mergeDicts -> fillIncompleteResults -> validateEFMetadata
# Inputs:
#	input folder			- Holds BIBFRAME XML version of metadata
#	output folder			- Folder where output should be written to
#	saxon jar				- Path to Saxon jar file (saxon9he.jar) we use to apply XSL transform
#	number of cores to use	- Optional, defaults to 4 if no input
#	do not validate			- Optional, shortens running time, validation can be run seperately in the future

def printHelp():
	print('Convert a folder of BIBFRAME XML files and turn them into Extracted Features Metadata Files\n\nUsage: \n\tpython generateEFMetaFromBIBF.py input_folder output_folder saxon_jar [--cores=NUMBER | -c=NUMBER] [--fast | -f]\n\nRequirements:\n\tinput_folder:\tFolder containing the BIBFRAME XML files being transformed\n\toutput_folder:\tFolder where the output folders should be written to. This folder will contain three output folders: complete, dicts and incomplete\n\tsaxon_jar:\tThe location of the saxon9he.jar file, which is used to run the stylesheet\n\nOptions:\n\t--cores=NUMBER | -c=NUMBER:\tNumber of cores that should be used to run the parallel parts of the script\n\t--fast | -f:\tIncrease speed of processing by skipping validation step')
	sys.exit()

def validateInput():
	print(sys.argv)
	option_regex = r"^--cores=[1-9][0-9]?$|^-c=[1-9][0-9]?$|^--fast$|^-f$"
	if os.path.exists(sys.argv[1]):
		if len(sys.argv) > 4:
			if re.search(option_regex,sys.argv[4]):
				if len(sys.argv) > 5:
					if re.search(option_regex,sys.argv[5]):
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

def callPipeline(input_folder,output_folder,saxon_jar,core_count,validate):
	start_time = datetime.datetime.now().time()

	transformBIBF2JSON.transformBIBF2JSON(input_folder,output_folder,saxon_jar,core_count)
	mergeDicts.mergeDicts(output_folder)
	fillIncompleteResults.fillIncompleteResults(output_folder)
	if (validate):
		validateEFMetadata.validateEFMetadata(output_folder,core_count)

	end_time = datetime.datetime.now().time()
	print('PIPELINE TIMELINE:')
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

def generateEFMetaFromBIBF():
	if len(sys.argv) < 4 or len(sys.argv) > 6 or sys.argv[1] == '-h' or sys.argv[1] == '--help':
		printHelp()
	else:
		if validateInput():
			input_folder = sys.argv[1]
			output_folder = sys.argv[2]
			saxon_jar = sys.argv[3]
			core_count = 4
			validate = True

			if len(sys.argv) > 4:
				core_regex = r"^--cores=[1-9][0-9]?$|^-c=[1-9][0-9]?$"
				no_validation_regex = r"^--fast$|^-f$"
				if re.search(no_validation_regex,sys.argv[4]):
					validate = False
				elif re.search(core_regex,sys.argv[4]):
					core_count = int(sys.argv[4][sys.argv[4].rfind('=')+1:])
					if core_count > 40:
						print("Too many cores. Please try again with fewer cores.")
						sys.exit()
				else:
					print("First optional input not formatted correctly")

				if len(sys.argv) > 5:
					if re.search(no_validation_regex,sys.argv[5]):
						validate = False
					elif re.search(core_regex,sys.argv[5]):
						core_count = int(sys.argv[5][sys.argv[5].rfind('=')+1:])
						if core_count > 40:
							print("Too many cores. Please try again with fewer cores.")
							sys.exit()
					else:
						print("Second optional input not formatted correctly")

			if input_folder[-1:] != SLASH:
				input_folder += SLASH
			if output_folder[-1:] != SLASH:
				output_folder += SLASH
			if not os.path.exists(output_folder + 'reports'):
				os.mkdir(output_folder + 'reports')

			print(core_count)
			callPipeline(input_folder,output_folder,saxon_jar,core_count,validate)
		else:
			printHelp()

generateEFMetaFromBIBF()