import sys, os, subprocess, time, datetime
from datetime import timedelta
from multiprocessing import Pool

def transformBIBF2JSON(filename):
	bashCommand = 'java -jar ../SaxonHE9-9-1-1J/saxon9he.jar inputs/segments/' + filename + ' bibframe2ef.xsl filename=' + filename[:-4]
	with open('transform_error.txt','a') as err_output:
		subprocess.call(bashCommand.split(), stderr=err_output)

def main():
	bibframe_folder = sys.argv[1]

	p = Pool(4)

	start_time = datetime.datetime.now().time()
	for root, dirs, files in os.walk(bibframe_folder):
		p.map(transformBIBF2JSON,[f for f in files if f[-4:] == '.xml'])

	end_time = datetime.datetime.now().time()
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

main()