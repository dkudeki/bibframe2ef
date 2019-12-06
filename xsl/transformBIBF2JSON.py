import sys, os, subprocess, time, datetime
from multiprocessing import Pool
from datetime import timedelta
from itertools import repeat
from functools import wraps

def unpack(func):
	@wraps(func)
	def wrapper(arg_tuple):
		return func(*arg_tuple)
	return wrapper

@unpack
def applyXSLStylesheetToBIBFRAMEXML(filename,input_folder,output_folder,saxon_jar):
	print(filename)
	bashCommand = 'java -jar ' + saxon_jar + ' ' + input_folder + filename + ' bibframe2ef.xsl'

	try:
		os.mkdir(output_folder + 'complete/' + filename[:filename.find('.')])
	except:
		pass

	with open(output_folder + 'complete/' + filename[:filename.find('.')] + '/' + filename[:-4] + '.json','w') as std_output:
		with open(output_folder + 'reports/transform_error.txt','a') as err_output:
			print("Calling saxon for " + filename)
			err_output.write(filename + '\n')
			results = subprocess.call(bashCommand.split(), stdout=std_output, stderr=err_output)
			print("Finished transforming " + filename)

def transformBIBF2JSON(input_folder,output_folder,saxon_jar,core_count):
	start_time = datetime.datetime.now()
	p = Pool(core_count)
	for root, dirs, files in os.walk(input_folder):
		p.map(applyXSLStylesheetToBIBFRAMEXML,iterable=zip([f for f in files if f[-4:] == '.xml'],repeat(input_folder),repeat(output_folder),repeat(saxon_jar)))

	end_time = datetime.datetime.now()
	print('XSL TRANSFORM:')
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(end_time-start_time))

if __name__ == "__main__":
	transformBIBF2JSON(sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4]))