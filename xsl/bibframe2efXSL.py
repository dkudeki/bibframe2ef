import sys, os, subprocess, time, datetime
from lxml import etree
from collections import OrderedDict
from datetime import timedelta
from multiprocessing import Pool

def transformGeneratedXML(generated_xml):
	bashCommand = 'xsltproc ./bibframe2ef.xsl ' + xml_input_file


def generateXMLTripleForVolumes(volume_ids,tree,work,instance):
	xslt = etree.parse('./bibframe2ef.xsl')
	transform = etree.XSLT(xslt)

	for volume in volume_ids:
		print(volume)
		volume_metadata = tree.xpath("bf:Item[@rdf:about = '" + volume + "']",namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})
		item = volume_metadata[0]
#		print(etree.tostring(volume_metadata[0]))
		instance_id = item.xpath("bf:itemOf/@rdf:resource",namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})[0]
		if instance['id'] != instance_id:
			print(instance_id)
			#Insert Database code here to store old instance info if needed
			instance_metadata = tree.xpath("bf:Instance[@rdf:about = '" + instance_id + "']",namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})

			instance['id'] = instance_id
			instance['metadata'] = instance_metadata[0]

		work_id = instance['metadata'].xpath("bf:instanceOf/@rdf:resource",namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})[0]
		if work['id'] != work_id:
			print(work_id)
			#Insert Database code here to store old work info if needed
			work_metadata = tree.xpath("bf:Work[@rdf:about = '" + work_id + "']",namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})

			work['id'] = work_id
			work['metadata'] = work_metadata[0]

		new_tree = etree.XML('<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:bf="http://id.loc.gov/ontologies/bibframe/" xmlns:bflc="http://id.loc.gov/ontologies/bflc/" xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#" xmlns:dct="http://purl.org/dc/terms/" xmlns:htrc="http://wcsa.htrc.illinois.edu/">\n  </rdf:RDF>')
		new_tree.insert(0,work['metadata'])
		new_tree.insert(1,instance['metadata'])
		new_tree.insert(2,item)
		try:
			result = transform(new_tree)
			result.write_output('.results_xsl/' + volume[27:] + '.json')
		except:
			print(etree.tostring(new_tree))
			for error in transform.error_log:
				print(error.message, error.line)
			sys.exit()

def validate(file):
	bashCommand = 'ajv validate -s ../schemas/EF-Schema/ef_2_20_schema.json -d ../outputs/' + file
	with open('output_validation.txt','a') as err_output:
		subprocess.call(bashCommand.split(), stderr=err_output)

def main():
	bibframe_folder = './inputs'
	json_folder = '../outputs'
	instance = { 'id': None, 'metadata': None }
	work = { 'id': None, 'metadata': None }

	p = Pool(4)

	start_time = datetime.datetime.now().time()
	for root, dirs, files in os.walk(json_folder):
		p.map(validate,files)
#			for f in files:
#				bashCommand = 'ajv validate -s ../schemas/EF-Schema/ef_2_20_schema.json -d ../outputs/' + f
#				subprocess.call(bashCommand.split(), stderr=err_output)

	end_time = datetime.datetime.now().time()
	print("Start time: " + str(start_time))
	print("End time: " + str(end_time))
	print("Run duration: " + str(datetime.datetime.combine(datetime.date.min,end_time)-datetime.datetime.combine(datetime.date.min,start_time)))
#			if '.xml' in f:
#				file_path = bibframe_folder + '/' + f[5:-5].replace('_segment','') + '/' + f
#				file_path = bibframe_folder + '/' + f
#				print(file_path)
#				tree = etree.parse(file_path)
#				print(tree)
#				volume_ids = tree.xpath('bf:Item/@rdf:about',namespaces={'bf': 'http://id.loc.gov/ontologies/bibframe/', 'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'})
#				generateXMLTripleForVolumes(list(OrderedDict.fromkeys(volume_ids)),tree,work,instance)
#				sys.exit()

main()