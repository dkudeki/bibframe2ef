import sys, os, subprocess, time, datetime
from multiprocessing import Pool
from datetime import timedelta
from itertools import repeat

def applyXSLStylesheetToBIBFRAMEXML(filename,input_folder,output_folder,saxon_jar):
	print(filename)
	bashCommand = 'java -jar ' + saxon_jar + ' ' + input_folder + filename + ' bibframe2ef.xsl output_folder=' + output_folder + ' filename=' + filename[:-4]
	with open(output_folder + 'reports/transform_error.txt','a') as err_output:
		print("Calling saxon for " + filename)
		subprocess.call(bashCommand.split(), stderr=err_output)
		print("Finished transforming " + filename)

def transformBIBF2JSON(input_folder,output_folder,saxon_jar,core_count):
	start_time = datetime.datetime.now().time()
	p = Pool(core_count)
	for root, dirs, files in os.walk(input_folder):
		p.starmap(applyXSLStylesheetToBIBFRAMEXML,zip([f for f in files if f[-4:] == '.xml'],repeat(input_folder),repeat(output_folder),repeat(saxon_jar)))

	end_time = datetime.datetime.now().time()
	print('XSL TRANSFORM:')
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

if __name__ == "__main__":
	transformBIBF2JSON(sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4]))