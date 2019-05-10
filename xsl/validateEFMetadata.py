import sys, os, subprocess, time, datetime
from datetime import timedelta
from multiprocessing import Pool

def transformGeneratedXML(generated_xml):
	bashCommand = 'xsltproc ./bibframe2ef.xsl ' + xml_input_file

def validate(file):
	bashCommand = 'ajv validate -s ../schemas/EF-Schema/ef_2_20_schema.json -d ../outputs/complete/' + file
	with open('reports/output_validation.txt','a') as err_output:
		subprocess.call(bashCommand.split(), stderr=err_output)

def main():
	json_folder = '../outputs/complete'

	if len(sys.argv) > 1:
		p = Pool(sys.argv[1])
	else:
		p = Pool(4)

	start_time = datetime.datetime.now().time()
	for root, dirs, files in os.walk(json_folder):
		p.map(validate,files)

	end_time = datetime.datetime.now().time()
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))

main()